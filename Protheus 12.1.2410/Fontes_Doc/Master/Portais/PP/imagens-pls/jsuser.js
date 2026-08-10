//============================================
//Funções utilizadas em mais de uma guia//
//============================================
 
var cDataServ = document.getElementById('cDataServ');
var cBtnExec  = "BrcNumAut";

//--------------------------------------------------------------------
// Monta as rdas														  
//--------------------------------------------------------------------
function fRda(cRda, cCodLoc) {
   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
	   callback: CarregaRda, 
	   error: ExibeErro
   });
}

//--------------------------------------------------------------------
// Imprime a guia														  
//--------------------------------------------------------------------
function fImpGuia() {
   var cTipoGuia = (wasDef( typeof cTp) ? cTp.value : '1')
   if(document.getElementById("cNumAut") != null  ){
	   var cNumAut = document.getElementById("cNumAut").value;
	   var cReimpr = '0';
	 }else{
		 if(document.getElementById("cNumeHoId") != null){
			 var cNumAut = document.getElementById("cNumeHoId").value;
			 var cReimpr = '0';
	   }else{
		   var cNumAut = "";
			 var cReimpr = '0';
	   }
   }

   ChamaPoP('W_PPLRELGEN.APW?cFunName=PPRELST&cReimpr='+ cReimpr +'&Field_NUMAUT=' + cNumAut ,'bol','yes',0,925,605,1/*abre varias janelas*/); 
}

//--------------------------------------------------------------------
// Monta os Solicitantes/Executante									  
//--------------------------------------------------------------------
cBusca   = "";
cTimeOut = 0;
cProfAntG= "";
cSenhaOk = false;
lGuiResInt = false;
aBkpHonRes = '';
cPasgridCe = '99'
aCodEspOdo = [];
totalArray = 0;

//--------------------------------------------------------------------
// Limpa a variavel de busca no tempo determinado
//--------------------------------------------------------------------
function fProfSauRestart() {
   clearTimeout(cTimeOut);
   cBusca = "";
}

//============================================
//Funções utilizadas na GUIA SADT
//============================================

//--------------------------------------------------------------------
// Abre popup
//--------------------------------------------------------------------
function fAbre(cHtml) {   
   janela = window.open(cHtml,"PopAjuda", "width=400, height=300, left=0, top=110, scrollbars=0");
}  
//--------------------------------------------------------------------
// Validacao da re-consulta - ponto de entrada no botao confirmar da guia 
// GUIA DE SADT                                                           
//--------------------------------------------------------------------
function fRegEsp(cCmpReg) {
   //--------------------------------------------------------------------
   // Valida re-consulta													   
   //--------------------------------------------------------------------
   if (document.getElementById("cRegEsp").value == "1") {
	   //--------------------------------------------------------------------
	   // Variavel global para colocar em foco e variavel global para ativar o obrigatorio   
	   //--------------------------------------------------------------------
	   setCtrErro('focus',cCmpReg);
	   setCtrErro('obrigatorio',cCmpReg);
	   setCtrErro('delete','cIteRegEsp');
	   
	   if (typeof cCpoRegCon == 'undefined') cCpoRegCon = '';
	   //--------------------------------------------------------------------
	   // Variavel local																	   
	   //--------------------------------------------------------------------
	   var cCodRda = document.getElementById("cRda").value;
	   var cMatric = document.getElementById("cNumeCart").value;
	   var cCodPad = document.getElementById("cCodPadSSol").value;
	   var cCodPro = document.getElementById("cCodProSSol").value;
		  var dDatPro = document.getElementById("dDtSolicit").value;

	   if (cCodPad != '' && cCodPro != '') {
		   cCpoRegCon = cCodPad + cCodPro;
		   //--------------------------------------------------------------------
		   // Executa regra especifica do cliente									   
		   //--------------------------------------------------------------------
		   Ajax.open("W_PPSVLDESP.APW?cCodRda=" + cCodRda + "&cMatric=" + cMatric + "&cCodPad=" + cCodPad + "&cCodPro=" + cCodPro + "&dDatPro=" + dDatPro, { 
			   error: ExibeErro 
		   });
	   }

   } else {
	   return true;
   }
}

//--------------------------------------------------------------------
// Validacao da re-consulta para quando excluir o item					   
//--------------------------------------------------------------------
function fRegEspExc(cCmpReg, cTable) {
   var i, x, z, chkbox;
   var cIteAux = '';
   var cIteEsp = document.getElementById('cIteRegEsp').value;
   var oTable  = document.getElementById(cTable);
   //--------------------------------------------------------------------
   // Vai em todas as linhas da tabela para ver qual esta marcado			   
   //--------------------------------------------------------------------
   for (i = 1; i < oTable.rows.length; i++) {
	   chkbox = document.getElementById("chkbox" + cTable + i);

	   if (chkbox) {
		   if (chkbox.checked) {
			   cIteAux = '';
			   var cCodPad = getTC(oTable.rows[i].cells[2]);
			   var cCodPro = getTC(oTable.rows[i].cells[3]);

			   if (cIteEsp != '' && cIteEsp.indexOf(cCodPad + cCodPro) != -1 && cCodPad != '' && cCodPro != '') {

				   var aRegEspExc = document.getElementById('cIteRegEsp').value.split('|');

				   for (var x = 0; x < aRegEspExc.length; x++) {
					   if (aRegEspExc[x] != cCodPad + cCodPro && aRegEspExc[x] != '') {
						   cIteAux += aRegEspExc[x] + '|';
					   }
				   }
				   //--------------------------------------------------------------------
				   // Desativa a obrigatoriedade do campo									   
				   //--------------------------------------------------------------------
				   if (cIteAux != '') {
					   document.getElementById('cIteRegEsp').value = cIteAux;
				   } else {
					   for (z = 0; z < oForm.campos.length; z++) {
						   if (oForm.campos[z].campo.id == cCmpReg) {
							   oForm.campos[z].branco = true;
						   }
					   }
				   }
			   }
		   }
	   }
   }
}
//--------------------------------------------------------------------
// Ajusta solicitacao para mais de uma rda								   
//--------------------------------------------------------------------
function fAjusForm(lHab) {
   //--------------------------------------------------------------------
   // Solicitacao															   
   //--------------------------------------------------------------------
   FDisElemen('TabSolSer|bIncTabSolSer|bSaveTabSolSer',!lHab);
   
   //--------------------------------------------------------------------
   // Habilita campos especificos											   
   //--------------------------------------------------------------------
   //Solicitação
   setDisable("cGuiaPrincipal",!lHab);
   setDisable("cAtendRN",!lHab);
   setDisable("cProSolDesc",!lHab);
   
   //foi necessário fazer desse jeito abaixo, pois os botões tinham o mesmo nome e id
   var btn = document.querySelectorAll("#BcProSolDesc");
   for (var i = 0 ; i< btn.length ; i++){
	   if (isDitacaoOffline()){
		   btn[i].disabled = lHab;
		   btn[i].className = lHab ? "btn btn-default disabled" : "btn btn-default";
	   }else{
		   btn[i].disabled = !lHab;
		   btn[i].className = !lHab ? "btn btn-default disabled" : "btn btn-default";
	   }
   }
   
   setDisable("cCbosSol",!lHab); //Inverter offline
   if (!isDitacaoOffline()){
	   setDisable("BcCarSolicit",!lHab); 
	   setDisable("cCarSolicit",!lHab); 
   } else {
	   setDisable("cCarSolicit",false); 
   }
   
   setDisable("cIndCliSol",!lHab); //Inverter offline
   setDisable("cCodPadSSol",!lHab);
   setDisable("cCodProSSol",!lHab);
   setDisable("cQtdSSol",!lHab);
   
   //Grid de Solicitação
   setDisable("TabSolSer",!lHab);
   setDisable("bIncTabSolSer",!lHab);
   setDisable("bSaveTabSolSer",lHab); //Inverter
   
   //Execução
   setDisable("cEstSigExe",lHab);
   setDisable("cTipCon",lHab);
   setDisable("nSeqRef",lHab);
   setDisable("cGraPartExe",lHab);
   setDisable("cCbosExe",lHab);
   
   setDisable("cHorIniSExe",lHab);
   setDisable("cHorFimSExe",lHab);
   setDisable("cCodPadSExe",lHab);
   setDisable("cCodProSExe",lHab);
   setDisable("cQtdSExe",lHab);
   setDisable("cViaSExe",lHab);
   setDisable("cTecSExe",lHab);
   setDisable("nRedAcreSExe",lHab);
   setDisable("nVlrUniSExe",lHab);
   setDisable("nVlrTotSExe",lHab);
   
   //Grid Execução
   setDisable("TabExeSer",lHab);
   setDisable("bIncTabExeSer",lHab);
   setDisable("bSaveTabExeSer",true); //Sempre desabilita; só deve ser habilitado quando for alteração de item
   setDisable("bIncTabExe",lHab);
   setDisable("bSaveTabExe",true);

   //Ajusta a exibição dos grupos de campos entre SADT e liberação
   if(document.getElementById("cCnpjCpfExe").value == "" && !isDitacaoOffline()){  
	   $('#GrpDadExe').slideUp();
	   $('#GrpExeSer').slideUp();
	   $('#GrpIndExe').slideUp(); 
	   
	   $("#GrpExeSer :input").prop("disabled", lHab);
	   
   }else if(!lHab && !isDitacaoOffline()){ 
	   
	   $('#GrpDadSnte').slideUp();
	   $('#GrpSolSer').slideUp();
	   
	   $('#GrpDadExe').slideUp();
	   $('#GrpExeSer').slideDown();
	   $('#GrpIndExe').slideDown(); 
	   $('#GrpDadApe').slideDown(); 
	   
	   setDisable("cTpAteExe",lHab); 
	   setDisable("BcTpAteExe",lHab);
	   
	   setDisable("cIndAcid",lHab); 
	   setDisable("BcIndAcid",lHab);
	   
	   setDisable("cTpCon",lHab); 
	   setDisable("BcTpCon",lHab);
	   
	   setDisable("cTpSai",lHab); 
	   setDisable("BcTpSai",lHab);
	   
	   $("#GrpExeSer :input").prop("disabled", lHab); 
   
   }else if(isDitacaoOffline()){ 
	   
	   $('#GrpIndExe').slideDown();

	   setDisable("cTpAteExe",lHab); 
	   setDisable("cIndAcid",lHab);
	   setDisable("cTpCon",lHab); 
	   setDisable("cTpSai",lHab); 

	   setDisable("cAtendRN",lHab);
	   setDisable("cCbosSol",lHab);
	   setDisable("cIndCliSol",lHab);
	   setDisable("bSaveTabSolSer",!lHab);
   }
}

function fVldExec(nRecno, cTable, nOpc) {
   var cCodPad = "";
   var cCodPro = "";
   var cDtPro = "";
   var nQtdGrPar = 0;
   var cCodLoc = document.getElementById("cCodLoc").value;

   
   //Desabilita botoes
   setDisable("bIncTabExe",true);
   
   if(document.getElementById("nSeqRef").value == ""){
	   alert("Informe a sequência do procedimento.");
	   //Habilita botoes
	   setDisable("bIncTabExe",false);
	   return;
   }
   
   if(document.getElementById("cGraPartExe").value == ""){
	   alert("Informe o Grau de Participação do procedimento.");
	   //Habilita botoes
	   setDisable("bIncTabExe",false);
	   return;
   }

   var cGraPartExe = document.getElementById("cGraPartExe").value;
   var lReturn = true
   var nSeq = parseInt(document.getElementById("nSeqRef").value)
   //--------------------------------------------------------------------
   // Verifica se a sequencia existe 										  
   //--------------------------------------------------------------------
   if ( typeof oTabExeSer != "string" && oTabExeSer.aCols.length > 0 ){
	   //Recupera os dados do grid
	   var oTableExe = oTabExeSer.getObjCols();
	   var nLen = oTableExe.rows.length;
	   
	   if ( isNaN(nSeq) || nSeq > nLen || nSeq == 0){
		   lReturn = true;
	   } else {
		   lReturn = false;
		   cDtPro = getTC(oTableExe.rows[nSeq - 1].cells[3]); //Data do procedimento
		   cCodPad = getTC(oTableExe.rows[nSeq - 1].cells[6]); //Codigo do tabela padrão 
		   cCodPro = getTC(oTableExe.rows[nSeq - 1].cells[7]); //Codigo do procedimento
	   }
   }
   if (lReturn){
	   alert('Sequência inválida');
	   //Habilita botoes
	   setDisable("bIncTabExe",false);
	   return;
   }
   
   if ( typeof eval("o"+cTable) != "string" && eval("o"+cTable).aCols.length > 0 ) {
	   //Recupera os dados do grid
	   var oTable = eval("o"+cTable).getObjCols();
   }
   
   if ( typeof oTable != "string" && oTable != null ) {
	   var nQtdLinTab = oTable.rows.length;
	   for (var i = 0; i < nQtdLinTab; i++) {
		   var item = oTable.rows[i];
		   //Pega qtde de participações iguais na grid
		   if (getTC(item.cells[4]) == cGraPartExe) {
			   nQtdGrPar += 1;
		   }
	   }
   }else{
	   var nQtdLinTab = 0
   }
   
   //--------------------------------------------------------------------
   // Verifica duplicidade												  
   //--------------------------------------------------------------------
   for (var i = 0; i < nQtdLinTab; i++) {
	   
	   //--------------------------------------------------------------------
	   // Verfica se existe um registro igual na tabela						  
	   //--------------------------------------------------------------------
	   var lResult = false;
	   if ((i + 1 != parseInt(nRecno) || nRecno == 0)
		   && getTC(oTable.rows[i].cells[6]) == document.getElementById("cProExe").value
		   && getTC(oTable.rows[i].cells[4]) == document.getElementById("cGraPartExe").value) {
			   
		   alert('Já existe este registro');
		   //Habilita botoes
		   setDisable("bIncTabExe",false);
		   return;
	   }
	   
   }

   var cQueryString = "&cCodRda=" + document.getElementById("cRda").value +
						  "&cCodPad=" + cCodPad +
						  "&cCodPro=" + cCodPro +
						  "&dDatPro=" + cDtPro +
						  "&nQtGrPart=" + nQtdGrPar +
						  "&cCodLoc=" + cCodLoc +
						  "&cCodEsp=" + document.getElementById("cCbosExe").value +
						  "&cGrPart=" + cGraPartExe;
   //--------------------------------------------------------------------
   // Executa o metodo													  
   //--------------------------------------------------------------------
   Ajax.open("W_PPLVLDEX.APW?nRecno=" + nRecno + "&cTable=" + cTable + "&nOpc=" + nOpc + cQueryString, {
	   callback: CarregaExecutante,
	   error: ExibeErro
   });
}

function CarregaExecutante(v) {
   var result = v.split("|");
   //Habilita botoes
   setDisable("bIncTabExe",false);
   if (result[0] == "grau_invalido"){ 
	   ExibeErro("false|" + result[1]);
   } else { 
	   fGetDadGen(result[0], result[1], result[2]); 
   }
}
function fChkIc(ref){
   aMatAux2 = [oTabSolSer];     
   cStringEnvTab = "";                                                  
   cIndCli = "";
   cCampoRef = ref.name;
   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   if(aMatAux2 != ""){
	   aMat   		  = aMatAux2;
	   
	   for (var i = 0; i < aMat.length; i++) {

		   aInfoAux = aMat[i]
		   if (  aInfoAux.aCols.length > 0 ){
			   //Pega o nome do grid
			   oTable = aInfoAux.getObjCols();
			   //Associa a coluna com a variável do post
			   fMontMatGer('A', "TabSolSer");
			   aMatCampAux = aMatCap.split("|");    
			   
			   for (var y = 0; y < oTable.rows.length; y++) {
				   nf 	 = 0;
	   
				   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {
					   
					   cCampo = aMatCampAux[x - 2].split("$")[1];
					   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
						   celula = oTable.rows[y].cells[x + 1 - nf];
						   
						   if (typeof celula.value == 'undefined' || celula.value == '')
							   conteudo = getTC(celula);
						   else  conteudo = celula.value;	
						   
						   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
					   }
					   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;

				   }
				   cStringEnvTab += "|";
			   }
		   }			
	   }
   } 
   if (document.getElementById("cIndCliSol") != null) {
		   cIndCli = document.getElementById('cIndCliSol').value;
   }
   if (cStringEnvTab != "") Ajax.open("W_PPLTRTIND.APW?cCampoRef="+cCampoRef+"&cIndCli="+cIndCli+"&cString=" + cStringEnvTab , { 
						   error: ExibeErro 
					  });
}
//--------------------------------------------------------------------
// Monta tabela de procedimento e quantidades linha a linha (autorizacao) 
//--------------------------------------------------------------------
aCalcProcTotal = Array();
function fMontItens(cTp, cTable,nRecno) {
   var rowCount = $('#tabTabExeSer tr').length;
   
   cTpR 		 = cTp;
   cTableR 	 = cTable;
   cQueryString = "&cRda=" + document.getElementById('cRda').value + "&cCodLoc=" + document.getElementById('cCodLoc').value;
   
	 var cCodPad = document.getElementById("cCodPadSExe").value;
   var cViaExe    =  ""; 
   var cViaTable  =  ""; 
   
   //Desabilita botoes
   setDisable("bIncTabSolSer",true);
   setDisable("bSaveTabSolSer",true); 
   setDisable("bIncTabExeSer",true);
   setDisable("bSaveTabExeSer",true); 
   
   //--------------------------------------------------------------------
   // Numero da liberacao													  
   //--------------------------------------------------------------------
   if ( isDitacaoOffline() ) {
   
	   var cNumInt  = document.getElementById("cNumInt").value;
	   var cChavSol = ( wasDef( typeof cNumInt) && ! isEmpty(cNumInt) ? cNumInt : document.getElementById("cNumAut").value ); 
   
   } else {
   
	   var cChavSol = document.getElementById("cNumAut").value; 
   
   }
   //--------------------------------------------------------------------
   // Monta conteudo das tabelas solicitacao e execucao					  
   //--------------------------------------------------------------------
   if (cTable == "TabSolSer")
		aMatAux = "TabSolSer$oTabSolSer";
   else if (cTable == "TabExeSer"){ 
	   aMatAux = "TabExeSer$oTabExeSer";
   }
   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   cStringEnvTab = "";
   aMat = aMatAux.split("|");
   var x = document.getElementById('cMsnBloInt').value;
   
   if ( (document.getElementById('cNumInt').value == "") && x != "" ) {
	   alert('Informe a Guia Principal');
	   document.getElementById('cNumInt').focus();
	   //Habilita botoes
	   setDisable("bIncTabSolSer",false);
	   setDisable("bIncTabExeSer",false);
	   return;
   } 
   
   for (var i = 0; i < aMat.length; i++) {
	   aMatAux = aMat[i].split("$")
	   //Se o grid foi preenchido
	   if(typeof eval(aMatAux[1]) != "string" && eval(aMatAux[1]).aCols.length > 0){
		   //Recupera os dados do grid
		   oTable = eval(aMatAux[1]).getObjCols();
		   
		   fMontMatGer('A', aMatAux[0]);
		   
		   aMatCampAux = aMatCap.split("|");
		   for (var y = 0; y < oTable.rows.length; y++) {
			   nf = 0;                  
			   cStringEnvTab += "cSeq@"+getTC(oTable.rows[y].cells[0])+"$";
			   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {
					
					if (x-2 < aMatCampAux.length){
					cCampo = aMatCampAux[x - 2].split("$")[1];
					if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
					   celula = oTable.rows[y].cells[x + 1 - nf];
					   
					   if (typeof celula.value == 'undefined' || celula.value == '')
							conteudo = getTC(celula);
					   else conteudo = celula.value;	
					   
					   cStringEnvTab += cCampo + "@" + conteudo + "$";
					}
					if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;
					}
				   
			   }      
			   cStringEnvTab += "|";
		   }
	   }
   }
   //--------------------------------------------------------------------
   // Define parametros para uso na funcao de resultado					  
   //--------------------------------------------------------------------
   fMontMatGer(cTp, cTable);
   //--------------------------------------------------------------------
   // Matriz de campos													  
   //--------------------------------------------------------------------
   var aMatCol = aMatCap.split("|");
   if (eval(aMatAux[1]) != "" && eval(aMatAux[1]).aCols.length > 0){
	   var oTable  = eval(aMatAux[1]).getObjCols();
   }else{
	   var oTable = null
   }
   //--------------------------------------------------------------------
   // Tratamento inclusao ou alteracao									  
   //--------------------------------------------------------------------
   if (cTp == 'I' || cTp == 'A') {
	   switch (cTable) {
		   case "TabSolSer":
			   if (document.getElementById('cQtdSSol').value == "" || document.getElementById('cQtdSSol').value == "0") {
				   alert('Informe a quantidade de Serviço');
				   document.getElementById('cQtdSSol').focus();
				   //Habilita botoes
				   setDisable("bIncTabSolSer",false);
				   setDisable("bIncTabExeSer",false);
				   return;
			   }
			   if (document.getElementById('cProSolDesc').value == "") {
				   alert('Informe o profissional Solicitante');
				   document.getElementById('cProSolDesc').focus();
				   //Habilita botoes
				   setDisable("bIncTabSolSer",false);
				   setDisable("bIncTabExeSer",false);
				   return;
			   }  
			   if (cTp == 'I')
				   document.getElementById('cQtdAutSSol').value = document.getElementById('cQtdSSol').value;
			   break;   
		   case "TabExeSer":
			   if (document.getElementById('cQtdSExe').value == "" || document.getElementById('cQtdSExe').value == "0") {
				   alert('Informe a quantidade de Serviço');   
				   document.getElementById('cQtdSExe').focus();
				   //Habilita botoes
				   setDisable("bIncTabSolSer",false);
				   setDisable("bIncTabExeSer",false);
				   return;
			   }
			   break;
		   
		   }
	   //--------------------------------------------------------------------
	   // Verifica duplicidade												   
	   //--------------------------------------------------------------------
	   var nCol 		= 0;
	   if (typeof oTable != "string" && oTable != null){
		   var nQtdLinTab  = oTable.rows.length;
	   }else{
		   var nQtdLinTab = 0;
	   }
	   var cString 	= '1'+"|";
	   var cContChave  = document.getElementById(cChave).value;
	   if (cContChave == "") {
		  alert("Serviço não informado");
		  document.getElementById(cChave).focus();
		   //Habilita botoes
		   setDisable("bIncTabSolSer",false);
		   setDisable("bIncTabExeSer",false);
		  return;
	   }
	   //--------------------------------------------------------------------
	   // Monta a sequencia e matriz de retorno								   
	   //--------------------------------------------------------------------
	   if (document.getElementById(aMatAux[1]) != null) {
		   if (typeof document.getElementById(aMatAux[1]).length != 'undefined') {
			   if (cTp == 'I') 
					cString = String(document.getElementById(aMatAux[1]).length + 1) + "|";
			   else cString = String(document.getElementById(aMatAux[1]).length) + "|";
		   }
	   }
	   //--------------------------------------------------------------------
	   // Cbos do executante ou solicitante									  
	   //--------------------------------------------------------------------
	   if (cChavSol == '' || document.getElementById("cCbosExe").value == ''){
		   cCbos = document.getElementById("cCbosSol").value;
	   } else {
		   cCbos = document.getElementById("cCbosExe").value;
	   }
	   //--------------------------------------------------------------------
	   // Monta envio das variaveis de sessao GET								  
	   //--------------------------------------------------------------------
	   cQueryString =	"&cRda="+document.getElementById('cRda').value+
					   "&cCodLoc="+document.getElementById('cCodLoc').value+
					   "&cProSol="+document.getElementById('cProSol').value+
					   "&cProExe="+document.getElementById('cProExe').value+
					   "&dDtSolicit="+document.getElementById('dDtSolicit').value+
					   "&cNumAut="+cChavSol+
					   "&cCbos="+cCbos+
					   "&cAteRN="+document.getElementById('cAtendRN').value+
					   "&cChvBD6="+document.getElementById('cChvBD6').value+
					   "&cVlrUniSExe="+document.getElementById('nVlrUniSExe').value+
					   "&cCarSolicit="+document.getElementById('cCarSolicit').value+
					   "&cCobertEsp="+document.getElementById('cCobertEsp').value+
					   "&cRegAtendim="+document.getElementById('cRegAtendim').value+
					   "&cSaudeOcupac="+document.getElementById('cSaudeOcupac').value
	   
	   if (document.getElementById('cRecnoBD5') != undefined && document.getElementById('cRecnoBD5') != null){
		   cQueryString += "&cRecnoBD5="+document.getElementById('cRecnoBD5').value;
	   }
	   if (document.getElementById("cIndCliSol") != null) {
		   cQueryString += "&cIndCli="+(document.getElementById('cIndCliSol').value == "" ? "" : "1");
	   }
	   
	   cCamGer = "";
	   var objSubJson = "{";
	  for (var i = 0; i < aMatCol.length; i++) {
		   var aMatColAux = aMatCol[i].split("$");
		   cCampo = document.getElementById(aMatColAux[0]);
		   if (typeof cCampo != 'undefined' && cCampo != null && aMatNGet.indexOf(aMatColAux[1])==-1) {
			   cQueryString += "&" + aMatColAux[1] + "=" + cCampo.value;
			   
			   if(typeof oGuiaOff != 'undefined'){
				   if(cTp == 'I'){
					   objSubJson += '"' + aMatColAux[1] + '"' + ':{ "defaultValue" : ' + '"' + cCampo.value.trim() + '"' + ', "actualValue": ' + '"' + cCampo.value.trim() + '"}';
					   objSubJson += ","
				   }else{
					   objSubJson = getObjects(oGuiaOff, "sequen",nRecno);
					   if(objSubJson.length > 0){
						   objSubJson = objSubJson[0];
						   if(objSubJson[aMatColAux[1]] != undefined){ 
							   objSubJson[aMatColAux[1]].actualValue = cCampo.value.trim();
						   }
					   }
				   }
			   }
			   
		   }
	   }
	   
	   if(cTp == 'I'){
		   objSubJson +=  '"sequen":' + '"' + (typeof eval(aMatAux[1]) != "string" ? (eval(aMatAux[1]).aCols.length+1).toString() : "1") + '",';
		   objSubJson +=  '"lNewIte":true,';
		   objSubJson +=  '"lDelIte":false}';
	   }
	   //--------------------------------------------------------------------
	   // Verifica duplicidade												  
	   //--------------------------------------------------------------------
	   for (var i = 0; i < nQtdLinTab; i++) {
		   for (var y = 0; y < aMatCol.length; y++) {
			   var aMatColAux = aMatCol[y].split("$");
			   if (aMatColAux[0] == cChave) {
				   nCol = y;
				   break;
			   }	
		   }
		   if (cTp == 'A') nCol++;
		   
		   //--------------------------------------------------------------------
		   // Verfica se existe um registro igual na tabela						  
		   //--------------------------------------------------------------------
		   var lResult = false;   
		   	if(i+1 != parseInt(nRecno) && getTC(oTable.rows[i].cells[nCol+2]) != cContChave){
				if(i > 0){
					cQueryString += "|" + getTC(oTable.rows[i].cells[nCol+1]) + getTC(oTable.rows[i].cells[nCol+2]);
				}else {
					cQueryString += "&cListProc=" + getTC(oTable.rows[i].cells[nCol+1]) + getTC(oTable.rows[i].cells[nCol+2]);
				}
			}else if (i+1 != parseInt(nRecno) && getTC(oTable.rows[i].cells[nCol+2]) ==	cContChave) {
				//--------------------------------------------------------------------
				// verifica se algum campo foi alterado			   					   
				//--------------------------------------------------------------------
				if ((cTp == "A" || cTable == "TabExeSer") && oTable.rows[i].style.backgroundColor != "") {
					cSt = "0";
					//--------------------------------------------------------------------
					// Verifica se alguma campo que necessita de checar a regra novamente foi alterado
					//--------------------------------------------------------------------
					lResult = true;
					
					var ldata   = false;
					var lcodpro = false;
					var lcodtab = false;
					var lvia    = false;
					
					for (var y = 2; y < oTable.rows[i].cells.length; y++) {
						if (aMatCol[y - 2] != undefined){
							var aMatColAux = aMatCol[y - 2].split("$");
							cCampo = document.getElementById(aMatColAux[0]);
							if (cCampo != null){
								if (getTC(oTable.rows[i].cells[3]) == cCampo.value.trim()){
									ldata   = true;
								}
								if (getTC(oTable.rows[i].cells[6]) == cCampo.value.trim()){
									lcodtab   = true;
								}	
								if (getTC(oTable.rows[i].cells[7]) == cCampo.value.trim()){
									lcodpro   = true;
								}												
							}
							if (cCampo != undefined && getTC(oTable.rows[i].cells[y]) != cCampo.value.trim()) {
								cSt = "1";
								if (aValAlt.indexOf(aMatColAux[0]) != -1) lResult = false;
							}
						}
					}
					
					
					// Necessário seta um valor padrão para campos em branco.
					cViaExe = (document.getElementById("cViaSExe").value == "" ? '0' : document.getElementById("cViaSExe").value);
					cViaTable = (getTC(oTable.rows[i].cells[10]) == "" ? '0' : getTC(oTable.rows[i].cells[10]));
					
					if (cViaTable == cViaExe){
						lvia = true;
					}				
					
					if(document.getElementById("dDtExe").value == "" && cTable == "TabExeSer"){
						modalBS("Atenção", "<p>A data de Atendimento é obrigatória</p>", "@Fechar~closeModalBS();", "white~#960000", "large");
						setDisable("bIncTabSolSer",false);
						setDisable("bIncTabExeSer",false);
						return;							
					}
					
					if (lcodpro && lcodtab &&ldata &&lvia){
						modalBS("Atenção", "<p>Este procedimento já foi informado, utilize o campo quantidade</p>", "@Fechar~closeModalBS();", "white~#960000", "large");
						setDisable("bIncTabSolSer",false);
						setDisable("bIncTabExeSer",false);
						return;
					}
						
					//--------------------------------------------------------------------
					// Altera a tabela sem checar a regra novamente								  
					//--------------------------------------------------------------------
					if (lResult) {
						fGetDadGen(nRecno, cTable ,4,true,cCampo.value,"",cCampoDefault.replace(/\|/g,","));						
						return;
					}
					
				} else if(cTable != "TabExeSer") {
					modalBS("Atenção", "<p>Este procedimento já foi informado, utilize o campo quantidade</p>", "@Fechar~closeModalBS();", "white~#960000", "large");
					//Habilita botoes
					setDisable("bIncTabSolSer",false);
					setDisable("bIncTabExeSer",false);
					return;
				}
	   		}
	   }
   }
   
   cString += aMatRet + "|" + cStringEnvTab + "|"; 

   nRecno = document.getElementById(cTableR+"_RECNO").value;
   cVlrRec = document.getElementById("nVlrTotSExe").value;

   if(nRecno == "")
   {
	   nRecno += (aCalcProcTotal.length + 1);
   }

   if ((cTp == "I") && (typeof oGuiaOff != 'undefined'))
	   oGuiaOff.procedimentos.push(JSON.parse(objSubJson));
	  //--------------------------------------------------------------------
	  // Executa o metodo													  
	  //--------------------------------------------------------------------
	  if (!lResult) Ajax.open("W_PPLSAUTITE.APW?cString=" + cString + cQueryString, { 
						  callback: CarregaMontItensSADT,
					   error: ExibeErroJsonSADT 
				   });
 
   //--------------------------------------------------------------------
   // Calculo de valores primeiro campo recebe segundo campo o valor do	  
   // campo e pego da tabela												  
   //--------------------------------------------------------------------
   if (typeof aCalVal != 'undefined' && aCalVal != null) {
	   var aCalValAux = aCalVal.split("|");
	   for (var i = 0; i < aCalValAux.length; i++) {
		   if (aCalValAux[i] != "") {
			   var aMatCamp = aCalValAux[i].split("$");
			   //--------------------------------------------------------------------
			   // Para pegar os campos de informacao e recebimento					  
			   //--------------------------------------------------------------------
			   if (typeof aMatCamp[0] != 'undefined' && aMatCamp[0] != null && typeof aMatCamp[1] != 'undefined' && aMatCamp[1] != null) {
				   //--------------------------------------------------------------------
				   // Descobrir a coluna na tabela										  
				   //--------------------------------------------------------------------
				   for (var x = 0; x < aMatCol.length; x++) {
					   var aMatColAux = aMatCol[x].split("$");
					   if (aMatColAux[0] == aMatCamp[1]) {
						   nCol = x;
						   break;
					   }
				   }
				   if (cTp != 'I') nCol++;
				   //--------------------------------------------------------------------
				   // atualiza os campos com base no valor da tabela						  
				   //--------------------------------------------------------------------
				   var nValor = 0;
				   var cCampo = document.getElementById(aMatCamp[0]);
				   for (var x = 1; x < oTable.rows.length; x++) {
					   nValor += parseInt(getTC(oTable.rows[x].cells[nCol + 1]).replace(/\D/g, ""));
				   }
				   cCampo.value = MaskMoeda(nValor);
			   }
		   }
	   }
   }
   document.getElementById("cCodPadSExe").disabled = false;
   document.getElementById("cCodProSExe").disabled = false;
   document.getElementById("BcCodPadSExe").disabled = false;
   document.getElementById("BcCodProSExe").disabled = false;
}

function CalculaTotaisGuia(){
   var total = 0;
   var totalPro = 0;
   var totalDia = 0;
   var totalMed = 0;
   var totalMat = 0;
   var totalTax = 0;
   var totalOpme = 0;
   var totalGas = 0;
	 var lachou = false;
	 var nVlrRec = 0;
   var cTpProc = "";
   var aCampos
   var aResult 
   
   aCalcProcTotal = []

 if (document.getElementById("cTp").value == "2") {
	   $('#tabTabExeSer > tbody  > tr').each(function(index, item) {
		   nVlrRec = parseFloat(item.cells[14].innerText.replace(/\D/g, "")); // Valor total do procedimento
		   cTpProc = item.cells[15].innerText.substring(0,1); // Tipo do procedimento
		   if(nVlrRec === ""){
			   nVlrRec = 0
		   }
	   
		   switch(cTpProc) {
			   case "0":
				   totalPro += nVlrRec;				
				   break;
			   case "1":
				   totalMat += nVlrRec;
				   break;
			   case "2":
				   totalMed += nVlrRec;
				   break;
			   case "3":
				   totalTax += nVlrRec;
				   break;
			   case "5":
				   totalOpme += nVlrRec;
				   break;
			   case "7":
				   totalGas += nVlrRec;				
				   break;
			   default:
				   
				   break;
		   }
		   total += nVlrRec;		
		   aCalcProcTotal.push([index.toString(),  nVlrRec, cTpProc]); //Popula o Array
	   });
 }

 if (document.getElementById("cTp").value == "2" || document.getElementById("cTp").value == "5") {
   aResult = CalculaSadtResIntOutDes(totalPro, totalMat, totalMed, totalTax, totalOpme, totalGas, total, totalDia);
 }

   aCampos  = aResult[0] 
   for (var i = 0; i < aCampos.length; i++) {
	   // verifico se o campo existe
	   if( typeof document.getElementById(aCampos[i][0]) != "undefined") {
		   // preencho o campo com o valor atual
		   document.getElementById(aCampos[i][0]).value = MaskMoeda(aCampos[i][1]);
	   }
   }
   
   document.getElementById("nTotGerGui").value = MaskMoeda(aResult[1]);
}

function ExibeErroJsonSADT(v) {
   //Habilita botoes
   setDisable("bIncTabSolSer", false);
   setDisable("bIncTabExeSer", false);
   ExibeErroJson(v);
}

//--------------------------------------------------------------------
// Pega o retorno do processamento										  
//--------------------------------------------------------------------
function CarregaMontItensSADT(v) {                       
   var lAto 	= false;
   var aResult = v.split("|");
   var cTitulo = aResult[0]; 				//Titulo do resultado autorizado,negado ou autorizado parcial
   var aMatRet = aResult[1].split("~"); 	//Retorno para grid campos e resultado do campo
   var cTexto 	= aResult[5]; 				//Procedimento autorizados ou negados resultado
   var cLembr = aResult[6] == "0" ? "" : aResult[6]; //Lembrete do Procedimento na Tabela Padrão (BR8_LEMBRE)
   var cNumGui = '';							//Número da guia, quando inclui procedimento diretamente na base.

   //Habilita botoes
   setDisable("bIncTabSolSer",false);
   setDisable("bIncTabExeSer",false);
   
   //PLSMFUN, PPLMFUN, WSPLSXFUN e WSCLIENT_WSPLSXFUN do dia 08-07-16 ou superior. 
   var cAlerta  = aResult[7];				 //Alertas do procedimento 
   var cTitComp = aResult[8];				//complemento do titulo 

   if(aResult.length >= 11){
		cNumGui  = aResult[11];	
	   
	   cCampo = document.getElementById("cNumGuiRes");

	   if(cCampo != null && isEmpty(cCampo.value)){
		   cCampo.value = cNumGui;
	   }		
   }	

   if (typeof cTitComp != 'undefined') { 
	   
	   if (cTitulo == '1') { 
	   
		   cTitulo = cTitComp;
	   
	   } else {
		   cTitulo += cTitComp;
	   }
   } 
   
   //--------------------------------------------------------------------
   // Trata obrigatoriedade do campo de IndCliSol							  
   //--------------------------------------------------------------------	
   if ( aResult[6] != "0" && (cTp.value != "5" && cTp.value != "6")) {
	   oForm.add( document.forms[0].cIndCliSol		,"tudo"	 , false, false );
   }
   //--------------------------------------------------------------------
   // Alimentar campos de retorno											  
   //--------------------------------------------------------------------
   for (var i = 0; i < aMatRet.length; i++) {
	   aRetAux = aMatRet[i].split(";");
	   cCampo = document.getElementById(aRetAux[0]);

	   if (typeof cCampo != 'undefined' && cCampo != null) 
		   cCampo.value = aRetAux[1];
   }
   //--------------------------------------------------------------------
   // Se vai incluir ou alterar a linha campo alimentado pela aMatRet 	  
   //--------------------------------------------------------------------
   if (typeof cTableR != 'undefined' && typeof aMatCap != 'undefined' && typeof aMatBut != 'undefined') {
	   cCampo = document.getElementById("cStatusAut");
	   if (typeof cCampo != 'undefined') {

		   if (cCampo.value == '5') {
			   lAto = true;
			   cCampo.value = '1';
		   }

		   if (lGuiResInt) {
			   fCalcValHonTot("nTotGerGui","nVlrApr",cTableR,"");	
		   }

			 if (cTpR == 'I') {
				   fGetDadGen(0, cTableR ,3,true,cCampo.value,"",cCampoDefault.replace(/\|/g,","));
								   
				   var cTpAut 	  	 = "1";

				   if(cTableR == "TabSolSer"){
					   var cCodPad = document.getElementById("cCodPadSSol").value;
					   var cCodPro = document.getElementById("cCodProSSol").value;
					   var nQtdAut = document.getElementById("cQtdAutSSol").value;
					   var nQtdSol	 = document.getElementById("cQtdSSol").value;
					   var cStatus = document.getElementById("cStatusAut").value;
					   var dDtExe  = "";
					   var nRedAcreSExe = 0;					
				   }
				   else { 
				   var cCodPad = document.getElementById("cCodPadSExe").value;

				   var cCodPro 	 = document.getElementById("cCodProSExe").value;
				   var nQtdAut 	 = document.getElementById("cQtdSExe").value;
				   var cStatus 	 = document.getElementById("cStatusAut").value;
				   var dDtExe		 = document.getElementById("dDtExe").value;
				   var nRedAcreSExe = document.getElementById("nRedAcreSExe").value;
				   }
				   //Se for um pacote, adiciona todos os itens do mesmo.
				   Ajax.open("W_PPLSITEPCT.APW?cCodPct=" + (cCodPad + cCodPro) + "&qtdAutSSol=" + nQtdAut + "&cQtdSSol=" + nQtdSol +"&cStatusAut=" +cStatus  + "&cTpAut=" + cTpAut + '&dDtExe=' + dDtExe + '&nRedAcreSExe=' + nRedAcreSExe, {
					   callback: AdicionProcRelPct,
					   error: ExibeErro
				   });

				   
		   }else{
			   fGetDadGen(document.getElementById(cTableR+"_RECNO").value, cTableR ,4,true,cCampo.value,"",cCampoDefault.replace(/\|/g,","));

		   }
		   //--------------------------------------------------------------------
		   // Retorno o valor original											  
		   //--------------------------------------------------------------------
		   cCampo.value == "0";
	   }
   }
   //--------------------------------------------------------------------
   // Mostra o resultado modal so mostra se for negado ou se existir lembrete 
   //--------------------------------------------------------------------
   if (cTitulo != "1" && cTitulo != "" || cAlerta != 'undefined' && cAlerta != "") {
	   if (lGuiResInt) {
		   var cCodif = "<strong>" + cCodPro + " - </strong>" + cTexto;
		   document.getElementById("cCritProc").value += btoa(cCodif); 
		   lGuiResInt = false;
	   }	

	   if (cAlerta != "") {
		   cTexto += cAlerta;
		   ShowModal(cTitulo, cTexto, false, false, true, undefined, (cLembr != "" ? "@Fechar~RepShowModal('Lembrete:', '"+cLembr+"');" : ""));
	   } else {
		   ShowModal(cTitulo, cTexto, undefined, undefined, undefined, undefined, (cLembr != "" ? "@Fechar~RepShowModal('Lembrete:', '"+cLembr+"');" : ""));
	   }

   } else {

	   if (cLembr != "" && cLembr != "0") {
		   ShowModal("Lembrete:", cLembr);
	   }
   }   
  
   //--------------------------------------------------------------------
   // Se for pagamento no ato												   
   //--------------------------------------------------------------------
   if ( lAto )	alert("Realizar o pagamento na Operadora.\nPara este procedimento deve ser efetuado o pagamento no ato.");
}

function fAtualizaDiaria(cTipo, nQtdDSol, aMatC, oTable, cTipoProc, cCodPro, nRecnoX){
   
   var nPosPro = 0;
   var nPosQtd = 0;
   var nQtdDiarias = 0;

   if(typeof cTpPD == "undefined")
	   cTpPD = ''; //se não existir a variavel eu crio (nova prorrogação de internacao)

   if(cTipo == "I"){
	   if(cTipoProc == "4"){

		   if(cTpPD == "" && document.getElementById("cQtdDSol").value != "" && parseInt(document.getElementById("cQtdDSol").value) > 0)
			   ShowModal("Procedimento de Diária", "Você adicionou um procedimento de diária, a quantidade de diárias solicitadas será substituída pela quantidade total de procedimentos de diárias.", true);
		   
		   cTpPD += cCodPro+"~";
	   }

	   if(oTable == null){ //Se for a primeira linha
		   if(cTipoProc == "4"){
			   document.getElementById("cQtdDSol").value = nQtdDSol;
			   document.getElementById("cQtdDSol").readOnly = true;
		   }
	   }else if(cTipoProc == "4"){
		   nQtdDiarias = nQtdDSol;
		   for (var y = 1; y < aMatC.length; y++) {

			   if (aMatC[y].indexOf('cCodPro') != -1) 
				   nPosPro = y + 2
			   
			   if (aMatC[y].indexOf('cQtdAutSSol') != -1) {
				   nPosQtd = y + 2
				   break;
			   }	
		   }

		   if ( nPosPro != 0 && nPosQtd != 0 && oTable != null) {              

			   document.getElementById("cQtdDSol").value = 0;

			   //Somando os itens que estão na gride
			   for (var y = 0; y < oTable.rows.length; y++) {	
				   //--------------------------------------------------------------------
				   // Somente se nao for negado e o campo tiver o tpproc igual a 4		  
				   //--------------------------------------------------------------------
				   if ( oTable.rows[y].className != "TextoNegPeq" && cTpPD.indexOf( getTC(oTable.rows[y].cells[nPosPro]).replace( /\s*$/, "" ) ) != -1 ) {
					   nQtdDiarias = parseInt(nQtdDiarias) + parseInt( getTC(oTable.rows[y].cells[nPosQtd]) ,10 );
				   }
			   }
		   }

		   document.getElementById("cQtdDSol").value = nQtdDiarias;
		   document.getElementById("cQtdDSol").readOnly = true;
	   }
   } else if (cTipo == "A"){
	   for (var y = 1; y < aMatC.length; y++) {
		   if (aMatC[y].indexOf('cCodPro') != -1) 
			   nPosPro = y + 3
			   
		   if (aMatC[y].indexOf('cQtdAutSSol') != -1) {
			   nPosQtd = y + 3
			   break;
		   }	
	   }

	   if(cTpPD == "") //Se não possuir nada, atribue a quantidade do próprio campo, senão 0.
		   nQtdDiarias = document.getElementById("cQtdDSol").value;
	   else	
		   nQtdDiarias = "0";

	   if ( nPosPro != 0 && nPosQtd != 0 && oTable != null) {              

		   for (var y = 0; y < oTable.rows.length; y++) {	
			   //--------------------------------------------------------------------
			   // Somente se nao for negado e o campo tiver o tpproc igual a 4		  
			   //--------------------------------------------------------------------
			   if ( oTable.rows[y].className != "TextoNegPeq" && cTpPD.indexOf(getTC(oTable.rows[y].cells[nPosPro]).replace( /\s*$/, "" ) ) != -1 ) {
				   if ( (y+1) != nRecnoX) 
					   nQtdDiarias = parseInt(nQtdDiarias) + parseInt( getTC(oTable.rows[y].cells[nPosQtd]) ,10 );
			   }
		   }
	   }

	   cTpPD = cTpPD.replace( getTC(oTable.rows[nRecnoX-1].cells[nPosPro]).replace( /\s*$/, "" ) + "~" , "" );

	   if (cTipoProc == "4"){
		   cTpPD += cCodPro+"~";
		   if(cTpPD == ""){
			   nQtdDiarias = nQtdDSol;
			   ShowModal("Procedimento de Diária", "Você adicionou um procedimento de diária, a quantidade de diárias solicitadas será substituída pela quantidade total de procedimentos de diárias.", true);
		   }else{
			   nQtdDiarias = parseInt(nQtdDiarias) + parseInt(nQtdDSol);
		   }
	   }

	   if(cTpPD != ""){
		   document.getElementById("cQtdDSol").value = nQtdDiarias;
		   document.getElementById("cQtdDSol").readOnly = true;
	   }else{
		   document.getElementById("cQtdDSol").value = "";
		   document.getElementById("cQtdDSol").readOnly = false;		
	   }
	   //nQtdDiarias
   } else if (cTipo == "E"){
	   if(cTpPD.indexOf(cCodPro.replace( /\s*$/, "" ) ) != -1){

		   cTpPD = cTpPD.replace(cCodPro.replace( /\s*$/, "" ) + "~" , "" );

		   if(cTpPD != ""){
			   document.getElementById("cQtdDSol").value = parseInt(document.getElementById("cQtdDSol").value) - parseInt(nQtdDSol);
		   }else{
			   document.getElementById("cQtdDSol").value = "";
			   document.getElementById("cQtdDSol").readOnly = false;
		   }
	   }
   }
}

//--------------------------------------------------------------------
//	Roberto Vanderlei - Adiciona procedimentos relacionados ao pacote.
//--------------------------------------------------------------------
function verificaDuplicidade(cCodPro, cTable){

   var lExiste = false;

   if (typeof eval("o"+cTable) != "string" && eval("o"+cTable).aCols.length > 0 ) {
	   //Recupera os dados do grid
	   var oTable = eval("o"+cTable).getObjCols();
   }

   if ( typeof oTable != "string" && oTable != null ) {
	   var nQtdLinTab  = oTable.rows.length;
   }else{
	   var nQtdLinTab = 0
   }
   //--------------------------------------------------------------------
   // Verifica duplicidade												  
   //--------------------------------------------------------------------
   for (var i = 0; i < nQtdLinTab; i++) {

	   //--------------------------------------------------------------------
	   // Verfica se existe um registro igual na tabela						  
	   //--------------------------------------------------------------------

	   if (getTC(oTable.rows[i].cells[7]).trim() == cCodPro.trim()) {
		   lExiste = true;
	   }
   }

   return lExiste;
}

function AdicionProcRelPct(v){

   var aResult  = v.split("|");
   var aMatRet;
   var cValores;
   var cTableR 	 = 'TabSolSer';
   var cCodPct;
   var cStatusAut;

   if(aResult.length > 0 && aResult[0] != ''){

	   for(var l = 0; l < aResult.length; l++){

		   aMatRet = aResult[l].split("~");

		   if(!verificaDuplicidade(aMatRet[1].split(";")[1] /*cCodPro*/, "TabSolSer")){
			   for (var i = 0; i < aMatRet.length; i++) {
				   aRetAux = aMatRet[i].split(";");

				   cValores += aRetAux[0] + "$" + aRetAux[1] + ";";
				   
				   if (aRetAux[0] == 'cStatusAut'){
					   cStatusAut = aRetAux[1];
				   }



				   if (aRetAux[0] == 'cCodPct'){
					   cCodPct = aRetAux[1];
				   }
			   }

			   if(l < aMatRet.length)
				   cValores += "@"

			   if(l == 0) alert("O pacote de codigo " + cCodPct + " possui procedimentos relacionados, os procedimentos serao carregados e devem compor a guia.");
		   }

	   }
	   fGetDadGen(0, cTableR ,3,true,cStatusAut,cValores,cCampoDefault.replace(/\|/g,","));
   }
}

function AdicionProcRelSolPct(v){

   var aResult  = v.split("|");
   var aMatRet;
   var cValores;
   var cTableR 	 = 'TabSolSer';
   var cCodPct;
   var cStatusAut;

   if(aResult.length > 0 && aResult[0] != ''){

	   for(var l = 0; l < aResult.length; l++){

		   aMatRet = aResult[l].split("~");

		   if(!verificaDuplicidade(aMatRet[1].split(";")[1] /*cCodPro*/, "TabSolSer")){
			   for (var i = 0; i < aMatRet.length; i++) {
				   aRetAux = aMatRet[i].split(";");


				   cValores += aRetAux[0] + "$" + aRetAux[1] + ";";

				   if (aRetAux[0] == 'cStatusAut'){
					   cStatusAut = aRetAux[1];
				   }



				   if (aRetAux[0] == 'cCodPct'){
					   cCodPct = aRetAux[1];
				   }
			   }

			   if(l < aMatRet.length)
				   cValores += "@"

			   if(l == 0) alert("O pacote de codigo " + cCodPct + " possui procedimentos relacionados, os procedimentos serao carregados e devem compor a guia.");
		   }
	   }
	   fGetDadGen(0, cTableR ,3,true,/*cCampo.value*/cStatusAut,cValores /*valores*/,cCampoDefault.replace(/\|/g,","));
   }
}

//--------------------------------------------------------------------
// Monta matriz genericas												   
//--------------------------------------------------------------------
function fMontMatGer(cTp,cTable) {                                       
		   //--------------------------------------------------------------------
		   // Monta matriz genericas												   
		   //--------------------------------------------------------------------
		   switch (cTable)	{                                          
			   case "TabSolSer":
				   aMatCap 		 = ( (cTp=='I') ? 'Chk$NIL|' : "" ) + 'cCodPadSSol$cCodPad|cCodProSSol$cCodPro|cDesProSSol$cDesPro|cQtdSSol$nQtdSol|cQtdAutSSol$nQtdAut';
				   aMatBut 		 = 'bISolSer|bASolSer|bESolSer';
				   aMatRet 		 = 'cStatusAut~cQtdAutSSol';
				   cChave 			 = 'cCodProSSol';
				   cCampoDefault	 = 'cCodPadSSol;aInipadcCodPadSSol|cQtdSSol;aInipadcQtdSSol';
				   aValAlt			 = 'cCodPadSSol|cCodProSSol|cQtdSSol';
				   aCalVal			 = '';
				   aMatConv 		 = '';
				   aMatNGet 		 = 'cDesPro';
				   break;   
			   case "TabExeSer":
				   aMatCap = ((cTp == 'I') ? 'Chk$NIL|' : "") + 'dDtExe$dDtExePro|cHorIniSExe$cHorIni|cHorFimSExe$cHorFim|cCodPadSExe$cCodPad|cCodProSExe$cCodPro|cDesProSExe$cDesPro|cQtdSExe$nQtdSol|cViaSExe$cViaAc|cTecSExe$cTecUt|nRedAcreSExe$nRedAcre|nVlrUniSExe$nVlrApr|nVlrTotSExe$nVlrTAp|cTpProc$cTpProc' + ((isDitacaoOffline() && document.getElementById("cTp").value == '6') ? '|cSeqBD6G$cSeqBD6G' : '');
				   aMatBut 		 = 'bIExeSer|bAExeSer|bEExeSer';
				   aMatBut 		 = 'bIExeSer|bAExeSer|bEExeSer';
				   aMatRet 		 = 'cStatusAut~cQtdSExe';
				   cChave 			 = 'cCodProSExe';
				   cCampoDefault	 = 'cCodPadSExe;aInipadcCodPadSExe|cQtdSExe;aInipadcQtdSExe|dDtExe;aInipaddDtExe|cHorIniSExe;aInipadcHorIniSExe|cHorFimSExe;aInipadcHorFimSExe|cQtdSExe;aInipadcQtdSExe|cViaSExe;aInipadcViaSExe|cTecSExe;aInipadcTecSExe|nRedAcreSExe;aInipadnRedAcreSExe|nVlrUniSExe;aInipadnVlrUniSExe|nVlrTotSExe;aInipadnVlrTotSExe';
				   aValAlt			 = 'cCodPadSExe|cCodProSExe|cQtdSExe|dDtExe|cViaSExe';
				   aCalVal			 = '';
				   aMatConv 		 = 'cCodPadSExe$cCodPadSSol|cCodProSExe$cCodProSSol|cDesProSExe$cDesProSSol|cQtdSExe$cQtdSSol';
				   aMatNGet 		 = 'cDesPro';
				   break;
			   case "TabExe":
				   aMatCap = 'nSeqRef$cSeqPro|cGraPartExe$cGrPar|cCpfExe$cCpfExe|cProExeDesc$cProExeDesc|cCodSigExe$cCodSig|cNumCrExe$cNumCr|cEstSigExe$cEstado|cCbosExe$cCbos|cProExe$cProExe' + ((isDitacaoOffline() && document.getElementById("cTp").value == '6') ? '|cSeqBD7G$cSeqBD7G' : '');
				   aMatBut 		 = '';
				   aMatRet 		 = '';
				   cChave 			 = 'cProExe|cGrPar';
				   cCampoDefault	 = '';
				   aValAlt			 = '';
				   aCalVal			 = '';
				   aMatConv 		 = '';
				   aMatNGet 		 = '';
				   break;
			   case "TabOutDesp":
				   aMatCap 		 = ( (cTp=='I') ? 'Chk$NIL|' : "" ) + 'cCodDesp$cCodDesp|dDtExe$dDtExe|cHorIniSExe$cHorIniSExe|cHorFimSExe$cHorFimSExe|cCodPadSExe$cCodPadSExe|cCodProSExe$cCodProSExe|cQtdSExe$cQtdSExe|cUnMedidaSExe$cUnMedidaSExe|nRedAcreSExe$nRedAcreSExe|nVlrUniSExe$nVlrUniSExe|nVlrTotSExe$nVlrTotSExe|cRegAnvisa$cRegAnvisa|cRefFabricante$cRefFabricante|cAutFuncEmp$cAutFuncEmp|cDesProSExe$cDesProSExe';
				   aMatBut 		 = 'bIOutDesp|bAOutDesp|bEOutDesp';
				   aMatRet 		 = 'cStatusAut~cQtdSExe';
				   cChave 			 = 'cCodProSExe';
				   cCampoDefault	 = 'cQtdSExe;aInipadcQtdSExe|dDtExe;aInipaddDtExe';
				   aValAlt			 = 'cCodProSExe|cCodProSExe|cQtdSExe';
				   aCalVal			 = '';
				   aMatConv 		 = '';
				   aMatNGet 		 = 'cDesProSExe';
				   aNoArray		 = ['cCodDesp', 'dDtExe', 'cHorFimSExe', 'cDesProSExe', 'nRedAcreSExe', 'nVlrUniSExe', 'nVlrTotSExe', 'cUnMedidaSExe', 'cRegAnvisa', 'cRefFabricante', 'cAutFuncEmp' ]
				   break; 
			   case "TabOdonto":
				   aMatCap 		 = ( (cTp=='I') ? 'Chk$NIL|' : "" ) + 'cCodPadSE$cCodPad|cCodProSE$cCodPro|cDesProSE$cDesPro|cDentRegSE$cDente|cFaceSE$cFace|cQtdSE$nQtdSol|nQtdUSSE$nQtdUs|nVlrUniSE$nVlrCon|nVlrFrPaSE$nVlrTpf|cAutSE$cStatus|cCodNeg$cCodNeg|dDtExe$dDtExe';
				   aMatBut 		 = 'bISolSer|bASolSer|bESolSer';
				   aMatRet 		 = 'cStatusAut~nQtdUSSE~nVlrUniSE~nVlrFrPaSE~cAutSE~cCodNeg';
				   cChave 			 = 'cCodProSE';
				   cCampoDefault	 = 'cCodPadSE;NIL|cQtdSE;NIL|dDtExe;NIL';
				   aValAlt			 = 'cCodPadSE|cCodProSE|cQtdSE';
				   aCalVal			 = '';
				   aMatConv 		 = '';
				   aMatNGet 		 = 'cDesPro';
				   break;
		   }
		   
}   
						  
//--------------------------------------------------------------------
//Monta matriz genericas carrega procedimento por procedimento		  
//--------------------------------------------------------------------
function fCarregaTabela(aMatTabRel, aMatValG, cMostraSer, aMatProfG) {
   var aMatTabAux = aMatTabRel.split('|')
   var cSeqCont = '0';
   var aCampos = Array();
   var aLinhas = Array();

   if (document.getElementById("cSeqProc") != null){
	   document.getElementById("cSeqProc").value = "";
   }
   //--------------------------------------------------------------------
   // Para as tabelas informadas											  
   //--------------------------------------------------------------------
   for (var x = 0; x < aMatTabAux.length; x++) {
	   //--------------------------------------------------------------------
	   // Para habilitar o click ou nao na tabela e pegar o nome da tabela 	  
	   //--------------------------------------------------------------------
	   var aMatTab  = aMatTabAux[x].split('$');
	   var cTable 	 = aMatTab[0];
	   var cTipoAcao= aMatTab[1];
	   //--------------------------------------------------------------------
	   // Carrega variaveis													  
	   //Carrega as variáveis globais - fMontMatGer. 
	   //Uma variável importante é a que faz o de para entre a variável do protheus e a do portal. aMatCap
	   //aMatCap
	   //	Estrutura: Tipo - String, Valor: Variavel_Portal$Variavel_Protheus|...
	   //--------------------------------------------------------------------
	   fMontMatGer('I', cTable);
	   //--------------------------------------------------------------------
	   // Se vai carregar na matriz original ou vai espelhar em outra matriz	  
	   //--------------------------------------------------------------------

	   var aMatCampVal = '';
	   var aMatCol 	= aMatCap.split("|");
	   var cTpAut 		= "1";
	   //--------------------------------------------------------------------
	   // Verifica toda a matriz com campos e valores							  
	   // associa o valor retornado ao campo do form							  
	   //--------------------------------------------------------------------
	   xHeader = ""
	   xCols = ""
	   var aHeader = new Array()
	   var aCols = new Array()
	   
	   for (var z = 0; z < aMatValG.length; z++){
		   var cValores = ""
		   var aMatVal = aMatValG[z];

		   for (var y = 0; y < aMatVal.length; y++) {
			   var aMatColVal 	= aMatVal[y].split("!");
			   var cCampo 		= aMatColVal[0]
			   var cConteudo 	= aMatColVal[1]    
			   //--------------------------------------------------------------------
			   // Conforme o tipo de autorizacao muda a cor da linha					  
			   //--------------------------------------------------------------------
			   if (cCampo == 'cStatus') {
				   cTpAut = ( (cConteudo=='S') ? "1" : "0" );
				   //indica a linha que ser?marcada como criticada
				   if(cTpAut == "0"){
					   aLinhas.push(z+1);
				   }
			   }
			   //--------------------------------------------------------------------
			   // Faz o De x Para da variável do protheus com a da guia				  
			   //--------------------------------------------------------------------
			   for (var i = 0; i < aMatCol.length; i++) {
				   var aMatCampoForm = aMatCol[i].split("$");
				   if (aMatCampoForm[1]==cCampo) { 
					   cCampo = aMatCampoForm[0];
					   if(cCampo=="dDtExe" && !isDitacaoOffline()){
						   
						   //Necessário a versão do WSPLSXFUN que cria o cDataServ na função MntHidden
						   this.cDataServ = document.getElementById("cDataServ");
						   cConteudo = cDataServ.value; 
					   }
					   break;
				   }	
			   }
			   
			   if (typeof cCampo != 'undefined' && document.getElementById(cCampo) != null) {
				   document.getElementById(cCampo).value = cConteudo;
				   //--------------------------------------------------------------------
				   // Matriz para compatibilizar tabelas exemplo. solicitacao com execucao.  
				   // Como a quantidade de campos e diferente deve dizer onde o valor da	   
				   // solicitacao vai ficar na execucao									   
				   //--------------------------------------------------------------------
				   aMatCampVal += cCampo + "$" + cConteudo + "|"
				   cValores +=  cCampo + "$" + cConteudo + ";"
			   }
			   if (cCampo == 'cSeqMov') {
				   cSeqCont = cConteudo;
			   }
		   }	
		   //--------------------------------------------------------------------
		   // Insere e limpa a linha												  ?
		   //--------------------------------------------------------------------
		   if (!wasDef( typeof(cGrids) ) ){
			   if(wasDef( typeof(document.getElementById("cGrids")))){
				   cGrids = document.getElementById("cGrids")
			   }	
		   }
		   if (wasDef( typeof(cGrids) ) ){	
			   var aGrids = cGrids.value.split("@");
			   var nPos = 0
			   var nLen = aGrids.length
			   
			   
			   
			   xHeader += "@"
			   for(nI=0; nI < nLen; nI++){
				   //Localiza o grid
				   nPos = aGrids[nI].indexOf(cTable+"~");
				   if(nPos > -1){
					   //Adiciona linha no xCols
					   xCols += "@"
					   //Retorna os campos do grid
					   aCampos = aGrids[nI].split("~")[1].split('|')[0].split(',') ;
					   aDescri = aGrids[nI].split("~")[1].split('|')[1].split(',') ;

					   var nLenCmp = aCampos.length; //Numero de campos do grid

					   var aLinha = cValores.split(";");

					   var aCmpVal = new Array();
					   //Separa campo e valor
					   for(nJ = 0; nJ < aLinha.length; nJ++){
						   aCmpVal.push(aLinha[nJ].split('$'));
					   }
					   //Cria o Array de valores
					   var aValores = new Array(nLenCmp)
					   for(nJ = 0; nJ < aLinha.length; nJ++){
						   var nCmp = 0;
						   var nPosCmp = false;
						   while(nPosCmp == false && nCmp < nLenCmp){
							   if ((typeof aCmpVal[nCmp]) != "undefined") {
								   nPosCmp = aCmpVal[nCmp][0] == aCampos[nJ];
							   }
							   nCmp++;
						   }
						   if(nPosCmp){
							   --nCmp
							   aValores[nJ] = aCmpVal[nCmp][1];
						   }
					   }
					   
					   if(z==0){
						   aHeader.push({name:'Alterar'});
						   aHeader.push({name:'Excluir'});
					   }
					   aCols.push([]);
					   nLenCols = aCols.length -1;
					   aCols[nLenCols].push({field:'RECNO', value:'0#' + Trim((z+1).toString())/*.trim()*/ + "," + '"' + cTable + '"' + ",4"});
					   aCols[nLenCols].push({field:'RECNO', value:'1#' + Trim((z+1).toString())/*.trim()*/ + "," + '"' + cTable + '"' + ',5,true,"","",cCampoDefault'}); //Bot? Excluir
					   
					   nLenCmp--;
					   for(nJ = 0; nJ < nLenCmp; nJ ++){

						   var cCampo  = aCampos[nJ];//Nome da variavel
						   var cValor = aValores[nJ];//Valor do campo
						   var cTitulo = aDescri[nJ];//Descricao do campo
						   //isso aqui foi necessario par manter o legado de na hr de executar uma sadt o sistema somente 
						   //executar 1 por 1. na versao 2 era assim..
						   //Condição adicionada para que na alteração de SADT seja exibida corretamente a quantidade
						   if (cCampo == "cQtdSExe" && aValores[nJ] != ""){
							   if(cTable != "TabOutDesp" && !(cTable == "TabExeSer" && isDitacaoOffline() && isAlteraGuiaAut())) { 
								   cValor = '1';
							   }
						   }

						   if(cCampo != ""){
							   if(z==0){
								   aHeader.push({name: cTitulo }) ;
								   xHeader += cCampo + "|";
							   }
							   aCols[nLenCols].push({field:cCampo, value: cValor });  
							   
							   xCols += cValor;
							   xCols += (nJ != nLenCmp - 1 ) ? "|" : "";
						   }

					   }
				   
				   }
			   }
		   }
		   //Limpa os campos da tela
		   fLimpaCmpGridGen(aCampos,cCampoDefault.replace(/\|/g,","));
	   }

	   if (cTipoAcao == '0') {
		   aBtnFunc = "[{info:'Alterar',img:'refresh.gif',funcao:''},{info:'Excluir',img:'004.gif',funcao:''}]";
	   }else{
		   aBtnFunc = "[{info:'Alterar',img:'refresh.gif',funcao:'fVisRecGen'},{info:'Excluir',img:'004.gif',funcao:'fGetDadGen'}]";
		  if (cTable != "TabOutDesp"){
				xCols = xCols.trim();
				Ajax.open("W_PPLSETACMP.APW?cGrid=" + cTable + "&cHeader=" + xHeader + "&cCols=" + xCols +  "&aLinhas=" + aLinhas, { 
					/*callback: CarregaLiberacao,*/
					error: ExibeErro 
				});
		   }
	   }
	   if(cTable == "TabExeSer"){
			   oTabExeSer = new gridData(cTable,'630','300')
					   //--------------------------------------------------------------------
					   //?Monta Browse 
					   //--------------------------------------------------------------------
					   oTabExeSer.load({	fFunName:'',
										   nRegPagina:1,
										   nQtdReg:getField("nQtdReg"),
										   nQtdPag:getField("nQtdPag"),
										   lOverflow:true,
										   lShowLineNumber:true,
										   lChkBox:false,
										   aBtnFunc:aBtnFunc,
										   aHeader: aHeader,
										   aCols: aCols,
										   cColLeg:"",
										   aCorLeg:"",
										   cWidth:"770"});
	   }else if(cTable == "TabSolSer"){
		   oTabSolSer = new gridData(cTable,'630','300')
					   //--------------------------------------------------------------------
					   //?Monta Browse 
					   //--------------------------------------------------------------------
					   oTabSolSer.load({	fFunName:'',
										   nRegPagina:1,
										   nQtdReg:getField("nQtdReg"),
										   nQtdPag:getField("nQtdPag"),
										   lOverflow:true,
										   lShowLineNumber:true,
										   lChkBox:false,
										   aBtnFunc:aBtnFunc,
										   aHeader: aHeader,
										   aCols: aCols,
										   cColLeg:"",
										   aCorLeg:"",
										   cWidth:"770"});
	   } else if (cTable == "TabExe"){
		   oTabExe = new gridData(cTable,'630','300')

		   for ( var nnn = 0; nnn < aCols.length; nnn++ ){
		   
			   for ( var nnx = 2; nnx < aCols[nnn].length; nnx++ ){
			   
				   if (aCols[nnn][nnx] != undefined && aCols[nnn][nnx].value == undefined && aMatProfG != undefined && aMatProfG[nnn] != undefined && aMatProfG[nnn][nnx-2] != undefined ){
					   aCols[nnn][nnx].value = aMatProfG[nnn][nnx-2].split("!")[1];
				   }
			   
			   }
		   }

		   var aux2 = new Array(aHeader.length - 2);

		   for (nnn = 2; nnn < aHeader.length; nnn++){
			   aux2[nnn-2] = aHeader[nnn];
		   }			
					   //--------------------------------------------------------------------
					   // Monta Browse 
					   //--------------------------------------------------------------------
					   oTabExe.load({	fFunName:'',
					   nRegPagina:1,
					   nQtdReg:getField("nQtdReg"),
					   nQtdPag:getField("nQtdPag"),
					   lOverflow:true,
					   lShowLineNumber:true,
					   lChkBox:false,
					   aBtnFunc:{},
					   aHeader: aux2,
					   aCols: aCols,
					   cColLeg:"",
					   aCorLeg:"",
					   cWidth:"770"});

	   }else if(cTable == "TabOutDesp"){
		   oTabOutDesp = new gridData(cTable,'630','300')
					   //--------------------------------------------------------------------
					   //?Monta Browse 
					   //--------------------------------------------------------------------
					   oTabOutDesp.load({	fFunName:'',
										   nRegPagina:1,
										   nQtdReg:getField("nQtdReg"),
										   nQtdPag:getField("nQtdPag"),
										   lOverflow:true,
										   lShowLineNumber:true,
										   lChkBox:false,
										   aBtnFunc:aBtnFunc,
										   aHeader: aHeader,
										   aCols: aCols,
										   cColLeg:"",
										   aCorLeg:"",
										   cWidth:"770"});
	   }
	   
	   for(nI=0;nI<aLinhas.length;nI++){
		   if(cTable == "TabExeSer"){
			   oTabExeSer.setLinhaCor(aLinhas[nI] ,'colfixeInd','#E49494')
		   }else if(cTable == "TabSolSer"){
			   oTabSolSer.setLinhaCor(aLinhas[nI] ,'colfixeInd','#E49494')
		   }else if(cTable == "TabOutDesp"){
			   oTabOutDesp.setLinhaCor(aLinhas[nI] ,'colfixeInd','#E49494')
		   }
	   }
   }
   
   if(cTable != "TabOutDesp" && !isDitacaoOffline()){
   e = eval("o" + cTable)
   if(typeof e != "string"){
	   if (e.aCols.length > 0){
		   oTable = e.getObjCols();
		   if (oTable != null && cSeqCont != '0')
			   setTC(oTable.rows[oTable.rows.length-1].cells[0],parseInt(cSeqCont,10)+" ");
	   }
   }

}
}
//--------------------------------------------------------------------
// Função genérica para cálculo de quantidade e valor
//--------------------------------------------------------------------
function fCalcVal(nVal, nQtd, cCampo) {
   cCampo.value = MaskMoeda((nQtd * nVal.replace(/\D/g, "")));
}

//--------------------------------------------------------------------
// Verifica se o numero da liberacao existe e mostra os dados			  
//--------------------------------------------------------------------
function fChamLibera(cNumeLib) {
   cCampoRefL = 'cNumAut';
   //--------------------------------------------------------------------
   // Verifica se foi informado a chave									  
   //--------------------------------------------------------------------
   if (cNumeLib == "") {
	   ShowModal("Atenção", "Informe o numero da Solicitação", true, false, true);
	   return;
   }
   
   //valida a quantidade de caracteres digitados 
   if(!fValQtdCarac(cNumeLib.replace(/\.|-/gi,""),18)){
	   return;                                                                                                   
   }
   
   //--------------------------------------------------------------------
   // Retira a mascara													  
   //--------------------------------------------------------------------
   cNumeLib = cNumeLib.replace(/\D/g, "");
   var cRda = document.getElementById("cRda").value;
   var cMatric = document.getElementById("cNumeCart").value;
   var cCodLoc = document.getElementById("cCodLoc").value;
   
   if(document.getElementById('cNumeLib') == null){
	   var numeroLiberacao	= document.createElement('input');
	   numeroLiberacao.id	 	= 'cNumeLib';
	   numeroLiberacao.type 	= 'hidden';
	   numeroLiberacao.value 	= cNumeLib;
	   document.body.appendChild(numeroLiberacao);
   }else{
	   document.getElementById('cNumeLib').value = cNumeLib;
   }
   
   //--------------------------------------------------------------------
   // Executa o metodo													  
   //--------------------------------------------------------------------
   fMontMatGer('I', "TabExeSer");
   Ajax.open("W_PPLSERPC.APW?cNumeAut=" + cNumeLib + "&cRda=" + cRda + "&cCodLoc=" + cCodLoc + "&cMatric=" + cMatric + "&cTp=2", {
		 callback: CarregaModalPacote,
		 error: ExibeErro
   });
}


function VerificaPacote(cCodPad, cCodPro){
   
   var cRda = document.getElementById('cRda'); 
   
	Ajax.open("W_PPLSCHKPCT.APW?cCodPadPro=" + ( cCodPad.value + cCodPro.value + cRda.value ), {
			 callback: CarregaLstPct,
			 error: ExibeErro
   });
}

function CarregaLstPct(v) {

   lProcPacote = "0"; //Inicializa como n?o sendo pacote

   var aResult = v.split("?");
   var cCampo1 = "";
   var cCampo2 = "";

   lProcPacote = aResult[0];

   if ((typeof document.getElementById('cCodProSExe') != 'undefined') || (document.getElementById('cCodProSExe') == null)){
	   cCampo1 = "cCodProSExe";
   }else{
	   cCampo1 = "cCodProSSol";
   }

   if (typeof document.getElementById('cDesProSExe') != 'undefined'){
	   cCampo2 = "cDesProSExe";
   }else{
	   cCampo2 = "cDesProSSol";
   }

   if(lProcPacote == "2"){ //Indica que se trata de um item do pacote cCodPadSExe,CodProSExe
	   alert("Este procedimento esta vinculado a um ou mais pacotes, selecione o pacote correspondente a execucao.");

	   if ((typeof document.getElementById('cCodProSExe') == 'undefined') || (document.getElementById('cCodProSExe') == null) || (document.getElementById('cCodProSExe').disabled)){
		   ChamaPoP('W_PPLSXF3.APW?cFunName=PLF3BR8D&F3Nome=cCodPadSSol&F3CmpDes=cCodPadSSol,cCodProSSol,cDesProSSol&cVldGen='+aResult[1]+"$"+cRda.value,'jF3','yes');
		   document.getElementById('cCodProSSol').value = '';
		   document.getElementById('cDesProSSol').value = '';
	   
	   }else{
		   ChamaPoP('W_PPLSXF3.APW?cFunName=PLF3BR8D&F3Nome=cCodPadSExe&F3CmpDes=cCodPadSExe,cCodProSExe,cDesProSExe&cVldGen='+aResult[1]+"$"+cRda.value,'jF3','yes');
		   document.getElementById('cCodProSExe').value = '';
		   document.getElementById('cDesProSExe').value = '';
	   }
   }else if(lProcPacote == "0" && document.getElementById('cCodProSSol').value != '' && document.getElementById('cCodProSSol').value != document.getElementById('cValueProcAnt').value){ 
	   document.getElementById('cValueProcAnt').value = document.getElementById('cCodProSSol').value;
	   alert('Este pacote não pertence a esta RDA');
	   document.getElementById('cCodProSSol').value = '';
	   document.getElementById('cDesProSSol').value = '';
   }
}

function CarregaModalPacote(v) {

   var aLinhas = v.split("@");

   if(aLinhas.length > 1)
	   ShowModalPacote(aLinhas);
   else
	   callBackLib("");


}

function callBackLib(cPacote){

   HideModal();

   var cRda     = document.getElementById("cRda").value;
   var cMatric  = document.getElementById("cNumeCart").value;
   var cCodLoc  = document.getElementById("cCodLoc").value;
   var cNumeLib = document.getElementById("cNumAut").value;
	
   if (isDitacaoOffline()){
	   var cDigOff = "1";	
   }
	
   Ajax.open("W_PPLSCHALIB.APW?cNumeAut=" + cNumeLib + "&cRda=" + cRda + "&cCodLoc=" + cCodLoc + "&cMatric=" + cMatric + "&cTp=2" + "&cPacote=" + cPacote + "&cVPerDig=" + cDigOff, {
	   callback: CarregaLiberacao,
	   error: ExibeErro
   });
}

function htmlDecode(input)
{
 var doc = new DOMParser().parseFromString(input, "text/html");
 return doc.documentElement.textContent;
}

//--------------------------------------------------------------------
// Pega o retorno														  
//--------------------------------------------------------------------
function CarregaLiberacao(v) {   
   var cPSol 		= "";
   var cNSol 		= "";
   var cPSol1 		= "";
   var cNSol1 		= "";
   
   //--------------------------------------------------------------------
   //aMatCabIte -> Tem os dados do Cabeçalho e detalhe. 
   //Estrutura: 
   //		Posição 0 -> Cabeçalho: Variavel_Protheus!Valor
   //		Posição 1 -> Detalhes dos itens Solicitados: Variavel_Protheus!Valor
   //--------------------------------------------------------------------
   var aMatCabIte 	= v.split("<");
   var aCriticas = typeof aMatCabIte[3] != "undefined" && aMatCabIte[3].length > 0 ? aMatCabIte[3].split(";") : [] ; 
   var aMatCab 	= aMatCabIte[0].split("|");
   cCampoRefL 		= "";
   //--------------------------------------------------------------------
   // Verifico se a estrutura dos itens foram enviadas					  
   //--------------------------------------------------------------------
   if (typeof aMatCabIte[1] == "undefined") {
	   alert("Estrutura indefinada");
	   return;
   }
   var aMatIte = aMatCabIte[1].split("~");
   //--------------------------------------------------------------------
   // Exibe criticas de procedimentos que nao podem ser executados		  
   //--------------------------------------------------------------------
   if (typeof aMatCab[aMatCab.length-1] != "undefined") {
	   if (aMatCab[aMatCab.length-1] != "") alert(aMatCab[aMatCab.length-1]);
   }
   //--------------------------------------------------------------------
   // Cabecalho e dados do executante caso for somente um					  
   //--------------------------------------------------------------------
   for (var i = 0; i < (aMatCab.length - 1); i++) {
	   var aCamVal = aMatCab[i].split("!");
	   //--------------------------------------------------------------------
	   // Somente se foi passado o nome do campo								  
	   //--------------------------------------------------------------------
	   if (aCamVal[0] != "") {
		   var cCampo = document.getElementById(aCamVal[0]);
		   if (cCampo != null) {
			   
		   if (aCamVal[0] != "cCbosSol" && aCamVal[0] !="cCnpjSolT" && aCamVal[0] !="cNomeSolT") {
				   cCampo.value = aCamVal[1];
		   } else if (aCamVal[0] == "cCnpjSolT") {
				   cPSol1 = aCamVal[1];
			   } else if (aCamVal[0] == "cNomeSolT") {
				   cNSol1 = aCamVal[1];
				   document.getElementById("cNomeSolT").value = cNSol1;

			   } else if (aCamVal[0] == "cCbosSol") {
				   setTC(document.getElementById("cCbosSol"),"");

				   var e = document.getElementById("cCbosSol");
				   var aIten = aCamVal[1].split("$");
				   e.options[0] = new Option(aIten[1], aIten[0]);
				   cCbosSolAux = aIten[0];
			   }                    
			   
			   //--------------------------------------------------------------------
			   // Codigo e Nome do HOSPITAL SOLICITANTE								  
			   //--------------------------------------------------------------------
			   if (cNSol1 != "" && cPSol1 != "") {
				   setTC(document.getElementById("cNomeSolT"),"");
				   var e = document.getElementById("cNomeSolT");
				   e.options[0] = new Option(cNSol1, cPSol1);
				   alert(cPSol1)
				   cPSol1 = "";
				   cNSol1 = "";
			   }

		   }
	   }
   }
   
   //--------------------------------------------------------------------ÄÄ¿
   //Abre os grupos para evitar erro no carregamento dos grids.
   //--------------------------------------------------------------------ÄÄ¿	
   var aMatIteG = new Array()
   
   //--------------------------------------------------------------------ÄÄ¿
   // Monta o array com os itens do detalhe da solicitação de procedimento 
   //--------------------------------------------------------------------ÄÄÙ
   for (var i = 0; i < aMatIte.length; i++) {
	   //--------------------------------------------------------------------
	   // Matriz com os campos e valores SERVICO								  
	   //--------------------------------------------------------------------
	   if (aMatIte[i] != "") {
		   //--------------------------------------------------------------------ÄÄÄÄÄ¿
		   // Aprimeira posicao da matriz aMatval e o tipo de servico a segunda      		
		   // e se vai ser exibido ou nao da terceira em diante contem valores dos campos	
		   //--------------------------------------------------------------------ÄÄÄÄÄÙ
		   var aMatVal = aMatIte[i].split("@");
		   
		   for(var p = 0; p < aMatVal.length; p++) {
			   aNew = aMatVal[p].split("!");
			   
			   if(aNew[0] == "cDesPro")
				   aMatVal[p] = aNew[0] + "!"  + htmlDecode(aNew[1]);
		   }
		   
		   //--------------------------------------------------------------------Ä
		   // A segunda posicao [1] retorna se e possivel exibir para uma rda o procedimento  
		   //--------------------------------------------------------------------Ä
		   var cMostraSer = aMatVal[1].split("!")[1];
		   
		   if(aMatVal[26].split("!")[1] == 'S') //Se for pacote, exibe a mensagem.
			   alert('O pacote de codigo ' + aMatVal[3].split("!")[1] + ' possui procedimentos relacionados, os procedimentos serao carregados e devem compor a guia.');
			   
			 //--------------------------------------------------------------------ÄÄÄÄ¿
			 //aMatIteG
		   //Estrutura: Tipo - Array, Conteúdo - Linha do detalhe
		   //	Estrutura: Tipo - String, Conteúdo - Coluna do detalhe: Variavel_Protheus!Valor 
		   //	***Não necessáriamente a coluna existe no grid. Isso é validado posteriormente
			 //--------------------------------------------------------------------ÄÄÄÄÙ
		   aMatIteG.push(aMatVal)
	   }
   }
   
   if (aMatVal[0].split("!")[1] == "S"){        
	   //--------------------------------------------------------------------ÄÄÄÄ¿
	   //Chama a função que carrega os grids.
	   //Pede para a função preencher o grid de proc. Sol. "TabSolSer" e copiar os itens pro grid proc. Exec. "TabExeSer"
	   //--------------------------------------------------------------------ÄÄÄÄÙ
	   fCarregaTabela('TabSolSer$0|TabExeSer$1',aMatIteG,cMostraSer,"","cTpAteExe");
   }
   
   if(aCriticas.length > 0){
	   var cTexto = "<p>";
	   
	   for(var i=0; i<aCriticas.length;i++){
		   cTexto += aCriticas[i] + '<br>';
	   }
	   
	   cTexto += "</p>"
	   
	   modalBS('<i class="fa fa-exclamation-triangle" style="font-weight: bold; color: #000; text-shadow: 0 1px 0 #fff; filter: alpha(opacity=20); opacity: .2;"></i>&nbsp;&nbsp;&nbsp;Alerta', cTexto, "@OK~closeModalBS();", "white~ #f8c80a", "large","N");
   
   }

   //--------------------------------------------------------------------
   // Execucao															   
   //--------------------------------------------------------------------
   setDisable("cProExe",false);
   setDisable('bIncTabExe',false);
   setDisable("bSaveTabExe",false);
   setDisable("bSaveTabExeSer",true);
   
   //--------------------------------------------------------------------
   // Troca o tipo obrigatorio do campo									   
   //--------------------------------------------------------------------
   for(var i=0; i<oForm.campos.length; i++) {                                       
	   switch (oForm.campos[i].campo.id) {
	   case "cCarSolicit":
			   oForm.campos[i].branco = true;
			   break    
	   case "cProSol":
			   oForm.campos[i].branco = true;
			   break
	   case "cCbosExe":
			   oForm.campos[i].branco = true;
			   break
	   }
   }	             


   oForm.add( document.forms[0].cTpAteExe,"tudo", false, false ); //transformo os campos em obrigatorio
   document.forms[0].cTpAteExe.className ="form-control TextoInputOB";//transformo os campos em obrigatorio
   
   setDisable("bconfirma",false);
   setDisable("bcomplemento",true);
   setDisable("bimprimir",true);
   setDisable("bAnexoDoc",true);
   
   //Mantém o valor do campo RN na execução igual o da liberação.
   var cAtendRNHidden	= document.createElement('input');
   cAtendRNHidden.id	 	= 'cAtendRNHidden';
   cAtendRNHidden.name	 	= 'cAtendRNHidden';
   cAtendRNHidden.type 	= 'hidden';
   cAtendRNHidden.value 	= document.getElementById('cAtendRN').value;
   document.forms[0].appendChild(cAtendRNHidden);
   //--------------------------------------------------------------------
   // Dados da rda na execucao											   
   //--------------------------------------------------------------------
   if (document.getElementById("cRda").value != "" && document.getElementById("cCodLoc").value != "") {

	   fRda(document.getElementById("cRda").value,document.getElementById("cCodLoc").value)	
   }
   
   setTimeout(function(){
		   $("#cTpAteExe").focus();
	   }, 2000);

}

function CarregaProSaudeExe(v){
   var aResult = v.split("|");
   var cCombo	= aResult[0];
   var aCombo	= aResult[1].split("~");
   //--------------------------------------------------------------------
   // Alimenta o combo
   //--------------------------------------------------------------------
   if (document.getElementById(cCombo)[0] != undefined){

	   var e = document.getElementById(cCombo); 
	   
	   e.options[0] = new Option('-- Selecione um Executante --', '');
	   e.length=1	
	   for (var i = 1; i < aCombo.length; i++) {
		   var aProf = aCombo[i].split(";");
		   if (aProf.length>1 && aProf[1] != '')
			   e.options[i] = new Option(aProf[1], aProf[0]);
	   }
   }
}


//--------------------------------------------------------------------
function ProcForm() {
   fProcForm(FrmGuia);
}


//--------------------------------------------------------------------
// Processa 															  
//--------------------------------------------------------------------
function fProcForm(formulario) {
   var aMatAux2 = "";
   var lDigOff = false;
   var cMatAux = "";
   var cMatAux2 = "";
   var x = document.getElementById('cMsnBloInt').value;
   var cCbosSol = document.getElementById('cCbosSol')
	   
   if ( (document.getElementById('cNumInt').value == "") && x != "" ) {
	   alert('Informe a Guia Principal');
	   document.getElementById('cNumInt').focus();
	   return;
   } 

   //--------------------------------------------------------------------
   // Verfica se foi selecionado o código de ocupação							   
   //--------------------------------------------------------------------
   if(cCbosSol.options[cCbosSol.selectedIndex].text == ""){
	   cMsg = "Informe o Codigo da Ocupação";
	   document.getElementById('cCbosSol').focus();
	   ShowModal("Atenção", cMsg, false, false, false);
	   return;
	} 	
	
	//--------------------------------------------------------------------
	// Verfica se foi digitado algum procedimento							   
	//--------------------------------------------------------------------
	lVld = false;
   
   if (typeof oTabSolSer == "string" && typeof oTabExeSer == "string") {  
	   lVld = true;
	   cMsg = "Informe pelo menos um procedimento";
   } 
	   
   //--------------------------------------------------------------------
   // Validação do cAtendRN	(campo rescem nascido)								  
   //--------------------------------------------------------------------
   if(document.getElementById("cAtendRN").value == "SELECTED"){
	   lVld = true;
	   cMsg = "Informe no Dados do Beneficiário o campo RN ";
   } 	 	                                     
											  
   //Campos Tipo Atendimento e Indicação de Acidente obrigatórios na execução e na digitação off-line
   if (document.getElementById('cNumAut').value != "" || isDitacaoOffline()) {
	   if (document.getElementById('cTpAteExe').value == "") {
		   lVld = true;
		   cMsg = 'Informe o Tipo de Atendimento';
		   document.getElementById('cTpAteExe').focus();
	   }
	   if (document.getElementById('cIndAcid').value == "") {
		   lVld = true;
		   cMsg = 'Informe a Indicação de Acidente';
		   document.getElementById('cIndAcid').focus();
	   }
	   if (document.getElementById('cRegAtendim').value == "") {
			lVld = true;
			cMsg = 'Informe o Regime de Atendimento';
			document.getElementById('cRegAtendim').focus();
		}
   } 

   //--------------------------------------------------------------------
   // aviso																   
   //--------------------------------------------------------------------
   if (lVld) {
	   ShowModal("Atenção", cMsg, true, false, true);
	   return;
   }
   
   //--------------------------------------------------------------------
   // Valida indicacao clinica											   
   //--------------------------------------------------------------------
   if (document.getElementById("cIndCliSol").value == "") { 
	var aMatInd = document.getElementById("cCmpIndCli").value;
	var aMat = new Array(["TabSolSer",oTabSolSer],["TabExeSer",oTabExeSer]);
			
	var lachou  = false;
	for (var i=0;i<aMat.length;i++) {        
		aMatAux = aMat[i];
		//Se o grid foi preenchido
		if(typeof aMatAux[1] != "string"){
			//Recupera os dados do grid
			oTable = aMatAux[1].getObjCols();
			//Monta as colunas com a vari�vel do post
			fMontMatGer('A',aMatAux[0]);
			aMatCampAux = aMatCap.split("|");
			for (var y=0;y<oTable.rows.length;y++) {        
				for (var x=2;x<oTable.rows[y].cells.length-1;x++) {        
					if (aMatCampAux[x-2]) {
						 cCampo = aMatCampAux[x-2].split("$")[1];
					 }							  
					if (cCampo == 'cCodPro') {
						cConteudo = getTC(oTable.rows[y].cells[x+1]);
						if ( aMatInd.indexOf(cConteudo.replace(" ","") ) != -1) {
							for (var z=0; z<oForm.campos.length; z++) {
								if (oForm.campos[z].campo.id == "cIndCliSol") {
									oForm.campos[z].branco = false;
									lachou = true;
									break;
								}
							}   
						}
					}                   
				}	
			}
		}
	} 
}

   //--------------------------------------------------------------------
   // Valida tipo de consulta
   //--------------------------------------------------------------------
   if (document.getElementById("cNumAut").value != "" || isDitacaoOffline()) { 
	   
	   if (document.getElementById('cTpAteExe').value == "04" && document.getElementById("cTpCon").value == "") {
		   alert('Informe o campo Tp. Consulta.');
		   document.getElementById('cTpCon').focus();
		   return;
	   }						
   }

   //--------------------------------------------------------------------
   // Campos obrigatorios do ponto de entrada
   //--------------------------------------------------------------------
   var cCpsObr = document.getElementById("cCpsObr").value;
	   
   if (document.getElementById("cNumAut").value != "" && cCpsObr != "" && cCpsObr != "cCbosExe") {
	   oForm.add( document.getElementById(cCpsObr) ,"tudo", false, false );
   }

   //--------------------------------------------------------------------
   // ValiDa formulario													   
   //--------------------------------------------------------------------
   if( !valida() ) return;

   if (isDitacaoOffline())
   {	
	   lDigOff = true;
   } else {
	   
	   var objSol = document.getElementById("GrpDadSol");
	   
	   if(objSol != null){
	   
		   if (document.getElementById("cCarSol") == null ){
	   
			   var cCarSol	= document.createElement('input');
			   
			   cCarSol.id	 	= 'cCarSol';
			   cCarSol.type 	= 'hidden';
			   cCarSol.name 	= 'cCarSol';
			   cCarSol.value 	= document.getElementById("cCarSolicit").value;
			   
			   objSol.appendChild(cCarSol);	
		   }else{
			   document.getElementById("cCarSol").value = document.getElementById("cCarSolicit").value;
		   }
	   }
		   
	   document.forms[0].action = "W_PPLPROCGUI.APW";
   }


   //--------------------------------------------------------------------
   // Monta conteudo das tabelas	solicitacao e execucao					  
   //--------------------------------------------------------------------
   if(lDigOff){
	   aMatAux = ["TabExeSer",oTabExeSer];
	   aMatAux2 = ["TabExe",oTabExe];
   }else{
	   if (document.getElementById("cNumAut").value==""){
			aMatAux = ["TabSolSer",oTabSolSer];
	   }else{
		   aMatAux = ["TabExeSer",oTabExeSer];
		   aMatAux2 = ["TabExe",oTabExe];
	   }
   }
   
   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   aMat   		  = aMatAux;
   cStringEnvTab = "";
   
   for (var i = 0; i < aMat.length; i++) {
	aInfoAux = aMat
	if (typeof aInfoAux[i] != "undefined" && typeof aInfoAux[i] != "string" && aInfoAux[i].aCols.length > 0) {
		//Pega o nome do grid
		oTable = aInfoAux[1].getObjCols();
		//Associa a coluna com a vari�vel do post
		fMontMatGer('A', aInfoAux[0]);
		aMatCampAux = aMatCap.split("|");

		for (var y = 0; y < oTable.rows.length; y++) {
			nf = 0;
				
			cStringEnvTab += "cSeq@" + (++y) + "$";
			--y;
			
			 
			  for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {
				
				 if(aMatCampAux[x - 2]){
					 cCampo = aMatCampAux[x - 2].split("$")[1];		 
					 if (cCampo != "NIL" && aMatNGet.indexOf(cCampo) == -1) {
						 celula = oTable.rows[y].cells[x + 1 - nf];
	 
							 if (typeof celula.value == 'undefined' || celula.value == '')
								 conteudo = getTC(celula);
							 else
								 conteudo = celula.value;
	 
						 cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
					 }
				}

					if(aMatCampAux[x - 2]){
						if (aMatCampAux[x - 2].split("$")[0] == 'cfixo'){
							nf += 1;
						}	
					} 		  		
			  }
			  
			  cStringEnvTab += "|";
		}
	}
}
   
   document.getElementById("cMatTabES").value = cStringEnvTab + "|";

   //Monta variável do grid de executantes	
   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   if(aMatAux2 != ""){
	   aMat   		  = aMatAux2;
	   cStringEnvTab = "";
	   
	   for (var i = 0; i < aMat.length; i++) {

		   aInfoAux = aMat 
		   if ( typeof aInfoAux[i] != "undefined" && typeof aInfoAux[i] != "string" && aInfoAux[i].aCols.length > 0 ){ 
			   //Pega o nome do grid
			   oTable = aInfoAux[1].getObjCols();
			   //Associa a coluna com a variável do post
			   fMontMatGer('A', aInfoAux[0]);
			   aMatCampAux = aMatCap.split("|");    
			   
			   for (var y = 0; y < oTable.rows.length; y++) {
				   nf 	 = 0;
	   
				   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {						
					   cCampo = aMatCampAux[x - 2].split("$")[1];
				 
					   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
						   celula = oTable.rows[y].cells[x + 1 - nf];
						   
						   if (typeof celula.value == 'undefined' || celula.value == '')
							   conteudo = getTC(celula);
							else
								  conteudo = celula.value;
							   
						   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
					   }

						 if (aMatCampAux[x - 2].split("$")[0] == 'cfixo')
							nf += 1;
				   }
				   
				   cStringEnvTab += "|";
			   }
		   }			
	   }
   }
   
   document.getElementById("cMatTabExe").value = cStringEnvTab + "|";
   
   //--------------------------------------------------------------------
   // Trata campos														  
   //--------------------------------------------------------------------
   setDisable("cIndCliSol",false);
   setDisable("cCbosSol",false);
   setDisable("cCbosExe",false);
   setDisable("cProSolDesc",false);
   setDisable("cProExeDesc",false);
   setDisable("bconfirma",true);
   setDisable("bcomplemento",false);
   setDisable("bAnexoDoc",false);

   if (isDitacaoOffline()){
	   setDisable("bimprimir",true);
   }else{
	   setDisable("bimprimir",false);
   }

   if(!lDigOff){
	   Ajax.send(formulario, { 
			   callback: CarregaProcForm,
			   error: ExibeErro 
	   });
   }else{
	   modalBS('<i class="fa fa-exclamation-triangle" style="font-weight: bold; color: #000; text-shadow: 0 1px 0 #fff; filter: alpha(opacity=20); opacity: .2;"></i>&nbsp;&nbsp;&nbsp;Alerta', '<p>Tem certeza que deseja finalizar a guia?</p>', "@Sim, conclui a digitação!~confirmaSADT('1')@Não, desejo continuar posteriormente!~confirmaSADT('2');", "white~ #f8c80a", "large","N");	
   }

   document.forms[0].action = "";
   
   if( isDitacaoOffline() && isAlteraGuiaAut() ){
	   document.getElementById("bconfirma").disabled = true;
   }
   
   //--------------------------------------------------------------------
   // Desabilita os campos												  
   //--------------------------------------------------------------------
   FDisElemen('TabExeSer|bIncTabExeSer|bSaveTabExeSer',true);
}

//--------------------------------------------------------------------
// Pega o retorno do processamento										  
//--------------------------------------------------------------------
function CarregaProcForm(v) {
   var aResult = v.split("|");
   var cSenha  = "";
   var cTexto  = aResult[10]; //Procedimento autorizados ou negados resultado
   var cTitulo = aResult[11]; //Titulo do resultado autorizado,negado ou autorizado parcial
   var cMostra = aResult[12];
   var cAutori = aResult[0];        
   var lLibera = false; 
	  
	if (cMostra == "SIM") {
	   if (confirm("A paciente é gestante?"))
		 { Ajax.open("W_PPLPROCBD5.APW?cNumAut=" + cAutori,  true) }
		 
	 }  
	

   //--------------------------------------------------------------------
   // Informacoes	da autorizacao											  
   //--------------------------------------------------------------------
   if (aResult[0] != ""){
	  if(document.getElementById("cNumAut") != undefined){
		  lLibera = document.getElementById("cNumAut").value == ""
		  document.getElementById("cNumAut").value = aResult[0].substr(0, 4) + "." + aResult[0].substr(4, 4) + "." + aResult[0].substr(8, 2) + "-" + aResult[0].substr(10, 8); //Numero da autorizacao
	  }else{
		  window.frames[0].document.getElementById("cNumAut").value = aResult[0].substr(0,4)+"."+aResult[0].substr(4,4)+"."+aResult[0].substr(8,2)+"-"+aResult[0].substr(10,8);//Numero da autorizacao
		  lLibera = window.frames[0].document.getElementById("cNumAut").value == ""
	   }
   }
   //--------------------------------------------------------------------
   // Implementa Senha na exibicao										  
   //--------------------------------------------------------------------
   if (aResult[1] != "") cSenha = "<br/> Senha: " + aResult[1];
   //--------------------------------------------------------------------
   // Alimenta campos														  
   //--------------------------------------------------------------------
   
   if(document.getElementById("cSenha") != undefined)
   document.getElementById("cSenha").value = aResult[1];   //Senha
   else
	  window.frames[0].document.getElementById("cSenha").value = aResult[1];   //Senha

   if(document.getElementById("dDtAut") != undefined)
   document.getElementById("dDtAut").value = aResult[2];   //Data da Autorizacao
   else
	  window.frames[0].document.getElementById("dDtAut").value = aResult[2];   //Data da Autorizacao

   if(document.getElementById("dDtValid") != undefined)
   document.getElementById("dDtValid").value = aResult[3]; //Validade da Senha
   else
	  window.frames[0].document.getElementById("dDtValid").value = aResult[3]; //Validade da Senha
	  
   //--------------------------------------------------------------------
   // Para mostrar o numero da autorizacao								  
   //--------------------------------------------------------------------
   if(document.getElementById("cNumAut") != undefined){
   if (cTexto == "") {
	   cTexto = "<center>" + document.getElementById("cNumAut").value + cSenha + "</center>";
   } else {
	   cTexto = "<center>" + document.getElementById("cNumAut").value + cSenha + "</center><br>" + cTexto;
   }
   }else{
	   if (cTexto == "") {
		   cTexto = "<center>" + window.frames[0].document.getElementById("cNumAut").value + cSenha + "</center>";
	   } else {
		   cTexto = "<center>" + window.frames[0].document.getElementById("cNumAut").value + cSenha + "</center><br>" + cTexto;
	   }
   }
   //--------------------------------------------------------------------
   // Mostra o resultado modal											  
   //--------------------------------------------------------------------

   if (aResult[16] == "true") {
		cFechar = "HideModal();";

    	anexoDocGui(aResult[0], cTp.value, false);

		if (lLibera){
			cFechar += "@Executar Guia~ExecGuia('"+cBtnExec+"')";
		}
		ShowModal(cTitulo, cTexto, false, false, false, cFechar);
   }else{

	if ( aResult[14] == "true") {
		cFechar = "ChamaAnexRad('"+cAutori+"')"
	}else{
		cFechar = "HideModal();"
		if(wasDef( typeof cTp) && (cTp.value == 1 || cTp.value == 2 || cTp.value == 3 || cTp.value == 7 || cTp.value == 8 || cTp.value == 9 || cTp.value == 11 )){
			cFechar += "@Anexar Documentos~anexoDocGui('" + aResult[0] + "')";
		}
		if (lLibera){
			cFechar += "@Executar Guia~ExecGuia('"+cBtnExec+"')";
		}
		ShowModal(cTitulo, cTexto, false, false, false, cFechar);
	}

	//cTitulo,cTexto,lS,lOld,lAlt,cPlusFunc
	if ( (document.getElementById("cNumAut") != undefined) && (document.getElementById("cNumAut") != null) ){
		document.getElementById("cNumAut").readOnly = true;
	}
   }
}  

function ChamaAnexRad(cAutori){
   HideModal()
   cTexto = "A Guia possui procedimentos de Radioterapia.\nDeseja digitar a guia de Anexo de Radioterapia para complementar as informações do tratamento?"
   if (confirm(cTexto)){ 
	   window.frames[0].location="W_PPLANRAD.APW?cNumAut=" + cAutori 
   }
}

function ExecGuia(cBtn){
   closeModalBS();
   HideModal();
   window.frames[0].document.getElementById(cBtn).onclick();
   $("html, body").animate({ scrollTop: $("#"+cBtnExec).scrollTop() }, 1000);
   
}

//--------------------------------------------------------------------
// Monta campos conforme processamento da rdas							  
//--------------------------------------------------------------------
function CarregaRda(v) {
   var aResult = v.split("|");
   var aResuEsp = (aResult[24].substring(1)).split("~");
   var lIsDigOffline = isDitacaoOffline();
   var aProsol  = aResult[19].split("@");

   //--------------------------------------------------------------------
   // Prepara para desabilitar solicitacao ou execucao					  
   //--------------------------------------------------------------------
   lSolicitacao = ($("#cNumAut").val() == "" && !lIsDigOffline); 

   //--------------------------------------------------------------------
   // Local de atendimento												  
   //--------------------------------------------------------------------
   document.getElementById("cCodLoc").value = aResult[22];

   //--------------------------------------------------------------------
   // Dados da Autorizacao de Solicitaca
   //itena abaixo estava zerando os campos de cabeçalho									   
   //--------------------------------------------------------------------
   //document.getElementById("dDtAut").value			= "";
   //document.getElementById("cSenha").value			= "";
   //document.getElementById("dDtValid").value		= "";

   

   //--------------------------------------------------------------------
   // Se e fisica ou juridica												   
   //--------------------------------------------------------------------
   if(lSolicitacao){


		//--------------------------------------------------------------------
   		// Dados do Solicitante												   
   	   //--------------------------------------------------------------------
   	   document.getElementById("cRegAns").value		= aResult[1];
   	   document.getElementById("cCnpjCpfSol").value	= aResult[2];
   	   document.getElementById("cNomeRdaSol").value = aResult[3];
   	   if (aResult[14].toUpperCase() == 'F') {
			if(aProsol[1]!= undefined && aProsol[1].trim() != "") {
				document.getElementById("cProSol").value = aProsol[1];
				document.getElementById("cProSolDesc").value = aProsol[0];
			}
	   }
   	   document.getElementById("cTpPe").value 			= aResult[14];

	   document.getElementById("cNomeRdaSol").value 	= aResult[3];
	   document.getElementById("cCodSigSol").value	= aResult[16];
	   document.getElementById("cNumCrSol").value 	= aResult[17];
	   document.getElementById("cEstSigSol").value	= aResult[18];
	   
	   //--------------------------------------------------------------------
	   // Monta especialidades												   
	   //--------------------------------------------------------------------
	   setTC(document.getElementById("cCbosSol"),"");

	   var e = document.getElementById("cCbosSol");
	   for (var i = 0; i < aResuEsp.length; i++) {
		   var aIten = aResuEsp[i].split("$");
		   e.options[i] = new Option(aIten[1], aIten[0]);
	   }
   }	

   //--------------------------------------------------------------------
   // Se e fisica ou juridica												   
   //--------------------------------------------------------------------
   if (aResult[14].toUpperCase() == 'F') {
	   setDisable('BIncSol',true);
	   setDisable('BHelp16',true);
	   setDisable('BHelp41',true);
   } else {
	   setDisable('BIncSol',false);
	   setDisable('BHelp16',false);
	   setDisable('BHelp41',false);
   }

   //Se for digitação offline
   if (!lSolicitacao || lIsDigOffline){

	   //Inicia Grupo de Solicitação desabilitado
	   $('#GrpSolSer').slideUp();
	   
	    //--------------------------------------------------------------------
	   // Dados do Solicitante											   
	   //--------------------------------------------------------------------
		document.getElementById("cRegAns").value		= aResult[1];
		document.getElementById("cCnpjCpfSol").value	= aResult[2];
		document.getElementById("cNomeRdaSol").value = aResult[3];
		if(aResult[16] !== "") {
			document.getElementById("cCodSigSol").value	= aResult[16];
			document.getElementById("cNumCrSol").value 	= aResult[17];
			document.getElementById("cEstSigSol").value	= aResult[18];
		}
	   
		//--------------------------------------------------------------------
		// Monta especialidades do Solicitante												   
		//--------------------------------------------------------------------
		setTC(document.getElementById("cCbosSol"),"");

		var e = document.getElementById("cCbosSol");
		for (var i = 0; i < aResuEsp.length; i++) {
			var aIten = aResuEsp[i].split("$");
			e.options[i] = new Option(aIten[1], aIten[0]);
		}
		
		if ( typeof(cCbosSolAux) != 'undefined' ) {
			if(e.options.length > 1) {
				if (cCbosSolAux !== '' && cCbosSolAux.length == e.options[1].value.length) {
					document.getElementById("cCbosSol").value = cCbosSolAux;
				} else if (cCbosSolAux !== '' && e.options[1].value.length == '3') {
					document.getElementById("cCbosSol").value = cCbosSolAux.substr(0,3)
				}
			}
		}
	   
	   //--------------------------------------------------------------------
	   // Dados do Executante  												   
	   //--------------------------------------------------------------------
	   document.getElementById("cCnpjCpfExe").value	= aResult[2];
	   document.getElementById("cNomeRdaExe").value 	= aResult[3];
	   document.getElementById("cCnesExe").value 		= aResult[4];
	   document.getElementById("cTpPe").value 			= aResult[14];

	   //document.getElementById("dDtSolicit").value		= "";

	   //--------------------------------------------------------------------
	   // Se e fisica ou juridica												   
	   //--------------------------------------------------------------------
		  if (document.getElementById("cProSol") != null){
		   if (lIsDigOffline) {
			   //Verifica se o campo profissional solicitante é texto ou combo
			   if (document.getElementById("cProSol")[0] == undefined){
				   if(aProsol[1] != undefined && aProsol[1].trim() != ""){
					   document.getElementById("cProSol").value = aProsol[1];
					   document.getElementById("cProSolDesc").value = aProsol[0];
				   }
			   }else{
				   document.getElementById("cProSol")[0].value = aProsol[0];
			   }
		   }else {
			   if (typeof document.getElementById("cNomeSol") == "undefined" || document.getElementById("cNomeSol").value == ""){					
				   if (document.getElementById("cProSol").type == "hidden"){
					   //Se for hidden, atribui o código do profissional solicitante ao campo hidden e a descrição ao campo desc
					   document.getElementById("cProSol").value = aResult[17];
					   document.getElementById("cProSolDesc").value = aResult[19];
				   }else{
					   document.getElementById("cProSol")[0].value = aResult[19];
				   }
			   }
		   }
	   }
	   if (aResult[14].toUpperCase() == 'F') {
		   document.getElementById("cCodSigExe").value	= aResult[16];
		   document.getElementById("cNumCrExe").value 	= aResult[17];
		   document.getElementById("cEstSigExe").value	= aResult[18];
			  document.getElementById("cCpfExe").value 	= aResult[20];
	   }

	   //--------------------------------------------------------------------
	   // CBOS																   
	   //--------------------------------------------------------------------

	   //Se está aqui, então é execução e já haverá o profissional preenchido
	   //Por isso damos o Disable
	   setDisable('BIncSol',false);
	   setDisable('BHelp16',false);
	   setDisable('BHelp41',false);

	   if (aResult[16] !== "") {
			Ajax.open("W_PPLPROSAUD.APW?cCombo=cProExe&cRda=" + document.getElementById("cRda").value +"&cCodLoc="+ document.getElementById("cCodLoc").value , {
					callback: CarregaProSaudeExe,
					error: ExibeErro,
					showProc: false
			});
		}
   }
   
   //--------------------------------------------------------------------
   // Ajusta o compo do executante e formata a tela para a solicitacao	   
   //--------------------------------------------------------------------
   fAjusForm(lSolicitacao);
   
}

//--------------------------------------------------------------------
// Monta campos conforme processamento da rdas							  
//--------------------------------------------------------------------
function CarregaRdaOffline(v) {
   var aResult = v.split("|");
   var aResuEsp = (aResult[24].substring(1)).split("~");
   var aProsol  = aResult[19].split("@");
	  //--------------------------------------------------------------------
   // Solicitacao															   
   //--------------------------------------------------------------------
   //--------------------------------------------------------------------
   // Dados da Autorizacao de Solicitacao									   
   //--------------------------------------------------------------------
   document.getElementById("dDtAut").value			= "";
   document.getElementById("cSenha").value			= "";
   document.getElementById("dDtValid").value		= "";
   document.getElementById("dDtSolicit").value		= "";
   
   //Inicia Grupo de Solicitação desabilitado
   toggleDiv('GrpSolSer');

   //--------------------------------------------------------------------
   // Dados do Solicitante												   
   //--------------------------------------------------------------------
   document.getElementById("cRegAns").value		= aResult[1];
   document.getElementById("cCnpjCpfSol").value	= aResult[2];
   document.getElementById("cNomeRdaSol").value 	= aResult[3];

   document.getElementById("cTpPe").value 			= aResult[14];

   //--------------------------------------------------------------------
   // Se e fisica ou juridica												   
   //--------------------------------------------------------------------
	  document.getElementById("cNomeRdaSol").value 	= aResult[3];
   document.getElementById("cCodSigSol").value	= aResult[16];
   document.getElementById("cNumCrSol").value 	= aResult[17];
   document.getElementById("cEstSigSol").value	= aResult[18];
   //--------------------------------------------------------------------
   // Monta especialidades												   
   //--------------------------------------------------------------------
   setTC(document.getElementById("cCbosSol"),"");

   var e = document.getElementById("cCbosSol");
   for (var i = 0; i < aResuEsp.length; i++) {
	   var aIten = aResuEsp[i].split("$");
	   e.options[i] = new Option(aIten[1], aIten[0]);
   }

   if (aResult[14].toUpperCase() == 'F') {
   //	setDisable("cProSol",true);
	   setDisable('BIncSol',true);
	   setDisable('BHelp16',true);
	   setDisable('BHelp41',true);
   } else {
   //	setDisable("cProSol",false);
	   setDisable('BIncSol',false);
	   setDisable('BHelp16',false);
	   setDisable('BHelp41',false);
   }
   
   //--------------------------------------------------------------------
   // Local de atendimento												  
   //--------------------------------------------------------------------
   document.getElementById("cCodLoc").value = aResult[22];

   //--------------------------------------------------------------------
   // Dados do Executante  												   
   //--------------------------------------------------------------------
   document.getElementById("cCnpjCpfExe").value	= aResult[2];
   document.getElementById("cNomeRdaExe").value 	= aResult[3];
   document.getElementById("cCnesExe").value 		= aResult[4];
   document.getElementById("cTpPe").value 			= aResult[14];
   //--------------------------------------------------------------------
   // Se e fisica ou juridica												   
   //--------------------------------------------------------------------
   //Verifica se o campo profissional solicitante é texto ou combo
   if (document.getElementById("cProSol")[0] == undefined){
	   if(aProsol[1] != undefined && aProsol[1].trim() != ""){
	   document.getElementById("cProSol").value = aProsol[1];
	   document.getElementById("cProSolDesc").value = aProsol[0];
	   }

   }else if(document.getElementById("cProSol") != null){
	   document.getElementById("cProSol")[0].value = aProsol[0];
   }
		  
   if (aResult[14].toUpperCase() == 'F') {
	   document.getElementById("cCodSigExe").value	= aResult[16];
	   document.getElementById("cNumCrExe").value 	= aResult[17];
	   document.getElementById("cEstSigExe").value	= aResult[18];
		  document.getElementById("cCpfExe").value 	= aResult[20];
   }

   setDisable('BIncSol',false);
   setDisable('BHelp16',false);
   setDisable('BHelp41',false);

   Ajax.open("W_PPLPROSAUD.APW?cCombo=cProExe&cRda=" + document.getElementById("cRda").value +"&cCodLoc="+ document.getElementById("cCodLoc").value , {
		   callback: CarregaProSaudeExe,
		   error: ExibeErro,
		   showProc: false
   });

   //--------------------------------------------------------------------
   // Ajusta o compo do executante e formata a tela para a solicitacao	   
   //--------------------------------------------------------------------
   fAjusForm(false);
}

//--------------------------------------------------------------------
// Carrega campos conforme processamento Profissional de saude			  
//--------------------------------------------------------------------
function CarregaProSaudeFil(v) {
   var aResult = v.split("|");   
   //--------------------------------------------------------------------
   // Verfiica se e solicitacao ou execucao
   //--------------------------------------------------------------------
   if (cTpProfG == "S") {
   
	   setTC(document.getElementById("cProSol"),"");
	   var e = document.getElementById("cProSol");
	   
   } else {
   
	   setTC(document.getElementById("cProExe"),"");
	   var e = document.getElementById("cProExe");      
	   
   }
   //--------------------------------------------------------------------
   // Alimenta o combo
   //--------------------------------------------------------------------
   
   if (LastkeyID == 46){
	   e.options[0] = new Option('-- Selecione um '+cTexto+' --', '');
	   j = 1;
   } 
   for (i; i < aResult.length; i++) {
	   var aProf = aResult[i].split("%");
	   if (aProf.length>1 && aProf[1] != '')
		   e.options[i+j] = new Option(aProf[1], aProf[0]);
		   if (aProf[0]!=''){
			   lEntrou = true;
		   }
   } 	
   if (!lEntrou){
	   e.options[0] = new Option('-- ['+cString+'] nao localizado --', '');
   }	
   if (cProfAntG != e.value) {
	   cProfAntG = e.value;
	   fProfSau(e.value,cTpProfG);
   }
}     

//--------------------------------------------------------------------
// Limpa variavel BackSpace ou Delete - chamado no keydown
//--------------------------------------------------------------------
function fProfSauClear(e,cTpProf) {
   var keyID = (window.event) ? e.keyCode : e.which;
   //--------------------------------------------------------------------
   // BackSpace e Delete etc nao sao capturadas pelo keypress
   // por isso o tratamento desta forma. quando for backspace tem que retornar
   // false para nao retornar a pagina anterior.
   //--------------------------------------------------------------------
   lVld = (keyID >=64 && keyID <=93 || keyID >=97 && keyID <=125 || keyID >=48 && keyID <=62 || keyID == 95 || keyID == 8 || keyID == 46 || keyID == 32)
   if (lVld)  {
	   fProfSauFil(e,cTpProf);                         
	   return (keyID == 8) ? false : true;
   }
}
//--------------------------------------------------------------------
// Busca lookup (filtrado) - chamado no keypress
//--------------------------------------------------------------------
function fProfSauFil(e,cTpProf) {
   cTpProfG    = cTpProf
var cRda 	= document.getElementById("cRda").value;
   var cCodLoc = document.getElementById("cCodLoc").value;
   var keyID 	= (window.event) ? e.keyCode : e.which;
   //--------------------------------------------------------------------
   // Tratamento quando for backspace ou delete desviado pela fProfSauClear
   //--------------------------------------------------------------------
   if (keyID == 8) {
   cBusca = cBusca.substr(0,cBusca.length-1);
   } else if (keyID == 46) {
   cBusca = "";         
   } else {
	   cBusca = cBusca + String.fromCharCode(keyID);
   }
//--------------------------------------------------------------------
// Executa o metodo													  
//--------------------------------------------------------------------
Ajax.open("W_PPLATUPRO.APW?cBusca=" + cBusca + "&cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
   callback: CarregaProSaudeFil, 
   error: ExibeErro,
   showProc: false  
});
//--------------------------------------------------------------------
// Se nao for digitado nada no tempo abaixo limpa a string 30 segundos
//--------------------------------------------------------------------
clearTimeout(cTimeOut);
cTimeOut = setTimeout("fProfSauRestart()", 30000);
}

function fProfSau(cProSaud, cTpProf) {
   cTpPrestador = cTpProf;   
   cCodCbo = wasDef( typeof(cCodCbos) ) && (cCodCbos.trim() != "" );
   var cMatric = parent.frames['principal'].document.forms[0]["cNumeCart"].value;
   var cCodLoc = parent.frames['principal'].document.forms[0]["cCodLoc"].value;
   var cRda = parent.frames['principal'].document.forms[0]["cRda"].value;
   //--------------------------------------------------------------------
   // Executa o metodo													  
   //--------------------------------------------------------------------
   Ajax.open("W_PPCBOSPSAU.APW?cProSaud=" + cProSaud + "&cMatric=" + cMatric + "&cRda=" +cRda+ "&cCodLoc=" +cCodLoc+"&cTpProf="+cTpProf, {
	   callback: CarregaProSaude, 
	   error: ExibeErro,
	   showProc: false 
   });
}                 

function CarrEspAnt(v){
   var aResult = v.split("|");
   var aResuEsp = (aResult[24].substring(1)).split("~");
   lHab = (parent.window[0].document.getElementById("cNumAut").value == "" || parent.window[0].document.getElementById("cTipoOrigem").value != ""); 
   if (lHab) {
	   //--------------------------------------------------------------------
	   // Monta especialidades												   
	   //--------------------------------------------------------------------
	   setTC(parent.window[0].document.getElementById("cCbosSol"),"");
   
	   var e = parent.window[0].document.getElementById("cCbosSol");
	   for (var i = 0; i < aResuEsp.length; i++) {
		   var aIten = aResuEsp[i].split("$");
		   e.options[i] = new Option(aIten[1], aIten[0]);
	   }
	   
	   if (e.options.length > 0){
		   e.selectedIndex = 1;
	   }
   }
   // Recupero os posicionamento da combo que pode ter perdido a referência com o ajax
   if ( typeof(cIndCombo) != 'undefined' ) {
	   if (cIndCombo != ""){
		   aIndCombo = cIndCombo.split("|");
		   
		   for(var i=0; i < aIndCombo.length; i++) {
			  if (aIndCombo[i].trim() != ""){
				   var aCmbAtu = aIndCombo[i].split(";"); 
				   $('#' + aCmbAtu[0] + ' option[value^="' + aCmbAtu[1] + '"]').prop('selected', true); 
			  }
		   }   				
	   }
   }
}

function CarrEspAntExe(v){
   var aResult = v.split("|");
   var aResuEsp = (aResult[24].substring(1)).split("~");
   //--------------------------------------------------------------------
   // Monta especialidades												   
   //--------------------------------------------------------------------
   setTC(parent.window[0].document.getElementById("cCbosExe"),"");
   var e = parent.window[0].document.getElementById("cCbosExe");
   for (var i = 0; i < aResuEsp.length; i++) {
	   var aIten = aResuEsp[i].split("$");
	   e.options[i] = new Option(aIten[1], aIten[0]);
   }
   
   if (e.options.length > 0){
	   e.selectedIndex = 1;
   }
}
//--------------------------------------------------------------------
// Carrega campos conforme processamento Profissional de saude			  
//--------------------------------------------------------------------
function CarregaProSaude(v) {
   var aResult = v.split("|");
   var cBkpEsp = '';
   var nIndCmb = -1;

   if ( typeof(cTpPrestador) != 'undefined' ) {
	   //--------------------------------------------------------------------
	   // alimenta variaveis													  
	   //--------------------------------------------------------------------
	   if (cTpPrestador == "S") {
			   if (parent.window.frames['principal'].document.getElementById("cCodSigSol") != undefined) {
				   parent.window.frames['principal'].document.getElementById("cCodSigSol").value = aResult[0];
			   }
			   parent.window.frames['principal'].document.getElementById("cNumCrSol").value	= aResult[1];
			   parent.window.frames['principal'].document.getElementById("cEstSigSol").value	= aResult[2];
			   
			   //O índice 6 do array contém as especialidades do profissional
			   if (aResult.length >= 6){
				   if ( typeof(aResult[6]) != 'undefined' ) {
						setTC(parent.window.frames['principal'].document.getElementById("cCbosSol"),"");			
					   var aEspeci = aResult[6].split('$');		
	   
					   var e = parent.window.frames['principal'].document.getElementById("cCbosSol");
					   for (var i = 0; i < aEspeci.length; i++) {
						   var aIten = aEspeci[i].split("#");
						   if (aIten[0] != '') {                  
							   e.options[i] = new Option(aIten[1], aIten[0]);
							}	
					   }

					   // Recupero os posicionamento da combo que pode ter perdido a referência com o ajax
					   if ( typeof(cIndCombo) != 'undefined' ) {
						   if (cIndCombo != ""){
							   aIndCombo = cIndCombo.split("|");
							   
							   for(var i=0; i < aIndCombo.length; i++) {
								  if (aIndCombo[i].trim() != ""){
									   var aCmbAtu = aIndCombo[i].split(";"); 
									   $('#' + aCmbAtu[0] + ' option[value^="' + aCmbAtu[1] + '"]', parent.window.frames['principal'].document).prop('selected', true); 
								  }
							   }   				
						   }
					   }
					   
					   if (e.options.length > 0 && aCmbAtu[1] <= 0){
						   e.selectedIndex = 1;
					   }

				   }else{    
					   //Caso não seja encontrada as especialidades para o prestador, busca as especialidades para a RDA
					   var cRda 	= parent.window.frames['principal'].document.getElementById("cRda").value;
					   var cCodLoc = parent.window.frames['principal'].document.getElementById("cCodLoc").value;
					   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
						   callback: CarrEspAnt, 
						   error: ExibeErro
					   });    
				   }
			   }else{       
					   //Caso não seja encontrada as especialidades para o prestador, busca as especialidades para a RDA
					   var cRda 	= parent.window.frames['principal'].document.getElementById("cRda").value;
					   var cCodLoc = parent.window.frames['principal'].document.getElementById("cCodLoc").value;
					   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
						   callback: CarrEspAnt, 
						   error: ExibeErro
					   });    
			   }
							  
	   } else {
			   if (parent.window.frames['principal'].document.getElementById("cCodSigExe") != undefined) {
				   parent.window.frames['principal'].document.getElementById("cCodSigExe").value = aResult[0];
			   }
			   parent.window.frames['principal'].document.getElementById("cNumCrExe").value	= aResult[1];
			   parent.window.frames['principal'].document.getElementById("cEstSigExe").value	= aResult[2];
				  if (parent.window.frames['principal'].document.getElementById("cCpfExe") != null) {
					  parent.window.frames['principal'].document.getElementById("cCpfExe").value	= aResult[4];
			   }
			   if (aResult.length >= 6){			    
				   if ( typeof(aResult[6]) != 'undefined' ) {
					   if (isDitacaoOffline() && isAlteraGuiaAut() && (parent.window.frames['principal'].document.getElementById("cCbosExe").value != '' || (typeof(cCdEspResInt) != 'undefined' && cCdEspResInt != '')) ){ 
						   cBkpEsp = parent.window.frames['principal'].document.getElementById("cCbosExe").value != '' ? parent.window.frames['principal'].document.getElementById("cCbosExe").value : cCdEspResInt;
					   }
						setTC(parent.window.frames['principal'].document.getElementById("cCbosExe"),"");			
					   var aEspeci = aResult[6].split('$');		
					   
					   var e = parent.window.frames['principal'].document.getElementById("cCbosExe");
					   for (var i = 0; i < aEspeci.length; i++) {
						   var aIten = aEspeci[i].split("#");
						   if (aIten[0] != '') {                  
							   e.options[i] = new Option(aIten[1], aIten[0]);
							   if (cBkpEsp != '' && cBkpEsp == aIten[0]) {
								   nIndCmb = i;
							   }
							}	
						   
						   if((typeof parent.window.frames[0].document.forms[0].tmpCboHidden == "object") && aIten[0] == parent.window.frames[0].document.forms[0].tmpCboHidden.value){
							   e.options[i].selected = true;
							   parent.window.frames[0].document.forms[0].tmpCboHidden.remove();
						   }
					   }

					   // Recupero os posicionamento da combo que pode ter perdido a referência com o ajax
					   if ( typeof(cIndCombo) != 'undefined' ) {
						   if (cIndCombo != ""){
							   aIndCombo = cIndCombo.split("|");
							   
							   for(var i=0; i < aIndCombo.length; i++) {
								  if (aIndCombo[i].trim() != ""){
									   var aCmbAtu = aIndCombo[i].split(";"); 
									   $('#' + aCmbAtu[0] + ' option[value^="' + aCmbAtu[1] + '"]', parent.window.frames['principal'].document).prop('selected', true); 
								  }
							   }   				
						   }
					   }
					   
					   if (e.options.length > 0 && nIndCmb == -1 ){
						   e.selectedIndex = 1;
					   } else {
						   e.selectedIndex = nIndCmb;
						   cCdEspResInt = '';
					   }
				   }else{        
					   var cRda 	= parent.window.frames['principal'].document.getElementById("cRda").value;
					   var cCodLoc = parent.window.frames['principal'].document.getElementById("cCodLoc").value;
					   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
						   callback: CarrEspAntExe, 
						   error: ExibeErro
					   });    
				   }
			   }else{        
					   var cRda 	= parent.window.frames['principal'].document.getElementById("cRda").value;
					   var cCodLoc = parent.window.frames['principal'].document.getElementById("cCodLoc").value;
					   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
						   callback: CarrEspAntExe, 
						   error: ExibeErro
					   });    
				   }
	   }                                   
   }       
	  
}                       
//--------------------------------------------------------------------
// Checa se o procedimento e valido									  
//--------------------------------------------------------------------
function fChkCodPro(cCmpPad,cCmpPro,cCmpDesc,cTpProc, cCmpMatric, cCmpRda) { 
   cCampoRef 	 = cCmpPro;                 
   cRda = '';
   if (cCmpDesc != '') {
	   cCampoRefDes = cCmpDesc;
	   document.getElementById(cCmpDesc).value = "";
   }    

   cCodPad = document.getElementById(cCmpPad).value;
   cCodPro = document.getElementById(cCmpPro).value;
   cMatric = document.getElementById(cCmpMatric).value;
   if  (document.getElementById(cCmpRda) != null){
	   cRda = document.getElementById(cCmpRda).value;
   }
   

   if (cCodPad == "" && cCodPro != "") {
	   alert("Informe o Código da tabela");
	   document.getElementById(cCmpPad).focus();
	   return false;
   }                    

   if (cCodPro == "") return true;
   
   Ajax.open("W_PPLSCHKSER.APW?cCodPadPro=" + ( cCodPad + cCodPro ) + "&cTpProc=" + cTpProc + "&cMatric=" + cMatric + "&cRda=" + cRda, { 
			   callback: CarregaDeskPro, 
	   error: ExibeErro 
   });			
}                               

//--------------------------------------------------------------------
// Mostra a descricao do procedimento									  
//--------------------------------------------------------------------
function CarregaDeskPro(v) {
   var aResult = v.split("|");
   
   if(typeof cCampoRefDes != 'undefined') document.getElementById(cCampoRefDes).value = aResult[0];
   document.getElementById(cCampoRefDes).value = document.getElementById(cCampoRefDes).value.replace( /\?/, "" );
   //--------------------------------------------------------------------
   // Tratamento para indicação clinica									   
   //--------------------------------------------------------------------
   if (document.getElementById("cCmpIndCli") != null){
	   if (aResult[1]=='1') document.getElementById("cCmpIndCli").value += cCodPro+"~";
   }
   if (aResult[5] == "forbla") {
	   alert(aResult[6]);
   }
}

//--------------------------------------------------------------------
//  fChkQtdPro    Data   01/10/13  
//Desc.      Valida a exibição do lembrete do procedimento com base     
//               na quantidade solicitada.        
//--------------------------------------------------------------------		
function fChkQtdPro(cCodPad,cCodPro,nQtdPro) {  

var cCodPad = document.getElementById(cCodPad).value;
var cCodPro = document.getElementById(cCodPro).value;
var nQtdPro = document.getElementById(nQtdPro).value; 
	   Ajax.open("W_PPLSQTD.APW?cCodPad=" + cCodPad  + "&cCodPro=" + cCodPro + "&nQtdPro=" + nQtdPro, {  
	   callback: CarregaQTD, 
	   error: ExibeErro 
   });
} 

//--------------------------------------------------------------------
// Exibe a tela de lembrete do procedimento.							  
//--------------------------------------------------------------------  
function CarregaQTD(v) {  

var aResult = {}
   if (v != null){
	   aResult = v.split("|");  
	   alert(aResult[1]); 
   }
}
//--------------------------------------------------------------------
// Checa se o cid e valido												   
//--------------------------------------------------------------------
function fChkCid(ref) {           
   if (ref.value == "") return true;
   cCampoRef = ref.name;
   Ajax.open("W_PPLSCHKCID.APW?cCampoRef="+cCampoRef+"&cChkCid="+ref.value, {callback: AtuTip, error: ExibeErro} );
}
//--------------------------------------------------------------------
// Checa se o o dado preenchido eh valido								   
//--------------------------------------------------------------------
function fChkBTQ(ref,cTab,cCheckDePara) {           
   
   //sem valor no campo, o atributo title é removido e o objeto tooltip destruido.
   if (ref.value == "") { 
	   document.getElementById(ref.id).removeAttribute('title');
	   $(document.getElementById(ref.id)).tooltip();
	   $(document.getElementById(ref.id)).tooltip("destroy");
	   return true;
   } 
   
   cCampoRef = ref.name;
   //-----set atrbute                         
   //este parametro aqui serve para indicar que alem de checar se o dado existe devemos checar se o cliente parametrizou o de-para dele
   if (cCheckDePara != null) {
	   Ajax.open("W_PPLSCBTQ.APW?cCampoRef="+cCampoRef+"&cChkCpo="+ref.value+"&cTab="+cTab+"&cCheckDePara="+cCheckDePara, {callback: AtuTip,  error: ExibeErro} );
   }else{
	   Ajax.open("W_PPLSCBTQ.APW?cCampoRef="+cCampoRef+"&cChkCpo="+ref.value+"&cTab="+cTab+"&cCheckDePara=0", {callback: AtuTip,  error: ExibeErro} );
   }
}
function AtuTip(v){
   //aqui atualizo o valor que vem no tooltip
   var aRetorno = v.split("|");
   var cCampoRef = aRetorno[0];
   var cDescri = aRetorno[1]; 

   if (document.getElementById(cCampoRef) != null){ 

	   document.getElementById(cCampoRef).setAttribute("title",cDescri);
	   
	   $(document.getElementById(cCampoRef)).data('tooltip',false).tooltip({ title: 'cDescri'});

   } 
}

//Exibe erro e re-habilita botao de incluir
function ExibeErroInt(v) {
   setDisable("bIncTabSolSer", false);
   ExibeErro(v);
}

//--------------------------------------------------------------------
// Exibe erros no processamento das funcoes						 	    
//--------------------------------------------------------------------
function ExibeErro(v) {
   var aResult = v.split("|");

   if (aResult[0] != "true" && aResult[0] != "false") alert("Erro: " + aResult[0])
   else {
	   if (aResult[0] == "false") {
		   //retirado o actionVoltar daqui pois estava impactando nos erros que dava na guia na tela
		   ShowModal("Atenção!", aResult[1], true, false, true);
		   //--------------------------------------------------------------------
		   // Move o focu para o campo											  
		   //--------------------------------------------------------------------
		   if (typeof cCampoRef != 'undefined' && !document.getElementById(cCampoRef).disabled){
			   document.getElementById(cCampoRef).value = '';
			   document.getElementById(cCampoRef).focus();
		   }
		   //--------------------------------------------------------------------
		   // Limpa campo															  
		   //--------------------------------------------------------------------
		   if (typeof cCampoRefL != 'undefined' && cCampoRefL != '' && !document.getElementById(cCampoRefL).disabled) {
			   document.getElementById(cCampoRefL).value = "";
			   cCampoRefL = "";
		   }
		   //--------------------------------------------------------------------
		   // Ativa campo como obrigatorio										  
		   //--------------------------------------------------------------------
		   if (typeof cCampoRefObr != 'undefined') {
			   oForm.add(document.getElementById(cCampoRefObr), "tudo", false, false);
		   }
		   //--------------------------------------------------------------------
		   // Para controle de exclusao											  
		   //--------------------------------------------------------------------
		   if (typeof cCpoRegEsp != 'undefined' && typeof cCpoRegCon != 'undefined') {
			   document.getElementById(cCpoRegEsp).value += cCpoRegCon + '|';
		   }
	   }
   }
}
//--------------------------------------------------------------------
// Botao complemento a ser implementado pelo usuario	 		    	  
//--------------------------------------------------------------------
function fComplemento() {
   var pRda    = document.getElementById("cRda").value;
   var pCodLoc = document.getElementById("cCodLoc").value;
   var pTp     = document.getElementById("cTp").value;
   var pNumAut = document.getElementById("cNumAut").value;

   setDisable("bcomplemento",true);
   ChamaPoP('W_PPLSCMPFP.APW?cFunName=PLSCMPFP&cNumAut='+pNumAut+'&cRda='+pRda+'&cCodLoc='+pCodLoc+'&cTp='+pTp,'bol','yes',0,925,605);
}  

//--------------------------------------------------------------------
// Funções executadas na abertura da guia SADT	 		    	  
//--------------------------------------------------------------------
function SADTLoad(){

var aResult 	= {};
var aIndCombo 	= {}
cVazio 			= "";
cVirgula 		= ",";
cIndCombo 		= "";
lIsDigitacaOffLineZ = isDitacaoOffline();
lIsAlteraGuiaAutZ   = isAlteraGuiaAut();
   //--------------------------------------------------------------------
   // Carrega dados da rda												   
   //--------------------------------------------------------------------
   //Independente se é Off-Line ou Atendimento, este campo deve ficar oculto!
   if (isObject(document.forms[0].cTpProc)) {
	   document.forms[0].cTpProc.style.display = "none"; //deixo o campo que carrega o tipo de documento escondido pois não pertence ao layout tiss
	   document.forms[0].cTpProc.parentElement.style.display = "none";
   }
   if( lIsDigitacaOffLineZ && lIsAlteraGuiaAutZ ){
	   var cRecno = $("#cRecnoBD5").val();
	   setDisable('bSaveTabExeSer',true);		

	   //Desabilita o campo Num. Guia Prestador (002) e o botão de busca da guia
	   setDisable('cNumAut',true);
	   setDisable(cBtnExec,true);
	   
	   setDisable('cCarSolicit', true);
	   setDisable('dDtSolicit', true);
	   setDisable('cIndCliSol', true);

	   //Desabilita os campos cProSolDesc e cProExeDesc, deixando habilitado apenas o botão de busca F3
	   setDisable('cProSolDesc',true);
	   setDisable('cProExeDesc',true);

	   setDisable("bIncTabExe",false);
	   setDisable("bSaveTabExe",true);

	   Ajax.open("W_PPLCHAALT.APW?cRecno=" + cRecno + "&cTipGui=2"  , { callback : fRespostaSADT, error : exibeErro });
   }else if (lIsAlteraGuiaAutZ){
	   aResult = $("#cAltCmpG").val().split("|"); 
	   fChamConsulta(aResult[1]);  
	   setDisable("cCbosSol",true);
	   setDisable("cCarSolicit",true);

	   //Desabilita os campos cProSolDesc e cProExeDesc, bloqueando também o botão de busca F3
	   setDisable('cProSolDesc',true);
	   setDisable('BcProSolDesc',true);
	   setDisable('cProExeDesc',true);
	   setDisable('BcProExeDesc',true);

	   setDisable("bIncTabExe",true);
	   setDisable("bSaveTabExe",true);

	   cTexto = "<p> Somente os campos disponiveis para edicao podem ser alterados apos Autorizacao da guia. Os demais campos sao apenas visualizacao! </p>"
	   
	   modalBS("Atencao", cTexto, "@Fechar~closeModalBS();", "white~#ffff00");	
   } else {
	   fRda(document.getElementById("cRda").value,document.getElementById("cCodLoc").value);
	   document.getElementById("cCodPadSSol").value=document.getElementById("cmvTabDef").value;
	   document.forms[0].cCodPadSSol.className = "form-control TextoInputOB"; //deixo os campos em destaque
	   document.forms[0].cCodProSSol.className ="form-control TextoInputOB"; //deixo os campos em destaque
	   document.forms[0].cQtdSSol.className ="form-control TextoInputOB";//deixo os campos em destaque
	   document.forms[0].cNumeCart.className ="form-control TextoInputOP";//deixo o campo apagado
	   document.forms[0].cNomeUsu.className ="form-control TextoInputOP";//deixo o campo apagado
	   document.forms[0].cRegAns.className ="form-control TextoInputOP";//deixo o campo apagado
	   document.forms[0].cCnpjCpfSol.className ="form-control TextoInputOP";//deixo o campo apagado
	   document.forms[0].cNomeRdaSol.className = "form-control TextoInputOP";//deixo o campo apagado
								   
	   setDisable('bSaveTabSolSer',true);	
	   setDisable('bSaveTabExeSer',true);	
	   setDisable('bimprimir',true);
	   setDisable("bAnexoDoc",true);
	   
	   if(lIsDigitacaOffLineZ){

		   //Desabilita grid de executantes			
		   toggleDiv('GrpIndExe');	
		   setDisable("bIncTabExe",true);
		   setDisable("bSaveTabExe",true);
		   setDisable("dDtSolicit",false);
		   setDisable("dDtExe",false);

		   //Desabilita os campos cProSolDesc e cProExeDesc, deixando habilitado apenas o botão de busca F3
		   setDisable('cProSolDesc',true);
		   setDisable('cProExeDesc',true);
	   } else {
		   //Comportamento exclusivo do atendimento			
		   
		   /*Grupo de campos Dados do Atendimento fica oculto pois esses campos são
		   obrigatórios apenas na execução e dig. off-line*/
		   toggleDiv('GrpDadApe');	
	   
	   }
   
   }

   if (document.getElementById(cBtnExec) == null){
	   cBtnExec = 'BcNumAut';
   }

}

function fCmpObrigat(aCmp){
//--------------------------------------------------------------------
// Tratamento dos campos												   
//--------------------------------------------------------------------
var oForm = new xform( document.forms[0] );
   if (document.forms[0].cTp.value != "4") {
	   oForm.add( document.forms[0].cCodPadSSol	,"numero", false, true );
	   oForm.add( document.forms[0].cCodProSSol	,"numero", false, true );
	   oForm.add( document.forms[0].cQtdSSol		,"numero", false, true );
	   oForm.add( document.forms[0].cCodPadSExe	,"numero", false, true );
	   oForm.add( document.forms[0].cCodProSExe	,"numero", false, true );
	   oForm.add( document.forms[0].cQtdSExe		,"numero", false, true );
	   oForm.add( document.forms[0].cCarSolicit	,"tudo"	 , false, false );
	   oForm.add( document.forms[0].cProSol		,"tudo"	 , false, false );
	   oForm.add( document.forms[0].cIndCliSol		,"tudo"	 , false, true );
   } else {
	   oForm.add( document.forms[0].cProSol		,"tudo"	 , false, false );
   }
}

//====================================================
//FUNÇÕES DA GUIA DE CONSULTA
//====================================================

//--------------------------------------------------------------------
// Validacao da re-consulta - ponto de entrada no botao confirmar da guia 
// GUIA DE CONSULTA                                                       
//--------------------------------------------------------------------
function fRegEspCon(cCmpReg,cTpGuia) {
   //--------------------------------------------------------------------
   // Valida re-consulta													   
   //--------------------------------------------------------------------
   if (document.getElementById("cRegEsp").value=="1") {
	   
	   if (typeof cTpGuia == "undefined")	cTpGuia = '1';
   
	   //--------------------------------------------------------------------
	   // Variavel global para colocar em foco e variavel global para ativar o obrigatorio   
	   //--------------------------------------------------------------------
	   cCampoRef 	 = cCmpReg;                 
	   cCampoRefObr = cCmpReg;                 
	   //--------------------------------------------------------------------
	   // Variavel local																	   
	   //--------------------------------------------------------------------
	   var cCodRda = cTpGuia == "1" ?  document.getElementById("cRda").value : document.getElementById("cNumCrSol").value ;
	   var cMatric = document.getElementById("cNumeCart").value;
	   var cCodPad = cTpGuia == "1" ?  document.getElementById("cCodPad").value :document.getElementById("cCodPadSSol").value; 
	   var cCodPro = cTpGuia == "1" ?  document.getElementById("cCodPro").value :document.getElementById("cCodProSSol").value;  
	   var dDatPro = cTpGuia == "1" ?  document.getElementById("dDtAtend").value :document.getElementById("dDtSolicit").value;  
	   
	   //--------------------------------------------------------------------
	   // So executa uma vez													   
	   //--------------------------------------------------------------------
	   document.getElementById("cRegEsp").value = '0';
	   
	   cStringEnvTab = "";
	   
	   if (cTpGuia == "2"){ 
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Monta conteudo das tabelas	solicitacao e execucao					  ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   if (document.getElementById("cNumAut").value==""){
				aMatAux = ["TabSolSer",oTabSolSer];
		   }
		   else{
			   aMatAux = ["TabExeSer",oTabExeSer];
			   aMatAux2 = ["TabExe",oTabExe];
		   }
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Carrega as linhas das tabelas para processamento					   ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   aMat = aMatAux;
		  
			  for (var i = 0; i < aMat.length; i++) {
					  aInfoAux = aMat
					  if (typeof aInfoAux[i] != "undefined" && typeof aInfoAux[i] != "string" && aInfoAux[i].aCols.length > 0) { 
					   //Pega o nome do grid 
					   oTable = aInfoAux[1].getObjCols();
					   //Associa a coluna com a variável do post
					   fMontMatGer('A', aInfoAux[0]);
					   aMatCampAux = aMatCap.split("|");
						   for (var y = 0; y < oTable.rows.length; y++) { 
							   nf = 0;
							  for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) { 
								   cCampo = aMatCampAux[x - 2].split("$")[1];
								  if (cCampo != "NIL" && aMatNGet.indexOf(cCampo) == -1){ 
									   celula = oTable.rows[y].cells[x + 1 - nf];
									   if (typeof celula.value == 'undefined' || celula.value == ''){
										   conteudo = getTC(celula);
									   }
									   else{
										   conteudo = celula.value;
									   }
									   if ((cCampo == 'cCodPad') || (cCampo == 'cCodPro')){ 
											   cStringEnvTab += cCampo + conteudo.split("*")[0]  ;
									   } 
								   } 
								   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo'){
									   nf += 1;
								   }
							   } 
								   cStringEnvTab += "|";
						   } 
					 }
		   }
	   }				
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Executa regra especifica do cliente									   ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   if (cTpGuia == "1")
		   {
	   if (cCodPad != '' && cCodPro != '') {
				   Ajax.open("W_PPSVLDESP.APW?cCodRda="+cCodRda+"&cMatric="+cMatric+"&cCodPad="+cCodPad+"&cCodPro="+cCodPro+"&dDatPro="+dDatPro, {callback: ProcFormCon,  error: ExibeErro} );
			   }
		   }
		   else{
			   if (cStringEnvTab != ''){
				   Ajax.open("W_PPSVLDESP.APW?cCodRda="+cCodRda+"&cMatric="+cMatric+"&cProcs="+cStringEnvTab+"&dDatPro="+dDatPro, {callback: ProcForm,  error: ExibeErro} );
			   }
		   } 	
	   }	
   else {
		   if (cTpGuia == "1"){
	   fProcFormCon(FrmGuia);
   }  
		   else{
			   fProcForm(FrmGuia);
		   }
	   }  
} 

//--------------------------------------------------------------------
// Se vai fazer o processamento do formulario ou retono do ponto de entrada vai impedir  
//--------------------------------------------------------------------
function ProcFormCon() {
   fProcFormCon(FrmGuia);
}

function fProcFormCon(formulario)	{                
   var lDigOff = false;
   
   if (isDitacaoOffline())  //r7
   {	
	   lDigOff = true;
	   
	   //--------------------------------------------------------------------
	   // Valida formulario
	   //--------------------------------------------------------------------
	   if( !valida(/*window.frames[0].oForm*/) ) return;
	   document.forms[0].bconfirma.disabled = true;
	   modalBS('<i class="fa fa-exclamation-triangle" style="font-weight: bold; color: #000; text-shadow: 0 1px 0 #fff; filter: alpha(opacity=20); opacity: .2;"></i>&nbsp;&nbsp;&nbsp;Alerta', '<p>Tem certeza que deseja finalizar a guia?</p>', "@Sim, conclui a digitação!~confirmaConsulta('1')@Não, desejo continuar posteriormente!~confirmaConsulta('2');", "white~ #f8c80a", "large","N");
   } else {	
	   document.forms[0].action = "W_PPLPROCGUI.APW";
   }
   
   if (!lDigOff){
	   //--------------------------------------------------------------------
	   // Valida formulario													   
	   //--------------------------------------------------------------------
	   if( !valida() ) return;
	   //--------------------------------------------------------------------
	   // traca campos														   
	   //--------------------------------------------------------------------
	   setDisable("cCbos",false);
	   setDisable("cProSaud",false);
	   setDisable("bconfirma",true);
	   setDisable("bimprimir",false);
	   setDisable("bAnexoDoc",false);
	   //--------------------------------------------------------------------
	   // Metodo de envio de formulario pelo ajax								   
	   //--------------------------------------------------------------------

	   Ajax.send( formulario, {callback:CarregaProcFormCon, error: ExibeErro} );
	   
	   document.forms[0].action = "";
	   //--------------------------------------------------------------------
	   // Desabilita os campos												   
	   //--------------------------------------------------------------------
	   FDisElemen('Tdb|Tdc|Thd|Tdp|Toth',true);
   }
} 

function CarregaProcFormCon(v) {        
   var aResult   = v.split("|");               
	  var cSenha	  = "";
   var cTexto	  = aResult[10]; //Procedimento autorizados ou negados resultado
   var cTitulo   = aResult[11]; //Titulo do resultado autorizado,negado ou autorizado parcial 
   var cAlerta   = aResult[14]; //define que se trata de um alerta 
   if(document.getElementById("cNumAut") != undefined){
	   var cObjNumAut = document.getElementById("cNumAut");
   } else {
	   var cObjNumAut = window.frames[0].document.getElementById("cNumAut");
   }
   
   //--------------------------------------------------------------------
   // Numero da guia
   //--------------------------------------------------------------------
   if (aResult[0] != "")
	   cObjNumAut.value = aResult[0].substr(0,4)+"."+aResult[0].substr(4,4)+"."+aResult[0].substr(8,2)+"-"+aResult[0].substr(10,8);//Numero da autorizacao

   //--------------------------------------------------------------------
   // Implementa Senha na exibição (se houver)										   
   //--------------------------------------------------------------------
   if (aResult[1] != "")
	   cSenha = "<br/> Senha: "+aResult[1];
	   
   //--------------------------------------------------------------------
   // Para mostrar o numero da autorizacao								   
   //--------------------------------------------------------------------
   if (cTexto == "")
	  cTexto = cObjNumAut.value + cSenha;
   
   //--------------------------------------------------------------------
   // Mostra o resultado modal
   //--------------------------------------------------------------------
   if (cAlerta == "true") { 		
   
	   //Se houver alerta, exibimos o numero da guia e a mensagem logo abaixo
	   cTexto = "Guia número: " + cObjNumAut.value + "<br>" + cTexto;
	   
	   var cFuncDoc = "";
	   //Exibe modal com alertas
	   if(wasDef( typeof cTp) && (cTp.value == 1 || cTp.value == 2 || cTp.value == 3 || cTp.value == 7 || cTp.value == 8 || cTp.value == 9 || cTp.value == 11 )){
		   cFuncDoc =  "@Anexar Documentos~anexoDocGui('" + aResult[0] + "')";
	   }
	   
	   ShowModal(cTitulo,cTexto,true,false,true,"actionVoltar();"+ cFuncDoc);	
	   
   } else {	
	   
	   var cFuncDoc = "";
	   //Exibe modal com alertas
	   if(wasDef( typeof cTp) && (cTp.value == 1 || cTp.value == 2 || cTp.value == 3 || cTp.value == 7 || cTp.value == 8 || cTp.value == 9 || cTp.value == 11 )){
		   cFuncDoc =  "@Anexar Documentos~anexoDocGui('" + aResult[0] + "')";
	   }
	   
	   ShowModal(cTitulo,cTexto,(cTitulo.indexOf("Críticas") < 0 && cTitulo.indexOf("Nao Autorizada")),false,false,"actionVoltar();"+cFuncDoc);
   }
}

function fRdaCon(cRda, cCodLoc) {
   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
	   callback: CarregaRdaCon, 
	   error: ExibeErro
   });
}

//--------------------------------------------------------------------
// Monta campos conforme processamento da rdas							   
//--------------------------------------------------------------------
function CarregaRdaCon(v) {
 var aResult	 = v.split("|");                            
 var aResuEsp = (aResult[24].substring(1)).split("~");   
   
   //--------------------------------------------------------------------
   // Local de atendimento												   
   //--------------------------------------------------------------------
   document.getElementById("cCodLoc").value		= aResult[22];
//--------------------------------------------------------------------
// Alimenta as variaveis												   
//--------------------------------------------------------------------
 document.getElementById("cRegAns").value 		= aResult[1];
 
 document.getElementById("cCnpfCpf").value 		= aResult[2];
 document.getElementById("cNomeRdaExe").value	= aResult[3];
 document.getElementById("cCnes").value 			= aResult[4];
 document.getElementById("cTpPe").value 			= aResult[14]; 
   //--------------------------------------------------------------------
   // Se e fisica ou juridica												   
   //--------------------------------------------------------------------
 if(aResult[14].toUpperCase() == 'F') {            

	   // Se for pessoa Fisica eu ja deixo posicionado no indice dele
	   $('#cProSol option:contains("' + document.getElementById("cNomeRdaExe").value.trim() + '")').prop('selected' ,true);

	   if (document.getElementById("cCodSig") != null) {
		   document.getElementById("cCodSig").value	= aResult[16];
	   }                                   
	   if (document.getElementById("cCodSigExe") != null) {
		   document.getElementById("cCodSigExe").value	= aResult[16];
	   }         
	   if (document.getElementById("cNumCr") != null){
		   document.getElementById("cNumCr").value		= aResult[17];
	   }                                        
	   if (document.getElementById("cNumCrExe") != null){
		   document.getElementById("cNumCrExe").value		= aResult[17];
	   }        
	   if (document.getElementById("cEstado") != null){
		   document.getElementById("cEstado").value	= aResult[18];
	   }
	   if (document.getElementById("cEstSigExe") != null){
		   document.getElementById("cEstSigExe").value	= aResult[18];
	   }
	   
	   if (document.getElementById("cProSol") != null){
		   document.getElementById("cProSol").value = aResult[15];
	   }
	   
	   if (document.getElementById("cProSolDesc") != null){
		   document.getElementById("cProSolDesc").value = trim(aResult[19].split('@')[0]);
	   }

	   setDisable("cProSaud",true);
	   setDisable("BInclui",true);    
	   setDisable("BHelp20",true);    
   } else {
	   setDisable("cProSaud",false);
	   setDisable("BInclui",false);
	   setDisable("BHelp20",false);    
   }
   //--------------------------------------------------------------------
   // Monta especialidades												   
   //--------------------------------------------------------------------
   
   if (document.getElementById("cCbos") != null) {
	   setTC(document.getElementById("cCbos"),"");
	   var e = document.getElementById("cCbos");
	   for(var i=0; i < aResuEsp.length; i++) {
		  var aIten = aResuEsp[i].split("$"); 
		   e.options[i] = new Option(aIten[1], aIten[0]);
		 }   
   }else{ 
	   if (document.getElementById("cCbosExe") != null) {
		   setTC(document.getElementById("cCbosExe"),"");
		   var e = document.getElementById("cCbosExe");
		   for(var i=0; i < aResuEsp.length; i++) {
			  var aIten = aResuEsp[i].split("$"); 
			   e.options[i] = new Option(aIten[1], aIten[0]);
		   }
	   }   
   }
} 
//--------------------------------------------------------------------
cBusca   	= "";
cTimeOut 	= 0;
cProfAntG   = "";
//--------------------------------------------------------------------
// Limpa variavel BackSpace ou Delete - chamado no keydown
//--------------------------------------------------------------------
function fProfSauClearCon(e) {
   var keyID = (window.event) ? e.keyCode : e.which;
 //--------------------------------------------------------------------
 // BackSpace e Delete etc nao sao capturadas pelo keypress
 // por isso o tratamento desta forma. quando for backspace tem que retornar
 // false para nao retornar a pagina anterior.
 //--------------------------------------------------------------------
 lVld = (keyID >=64 && keyID <=93 || keyID >=97 && keyID <=125 || keyID >=48 && keyID <=62 || keyID == 95 || keyID == 8 || keyID == 46 || keyID == 32)
 if (lVld)  {
	   fProfSauFilCon(e);                         
	   return (keyID == 8) ? false : true;
   }
}
//--------------------------------------------------------------------
// Busca lookup (filtrado) - chamado no keypress
//--------------------------------------------------------------------
function fProfSauFilCon(e) {
 var cRda 	= document.getElementById("cRda").value;
   var cCodLoc = document.getElementById("cCodLoc").value;
   var keyID 	= (window.event) ? e.keyCode : e.which;
   //--------------------------------------------------------------------
   // Tratamento quando for backspace ou delete desviado pela fProfSauClear
   //--------------------------------------------------------------------
   if (keyID == 8) {
	 cBusca = cBusca.substr(0,cBusca.length-1);
   } else if (keyID == 46) {
	 cBusca = "";         
   } else {
	   cBusca = cBusca + String.fromCharCode(keyID);
   }
 //--------------------------------------------------------------------
 // Executa o metodo													  
 //--------------------------------------------------------------------
 Ajax.open("W_PPLATUPRO.APW?cBusca=" + cBusca + "&cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
	 callback: CarregaProSaudeFilCon, 
	 error: ExibeErro,
	 showProc: false	 
 });
 //--------------------------------------------------------------------
 // Se nao for digitado nada no tempo abaixo limpa a string 30 segundos
 //--------------------------------------------------------------------
 clearTimeout(cTimeOut);
 cTimeOut = setTimeout("fProfSauRestart()", 30000);
}

//--------------------------------------------------------------------
// Carrega campos conforme processamento Profissional de saude			  
//--------------------------------------------------------------------
function CarregaProSaudeFilCon(v) {
 var aResult = v.split("|");   
 //--------------------------------------------------------------------
 // Verfiica se e solicitacao ou execucao
 //--------------------------------------------------------------------
   setTC(document.getElementById("cProSaud"),"");
   var e = document.getElementById("cProSaud");
 //--------------------------------------------------------------------
 // Alimenta o combo
 //--------------------------------------------------------------------
   for (var i = 0; i < aResult.length; i++) {
	   var aProf = aResult[i].split("%");
	   if (aProf.length>1 && aProf[1] != '')
		   e.options[i] = new Option(aProf[1], aProf[0]);
   }		                 
 //--------------------------------------------------------------------
 // carrega campos do prestador
 //--------------------------------------------------------------------
 if (cProfAntG != e.value) {
	   cProfAntG = e.value;
	   fProfSauCon(e.value);
   }
}

//--------------------------------------------------------------------
// Monta os executantes												   
//--------------------------------------------------------------------
function fProfSauCon(cProSaud) {                
   var cMatric = document.getElementById("cNumeCart").value;
   var cCodLoc = parent.frames[0].document.forms[0]["cCodLoc"].value;
   var cRda = parent.frames[0].document.forms[0]["cRda"].value;
   //--------------------------------------------------------------------
   // Executa o metodo													  
   //--------------------------------------------------------------------
   Ajax.open("W_PPCBOSPSAU.APW?cProSaud="+cProSaud+ "&cMatric="+cMatric+"&cRda="+cRda+"&cCodLoc="+cCodLoc, {callback: CarregaProSaudeCon, error: ExibeErro,showProc: false } );
}   

function CarrEspAntCon(v){
   var aResult = v.split("|");
   var aResuEsp = (aResult[24].substring(1)).split("~");
   //--------------------------------------------------------------------
   // Monta especialidades												   
   //--------------------------------------------------------------------
   setTC(document.getElementById("cCbos"),"");
   var e = document.getElementById("cCbos");
   for (var i = 0; i < aResuEsp.length; i++) {
	   var aIten = aResuEsp[i].split("$");
	   e.options[i] = new Option(aIten[1], aIten[0]);
   }   
}   

//--------------------------------------------------------------------
// Carrega campos conforme processamento dos executantes				   
//--------------------------------------------------------------------
function CarregaProSaudeCon(v) {
 var aResult = v.split("|");                            
   //--------------------------------------------------------------------
   // alimenta variaveis													   
   //--------------------------------------------------------------------
 document.getElementById("cCodSig").value 	= aResult[0];
 document.getElementById("cNumCr").value 	= aResult[1];
 document.getElementById("cEstado").value 	= aResult[2];
 document.getElementById("cProSol").value 	= aResult[3];
	 if (aResult.length >= 6){			    
			   if ( typeof(aResult[6]) != 'undefined' ) {
					setTC(document.getElementById("cCbos"),"");			
				   var aEspeci = aResult[6].split('$');		
				   var e = document.getElementById("cCbos");
				   for (var i = 0; i < aEspeci.length; i++) {
					   var aIten = aEspeci[i].split("#");
					   if (aIten[0] != '') {                  
						   e.options[i] = new Option(aIten[1], aIten[0]);
						}	
				   }
			   }else{        
				   var cRda 	= document.getElementById("cRda").value;
				   var cCodLoc = document.getElementById("cCodLoc").value;
				   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
					   callback: CarrEspAntCon, 
					   error: ExibeErro,
					   showProc: false 
				   });    
			   }
		   }else{        
				   var cRda 	= document.getElementById("cRda").value;
				   var cCodLoc = document.getElementById("cCodLoc").value;
				   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
					   callback: CarrEspAntCon, 
					   error: ExibeErro,
					   showProc: false 
				   });    
		   }
}  

//--------------------------------------------------------------------
// Checa se o procedimento e valido									   
//--------------------------------------------------------------------
function fChkCodProCon(cCmpPad,cCmpPro,cCmpDesc,cTpProc, cCmpMatric, cCmpRda) { 
   cRda = '';
   cCampoRef 	 = cCmpPro;                 
 if (cCmpDesc != '') {
	   cCampoRefDes = cCmpDesc;
	   document.getElementById(cCmpDesc).value = "";
   }    

 cCodPad = document.getElementById(cCmpPad).value;
   cCodPro = document.getElementById(cCmpPro).value;
   cMatric = document.getElementById(cCmpMatric).value;
   if  (document.getElementById(cCmpRda) != null){
	   cRda = document.getElementById(cCmpRda).value;
   }
   
   if (cCodPad == "") {
	   alert("Informe o Código da tabela");
	   document.getElementById(cCmpPad).focus();
	   return false;
   }                    

   if (cCodPro == "") return true;
   
 Ajax.open("W_PPLSCHKSER.APW?cCodPadPro=" + ( cCodPad + cCodPro ) + "&cTpProc=" + cTpProc + "&cMatric=" + cMatric + "&cRda=" + cRda, { 
			 callback: CarregaDeskProCon, 
	 error: ExibeErro 
 });

		   
}                               

function CarregaDeskProCon(v) {
 var aResult = v.split("|");

   if (aResult[6] == "forbla") {
	   alert(aResult[7]);
   }
   //na versao 3 este eh o valor apresentado pelo prestador eu vou deixar ele informar o valor.	
   //document.getElementById("cVlrPro").value = aResult[3]	
}	

function CONSLoad(){
   cVazio = "";
   cVirgula = ",";
   cIndCombo = "";
   cCbosSolAux = "";
   var aIndCombo = {};

   //--------------------------------------------------------------------
   // disabled
   //--------------------------------------------------------------------
   setDisable("bimprimir",true);
   setDisable("bAnexoDoc",true);
   if(isDitacaoOffline()){
	   setDisable("dDtAtend",true); // Na consulta a data é definida na janela anterior e não pode ser alterada por existirem validações
   }
   //--------------------------------------------------------------------
   // Carrega dados da rda												   
   //--------------------------------------------------------------------
   fRdaCon(document.getElementById("cRda").value,document.getElementById("cCodLoc").value);
   document.getElementById("cCodPad").value=document.getElementById("cmvTabDef").value;
   
   if(isDitacaoOffline() && isAlteraGuiaAut()){
	   var cRecno = $("#cRecnoBD5").val();
	   Ajax.open("W_PPLCHAALT.APW?cRecno=" + cRecno + "&cTipGui=1"  , { callback : fMostraCons, error : exibeErro });
   }
   else if (isAlteraGuiaAut())	{
	   aResult = $("#cAltCmpG").val().split("|"); 
	   fChamConsulta(aResult[1]);
   }
   else{
   
	   //--------------------------------------------------------------------
	   // Carrega eventos dos campos											   
	   //--------------------------------------------------------------------
	   var oForm = new xform( document.forms[0] );

	   oForm.add( document.forms[0].cCodSigExe,  "tudo"	, false, false );
	   oForm.add( document.forms[0].dDtAtend, "data"  , false, false );
	   oForm.add( document.forms[0].cRda, 	"numero", false, false );
	   oForm.add( document.forms[0].cCodPad, 	"numero", false, false );
	   oForm.add( document.forms[0].cCodPro, 	"numero", false, false );
	   oForm.add( document.forms[0].cTpCon, 	"tudo"	, false, false );

	   //--------------------------------------------------------------------
	   // Validacao de campo que veio do ponto de entrada
	   //--------------------------------------------------------------------
	   //cCpsObr = document.getElementById("cCpsObr").value;

	   //if (cCpsObr != "")
	   //	oForm.add( document.getElementById(cCpsObr) ,"tudo", false, false );

	   //document.forms[0].cCodSigExe.focus();
	   
	   document.forms[0].cRegAns.className ="form-control TextoInputOP";//deixo o campo apagado
	   document.forms[0].cNumeCart.className ="form-control TextoInputOP";//deixo o campo apagado
	   document.forms[0].cNomeUsu.className ="form-control TextoInputOP";//deixo o campo apagado
	   document.forms[0].cCnpfCpf.className ="form-control TextoInputOP";//deixo o campo apagado
	   document.forms[0].cNomeRdaExe.className ="form-control TextoInputOP";//deixo o campo apagado
	   document.forms[0].cCbosExe.className ="form-control TextoInputOB";//deixo o campo destque
	   
	   document.forms[0].cCbosExe.className ="form-control TextoInputOB";//campo habilitado
	   
	   setDisable("cProSolDesc",true); //Desabilita o texto do campo nome profissional executante
   }
   
   alterarCamposGuias();
}

//=============================================
// Funções guia solicitação de internação
//=============================================

function fAjusFormInt(lHab) {
   var cSinal = "";
   
   //--------------------------------------------------------------------
   // Abre e Fecha os Grupos de acordo com o tipo de ação da guia            
   // lHab = .T. -> Solicitação; lHab = .F. -> Prorrogação                       
   //--------------------------------------------------------------------
   
   //--------------------------------------------------------------------
   // Solicitacao															   
   //--------------------------------------------------------------------
   cSinal = ( (lHab) ? '-' : '+' );	
   //--------------------------------------------------------------------
   // Execucao  - Prorrogacao												   
   //--------------------------------------------------------------------
   cSinal = ( (lHab) ? '+' : '-' );
   //Sempre Fechada	
   //--------------------------------------------------------------------
   // Habilia os campos de acordo com o tipo de ação da guia                 
   // lHab = .T. -> Solicitação; lHab = .F. -> Prorrogação                   
   //--------------------------------------------------------------------
   
   //Solicitação
   setDisable("cAtendRN",!lHab);
   setDisable("cCbosSol",!lHab);
   setDisable("cNomeSolT",!lHab);
   setDisable("cCarSolicit",!lHab);
   setDisable("cTpIntern",!lHab);
   setDisable("cRegInter",!lHab);
   setDisable("cQtdDSol",!lHab);
   setDisable("cIndCliSol",!lHab);
   setDisable("cIndAcid",!lHab);
   setDisable("cCid",!lHab);
   setDisable("cCid2",!lHab);
   setDisable("cCid3",!lHab);
   setDisable("cCid4",!lHab);
   setDisable("cCodPadSSol",!lHab);
   setDisable("cCodProSSol",!lHab);
   setDisable("cQtdSSol",!lHab);
   
   //Grid Solicitação
   setDisable("TabSolSer",!lHab);
   setDisable("bIncTabSolSer",!lHab);
   setDisable("bSaveTabSolSer",lHab); 
   
   //Execução
   setDisable("cResAutPro",lHab);
   setDisable("cCodPadSPro",lHab);
   setDisable("cCodProSPro",lHab);
   setDisable("cQtdSPro",lHab);
   setDisable("cQtdSAutPro",lHab);
   
   //Grid Prorrogação
   setDisable("TabProSer",lHab);
   setDisable("bIncTabProSer",lHab);
   setDisable("bSaveTabProSer",lHab);
	   
}
//--------------------------------------------------------------------
// Monta matriz genericas												   
//--------------------------------------------------------------------
function fMontMatGerInt(cTp,cTable) {                                       
   //--------------------------------------------------------------------
   // Monta matriz genericas												   
   //--------------------------------------------------------------------
   switch (cTable)	{                                          
	   case "TabSolSer":
		   aMatCap 		 = ( (cTp=='I') ? 'Chk$NIL|' : "" ) + 'cCodPadSSol$cCodPad|cCodProSSol$cCodPro|cDesProSSol$cDesPro|cQtdSSol$nQtdSol|cQtdAutSSol$nQtdAut';
		   aMatBut 		 = 'bISolSer|bASolSer|bESolSer';
		   aMatRet 		 = 'cStatusAut~cQtdAutSSol';
		   cChave 			 = 'cCodProSSol';
		   cCampoDefault	 = 'cCodPadSSol;aInipadcCodPadSSol|cQtdSSol;aInipadcQtdSSol';
		   aValAlt			 = 'cCodPadSSol|cCodProSSol|cQtdSSol';
		   aCalVal			 = '';
		   aMatConv 		 = '';
		   aMatNGet 		 = 'cDesPro';
		   break;   
	   case "TabProSer":
		   var d = new Date()
		   aMatCap 		 = ( (cTp=='I') ? 'Chk$NIL|' : "" ) + 'dDtExePro$dDtExe|cSenhaPro$cSenha|cResAutPro$cResAut|cTpAcomPro$cTpAcom|cDesAcomPro$cAcomod|cQtdDAutPro$nQtdDAut|cCodPadSPro$cCodPad|cCodProSPro$cCodPro|cDesProSPro$cDesPro|cQtdSPro$nQtdSol|cQtdSAutPro$nQtdAut|cIndCliSolEvo$cIndCliEvo';
		   aMatBut 		 = 'bIProSer|bAProSer|bEProSer';
		   aMatRet 		 = 'cStatusAut~cQtdSAutPro';
		   cChave 			 = 'cCodProSPro';
		   cCampoDefault	 = 'cCodPadSPro;aInipadcCodPadSPro|cQtdSPro;aInipadcQtdSPro|cQtdDAutPro;aInipadcQtdDAutPro|dDtExePro;aInipaddDtExePro|cTpAcomPro;aInipadcTpAcomPro|cDesAcomPro;aInipadcDesAcomPro' ;
		   aValAlt			 = 'cCodPadSPro|cCodProSPro|cQtdSPro';
		   aCalVal			 = '';
		   aMatConv 		 = '';
		   aMatNGet 		 = 'cDesPro';
		   break;
   }
} 

//--------------------------------------------------------------------
// Verifica se o numero da Autorizacao existe e mostra os dados		  
//--------------------------------------------------------------------
function fChamDadInt(cNumeAut) {
   //--------------------------------------------------------------------
   // Verifica se foi informado a chave									  
   //--------------------------------------------------------------------
   if (cNumeAut == "") {
	   alert("Informe o numero da Solicitacao");
	   return;
   }
   
   //valida a quantidade de caracteres digitados 
   if(!fValQtdCarac(cNumeAut.replace(/\.|-/gi,""),18)){
	   return;                                                                                                   
   }
   
   //--------------------------------------------------------------------
   // Retira a mascara													  
   //--------------------------------------------------------------------
   var cRda 	= document.getElementById("cRda").value;
   var cMatric = document.getElementById("cNumeCart").value;
   var cCodLoc = document.getElementById("cCodLoc").value;
   //--------------------------------------------------------------------
   // Executa o metodo													  
   //--------------------------------------------------------------------
   Ajax.open("W_PPLSCHALIB.APW?cNumeAut=" + cNumeAut.replace(/\D/g, "") + "&cTp=3&cTpAut=A", { 
	   callback: CarregaDadInt,
	   error: ExibeErro 
   });
}
//--------------------------------------------------------------------
// Pega o retorno														  
//--------------------------------------------------------------------
function CarregaDadInt(v) {   
   var cPSol 		= "";
   var cNSol 		= "";
	  var cPSol1 		= "";
   var cNSol1 		= "";
   var aMatCabIte 	= v.split("<");
   var aMatCab 	= aMatCabIte[0].split("|");
   //--------------------------------------------------------------------
   // Verifico se a estrutura dos itens foram enviadas					  
   //--------------------------------------------------------------------
   if (typeof aMatCabIte[1] == "undefined") {
	   alert("Estrutura indefinada");
	   return;
   }
   var aMatIteG = new Array()
   var aMatIte = aMatCabIte[1].split("~");
   //--------------------------------------------------------------------
   // Exibi criticas de procedimentos que nao podem ser executados		  
   //--------------------------------------------------------------------
   if (typeof aMatCab[aMatCab.length-1] != "undefined") {
	   if (aMatCab[aMatCab.length-1] != "") alert(aMatCab[aMatCab.length-1]);
   }
   //--------------------------------------------------------------------
   // Cabecalho															  
   //--------------------------------------------------------------------
   for (var i = 0; i < (aMatCab.length - 1); i++) {
	   var aCamVal = aMatCab[i].split("!");
	   //--------------------------------------------------------------------
	   // Somente se foi passado o nome do campo								  
	   //--------------------------------------------------------------------
	   if (aCamVal[0] != "") {
		   var cCampo = document.getElementById(aCamVal[0]);
		   if (cCampo != null) {
			   //--------------------------------------------------------------------
			   // Se ainda nao foi informado a senha o paciente nao esta internado	  
			   //--------------------------------------------------------------------
			   if (aCamVal[0] == 'cSenha') {
				   if (aCamVal[1].replace(/ /g, "") == "") {
					   alert("Não é possível fazer a prorrogação!\nInternação ainda não foi realizada.");
					   return;
				   }        
			   }
			   //--------------------------------------------------------------------
			   // Se nao for o cCbos													  
			   //--------------------------------------------------------------------
			   if (aCamVal[0] != "cCbosSol" && aCamVal[0] != "cNomeSol" && aCamVal[0] != "cProSol" && aCamVal[0] !="cCnpjSolT" && aCamVal[0] !="cNomeSolT") {
				   cCampo.value = aCamVal[1];
			   } else if (aCamVal[0] == "cNomeSol") {
				   cNSol = aCamVal[1];
			   } else if (aCamVal[0] == "cProSol") {
				   cPSol = aCamVal[1];
				   cNSol = '';
			   } else if (aCamVal[0] == "cNomeRdaSol") {
				   cNSol = aCamVal[1];
				   document.getElementById("cNomeRdaSol").value = cNSol;
			   } else if (aCamVal[0] == "cCbosSol") {
				   setTC(document.getElementById("cCbosSol"),"");
				   var e = document.getElementById("cCbosSol");
				   var aIten = aCamVal[1].split("$");
				   e.options[0] = new Option(aIten[1], aIten[0]);
			   } else if (aCamVal[0] == "cCnpjSolT") {
				   cPSol1 = aCamVal[1];
			   } else if (aCamVal[0] == "cNomeSolT") {
				   cNSol1 = aCamVal[1];
				   document.getElementById("cNomeSolT").value = cNSol1;
			   }
			   
			   if (document.getElementById("toolTip"+aCamVal[0]) != null){ 
				   //aqui eu gravo no tooltip o conteudo do campo.. eu sei que esta errado.. tinha que fazer uma chamada ajax
				   //para buscar a descricao.. TODO                                	
				   document.getElementById("toolTip"+aCamVal[0]).setAttribute("data-title",document.getElementById(aCamVal[0]).value);
			   }      
			   //--------------------------------------------------------------------
			   // Codigo e Nome do profissional de saude								  
			   //--------------------------------------------------------------------
			   if (cNSol != "" && cPSol != "") {
				   setTC(document.getElementById("cProSolDesc"),"");
				   var e = document.getElementById("cProSolDesc");
				   e.value = cNSol; 

				   setTC(document.getElementById("cProSol"),"");
				   var e2 = document.getElementById("cProSol");
				   e2.value = cPSol;

				   cPSol = "";
				   cNSol = "";
			   }
			   //--------------------------------------------------------------------¢¯
			   //©ø Codigo e Nome do HOSPITAL SOLICITANTE								  ©ø
			   //--------------------------------------------------------------------
			   if (cNSol1 != "" && cPSol1 != "") {
				   setTC(document.getElementById("cNomeSolT"),"");
				   var e = document.getElementById("cNomeSolT");
				   e.options[0] = new Option(cNSol1, cPSol1);
				   cPSol1 = "";
				   cNSol1 = "";
			   }
		   }
	   }
   }
	//--------------------------------------------------------------------
   // Marca todas as linhas para delecao									  
   //--------------------------------------------------------------------
   //eu tenho que deletar todos os itens que ja foram impressos antes para nao ocorrer fabrica de registros
   //isso tambem se faz necessario pois quando 
   aTabDel = new Array("TabProSer") 
   for (var y = 0; y < aTabDel.length; y++) {
	   fGetDadGen(0, aTabDel[y] ,6);
   }
   //--------------------------------------------------------------------ÄÄ¿
   //Abre os grupos para evitar erro no carregamento dos grids.
   //--------------------------------------------------------------------ÄÄ¿
   var cTpSerOld = ""
   var aMatIteG = new Array()
   //--------------------------------------------------------------------ÄÄ¿
   // Alimenta os tabelas de servicos	matriz com linhas SOLICITACAO E EXECUCAO 
   //--------------------------------------------------------------------ÄÄÙ
   for (var i = 0; i < aMatIte.length; i++) {
	   //--------------------------------------------------------------------
	   // Matriz com os campos e valores SERVICO								  
	   //--------------------------------------------------------------------
	   if (aMatIte[i] != "") {
		   //--------------------------------------------------------------------ÄÄÄÄÄ¿
		   // Aprimeira posicao da matriz aMatval e o tipo de servico a segunda      		
		   // e se vai ser exibido ou nao da terceira em diante contem valores dos campos	
		   //--------------------------------------------------------------------ÄÄÄÄÄÙ
		   var aMatVal = aMatIte[i].split("@");
		   //--------------------------------------------------------------------Ä
		   // A segunda posicao [1] retorna se e possivel exibir para uma rda o procedimento  
		   //--------------------------------------------------------------------Ä
		   var cMostraSer = aMatVal[1].split("!")[1];
		   //--------------------------------------------------------------------ÄÄÄÄ¿
		   // Servico/Opm/Prorrogacao				  								  	   
		   // Coloca os procedimentos nos devidos folder's							   
		   //--------------------------------------------------------------------ÄÄÄÄÙ
		   cTpSer = aMatVal[0].split("!")[1];
		   //limpo o array que carrega os dados do grid quando passei pra outro grid
		   if (cTpSerOld != cTpSer){
			   aMatIteG = new Array()
		   }
		   //--------------------------------------------------------------------ÄÄÄÄ¿
			 //aMatIteG
		   //Estrutura: Tipo - Array, Conteúdo - Linha do detalhe
		   //	Estrutura: Tipo - String, Conteúdo - Coluna do detalhe: Variavel_Protheus!Valor 
		   //	***Não necessáriamente a coluna existe no grid. Isso é validado posteriormente
			 //--------------------------------------------------------------------ÄÄÄÄÙ
		   aMatIteG.push(aMatVal)
		   
		   if (cTpSer == "S") {
			   fCarregaTabelaInt('TabSolSer$0',aMatIteG,cMostraSer);
		   } else if (cTpSer == "PS") {
				  fCarregaTabelaInt('TabProSer$0',aMatIteG,cMostraSer); 	  
		   }
		   cTpSerOld = cTpSer	    
	   }       
   }        
   //--------------------------------------------------------------------
   // Troca o tipo obrigatorio do campo									   
   //--------------------------------------------------------------------
   for(var i=0; i<oForm.campos.length; i++) {                                       
	   switch (oForm.campos[i].campo.id) {
		   case "cCarSolicit":
				   oForm.campos[i].branco = true;
				   break    
		   case "cProSol":
				   oForm.campos[i].branco = true;
				   break
	   }
   }	             
   document.getElementById("cCodProSPro").value = ''
   document.getElementById("cDesProSPro").value = ''
   setDisable("bconfirma",false);
   setDisable("bimprimir",true);
   setDisable("bcomplemento",true);
   setDisable("bAnexoDoc",true);
   
   document.forms[0].cCodPadSPro.className = "form-control TextoInputOB"; //deixo os campos em destaque
   document.forms[0].cCodProSPro.className ="form-control TextoInputOB"; //deixo os campos em destaque
   document.forms[0].cQtdSPro.className ="form-control TextoInputOB";//deixo os campos em destaque
   document.forms[0].cResAutPro.className ="form-control TextoInputOB";//deixo os campos em destaque
   //--------------------------------------------------------------------
   // Dados da rda na execucao											   
   //--------------------------------------------------------------------
   if (document.getElementById("cRda").value != "" && document.getElementById("cCodLoc").value != "")
	   fRdaInt(document.getElementById("cRda").value,document.getElementById("cCodLoc").value);
}


//--------------------------------------------------------------------
// Monta matriz genericas carrega procedimento por procedimento		  
//--------------------------------------------------------------------
function fCarregaTabelaInt(aMatTabRel, aMatValG, cMostraSer) {
   var aMatTabAux = aMatTabRel.split('|')
   var cSeqCont = '0';
   var aCampos = Array();
   var aLinhas = Array();
   //--------------------------------------------------------------------
   // Para as tabelas informadas											  
   //--------------------------------------------------------------------
   for (var x = 0; x < aMatTabAux.length; x++) {
	   //--------------------------------------------------------------------
	   // Para habilitar o click ou nao na tabela e pegar o nome da tabela 	  
	   //--------------------------------------------------------------------
	   var aMatTab  = aMatTabAux[x].split('$');
	   //--------------------------------------------------------------------
	   // Verifica se atabela foi informada									  
	   //--------------------------------------------------------------------
	   if (aMatTab[0] != '') {
		   var cTable 	 = aMatTab[0];
		   var cTipoAcao= aMatTab[1];
		   //--------------------------------------------------------------------
		   // Carrega variaveis													  
		   //--------------------------------------------------------------------
		   fMontMatGerInt('I', cTable);
		   //--------------------------------------------------------------------
		   // Se vai carregar na matriz original ou vai espelhar em outra matriz	  
		   //--------------------------------------------------------------------
		   if (cTipoAcao == '0') {
			   var aMatCampVal = '';
			   var aMatCol 	= aMatCap.split("|");
			   var cTpAut 		= "1";
			   //--------------------------------------------------------------------
			   // Verifica toda a matriz com campos e valores							  
			   // associa o valor retornado ao campo do form							  
			   //--------------------------------------------------------------------
			   xHeader = "["
			   xCols = "["
			   var aHeader = new Array()
			   var aCols = new Array()

			   for (var z = 0; z < aMatValG.length; z++){
				   var cValores = ""
				   var aMatVal = aMatValG[z];
				   for (var y = 0; y < aMatVal.length; y++) {
					   var aMatColVal 	= aMatVal[y].split("!");
					   var cCampo 		= aMatColVal[0]
					   var cConteudo 	= aMatColVal[1]    
					   //--------------------------------------------------------------------
					   // Conforme o tipo de autorizacao muda a cor da linha					  
					   //--------------------------------------------------------------------
					   if (cCampo == 'cStatus') {
						   cTpAut = ( (cConteudo=='S') ? "1" : "0" );
						   //indica a linha que ser?marcada como criticada
						   if(cTpAut == "0"){
							   aLinhas.push(z+1);
						   }
					   }
					   //--------------------------------------------------------------------
					   // Faz o De x Para da variável do protheus com a da guia				  
					   //--------------------------------------------------------------------
					   for (var i = 0; i < aMatCol.length; i++) {
						   var aMatCampoForm = aMatCol[i].split("$");
						   if (aMatCampoForm[1]==cCampo) { 
							   cCampo = aMatCampoForm[0];
							   if(cCampo=="dDtExe"){
								   var d = new Date()
								   cConteudo = d.toLocaleDateString();
							   }
							   break;
						   }	
					   }
					   
					   if (typeof cCampo != 'undefined' && document.getElementById(cCampo) != null) {
						   document.getElementById(cCampo).value = cConteudo.split("*")[0];
						   //--------------------------------------------------------------------
						   // Matriz para compatibilizar tabelas exemplo. solicitacao com execucao.  
						   // Como a quantidade de campos e diferente deve dizer onde o valor da	   
						   // solicitacao vai ficar na execucao									   
						   //--------------------------------------------------------------------
						   aMatCampVal += cCampo + "$" + cConteudo.split("*")[0] + "|"
						   cValores +=  cCampo + "$" + cConteudo + ";"
					   }
					   if (cCampo == 'cSeqMov') {
						   cSeqCont = cConteudo;
					   }
				   }	
					 //--------------------------------------------------------------------
				   // Insere e limpa a linha												  o
				   //--------------------------------------------------------------------
				   if (!wasDef( typeof(cGrids) ) ){
					   if(wasDef( typeof(document.getElementById("cGrids")))){
						   cGrids = document.getElementById("cGrids")
					   }	
				   }
				   if (wasDef( typeof(cGrids) ) ){	
					   var aGrids = cGrids.value.split("@");
					   var nPos = 0
					   var nLen = aGrids.length
				   
				   
					   xHeader += "@"
					   for(nI=0; nI < nLen; nI++){
						   //Localiza o grid
						   nPos = aGrids[nI].indexOf(cTable+"~");
						   if(nPos > -1){
							   //Adiciona linha no xCols
							   xCols += "@"
							   //Retorna os campos do grid
							   aCampos = aGrids[nI].split("~")[1].split('|')[0].split(',') ;
							   aDescri = aGrids[nI].split("~")[1].split('|')[1].split(',') ;

							   var nLenCmp = aCampos.length //Numero de campos do grid

							   var aLinha = cValores.split(";");

							   var aCmpVal = new Array();
							   //Separa campo e valor
							   for(nJ = 0; nJ < aLinha.length; nJ++){
								   aCmpVal.push(aLinha[nJ].split('$'))
							   }
							   //Cria o Array de valores
							   var aValores = new Array(nLenCmp)
							   var nLenCmpVal = aCmpVal.length 
							   for(nJ = 0; nJ < aLinha.length; nJ++){
								   var nCmp = 0
								   var nPosCmp = false
								   while(nPosCmp == false && nCmp < nLenCmpVal){
									   nPosCmp = aCmpVal[nCmp][0] == aCampos[nJ];
									   nCmp++
								   }
								   if(nPosCmp){
									   --nCmp
									   aValores[nJ] = aCmpVal[nCmp][1];
								   }
							   }
							   
							   if(z==0){
								   aHeader.push({name:'Alterar'})
								   aHeader.push({name:'Excluir'})
							   }
							   aCols.push([])
							   nLenCols = aCols.length -1
							   aCols[nLenCols].push({field:'RECNO', value:'0#' + Trim((z+1).toString())/*.trim()*/ + "," + '"' + cTable + '"' + ",4"})
							   aCols[nLenCols].push({field:'RECNO', value:'1#' + Trim((z+1).toString())/*.trim()*/ + "," + '"' + cTable + '"' + ',5,true,"","",cCampoDefault'}) //Bot? Excluir
							   
							   nLenCmp--;
							   for(nJ = 0; nJ < nLenCmp; nJ ++){

								   var cCampo  = aCampos[nJ];//Nome da variavel
								   var cValor = aValores[nJ];//Valor do campo
								   var cTitulo = aDescri[nJ];//Descricao do campo
								   if(cCampo != ""){
									   if(z==0){
										   aHeader.push({name: cTitulo }) 
										   xHeader += cCampo + "|"
									   }
									   aCols[nLenCols].push({field:cCampo, value: cValor })  
									   
									   xCols += cValor
									   xCols += (nJ != nLenCmp - 1 ) ? "|" : ""
								   }

							   }
						   
						   }
					   }
				   }
			   }
			   //Limpa os campos da tela
			   fLimpaCmpGridGen(aCampos,cCampoDefault.replace(/\|/g,",")) 
		   } else {
			   if (cMostraSer == '0') break;
			   //--------------------------------------------------------------------
			   // Todos os campos da tabela											  
			   //--------------------------------------------------------------------
			   var aMatCol 	= aMatConv.split("|");
			   var aMatCampVal = aMatCampVal.split("|")
			   
			   for (var y = 0; y < aMatCol.length; y++) {
				   var aMatColAux = aMatCol[y].split("$");
				   if (aMatColAux[0] != 'Chk' && typeof aMatColAux[0] != 'undefined' && document.getElementById(aMatColAux[0]) != null && aMatColAux[1] != 'NIL') {
					   //--------------------------------------------------------------------
					   // Para cada campo da tabela le a matriz de valores retornados 		  
					   //--------------------------------------------------------------------
					   for (var h = 0; h < aMatCampVal.length; h++) {
						   var aMatCampValAux = aMatCampVal[h].split("$");
						   if (aMatColAux[1] == aMatCampValAux[0]) {
							   document.getElementById(aMatColAux[0]).value = aMatCampValAux[1];
							   break;
						   }
					   }
				   }
			   }
		   }                
	   }
   }
   //--------------------------------------------------------------------
   // Insere e limpa a linha												  
   //--------------------------------------------------------------------
   //fGetDadGen(0, cTable ,3,true,cTpAut,aMatCampVal.replace(/\|/g,","),cCampoDefault.replace(/\|/g,","));
   //IncLinhaTab(cTable, aMatCap, aMatBut, "", cCampoDefault, cTpAut, false, parseInt(cSeqCont,10));

   if (cTipoAcao == '0') {
	   aBtnFunc = "[{info:'Alterar',img:'refresh.gif',funcao:''},{info:'Excluir',img:'004.gif',funcao:''}]"
   }else{
	   aBtnFunc = "[{info:'Alterar',img:'refresh.gif',funcao:'fVisRecGen'},{info:'Excluir',img:'004.gif',funcao:'fGetDadGen'}]"
	   Ajax.open("W_PPLSETACMP.APW?cGrid=" + cTable + "&cHeader=" + xHeader + "&cCols=" + xCols +  "&aLinhas=" + aLinhas, { 
		   /*callback: CarregaLiberacao,*/
		   error: ExibeErro 
	   });
   }
   if(cTable == "TabProSer"){
		   oTabProSer = new gridData(cTable,'630','300')
				   //--------------------------------------------------------------------
				   //?Monta Browse 
				   //--------------------------------------------------------------------
				   oTabProSer.load({	fFunName:'',
									   nRegPagina:1,
									   nQtdReg:getField("nQtdReg"),
									   nQtdPag:getField("nQtdPag"),
									   lOverflow:true,
									   lShowLineNumber:true,
									   lChkBox:false,
									   aBtnFunc:aBtnFunc,
									   aHeader: aHeader,
									   aCols: aCols,
									   cColLeg:"",
									   aCorLeg:"",
									   cWidth:"770"});
   }else if(cTable == "TabSolSer"){
	   oTabSolSer = new gridData(cTable,'630','300')
				   //--------------------------------------------------------------------
				   //?Monta Browse 
				   //--------------------------------------------------------------------
				   oTabSolSer.load({	fFunName:'',
									   nRegPagina:1,
									   nQtdReg:getField("nQtdReg"),
									   nQtdPag:getField("nQtdPag"),
									   lOverflow:true,
									   lShowLineNumber:true,
									   lChkBox:false,
									   aBtnFunc:aBtnFunc,
									   aHeader: aHeader,
									   aCols: aCols,
									   cColLeg:"",
									   aCorLeg:"",
									   cWidth:"770"});
   }
   
   for(nI=0;nI<aLinhas.length;nI++){
	   if(cTable == "TabProSer"){
		   oTabProSer.setLinhaCor(aLinhas[nI] ,'colfixeInd','#E49494')
	   }else{
		   oTabSolSer.setLinhaCor(aLinhas[nI] ,'colfixeInd','#E49494')
	   }
   }
   e = eval("o" + cTable)
   if(typeof e != "string"){
	   if (e.aCols.length > 0){
		   oTable = e.getObjCols();
		   if (oTable != null && cSeqCont != '0')
			   setTC(oTable.rows[oTable.rows.length-1].cells[0],parseInt(cSeqCont,10)+" ");
	   }
   }
}
var nRecnoX = 0;
//--------------------------------------------------------------------
// Monta tabela de procedimento e quantidades linha a linha (autorizacao) 
//--------------------------------------------------------------------
function fMontItensInt(cTp, cTable,nRecno) {
   cTpR 		 	 = cTp;
   cTableR 	 	 = cTable;
   var lResult 	 = false;   
   var cRda 	 	 = document.getElementById('cRda').value;                  
   var cRdaSolT 	 = document.getElementById('cRdaSolT').value;
   var cCodLoc		 = document.getElementById('cCodLoc').value;
   var cQueryString = "&cRda=" + ( (cChavAut != "" && cRdaSolT!="") ? cRdaSolT : cRda ) + "&cCodLoc=" + ( (cChavAut != "" && cRdaSolT!="") ? "" : cCodLoc );
   var cChavAut 	 = document.getElementById("cNumAut").value;
   var dDatInt		 = document.getElementById("dDatInt").value;
   var dDatAlt		 = document.getElementById("dDatAlt").value;
   var lExistdtExe  = true;
   var cGralau      = document.getElementById("cGralau").value;
   var cRegInt      = document.getElementById('cRegInter').value
   
   if (wasDef( typeof(dDtExePro) ) ){	
   var dDtExePro    = document.getElementById("dDtExePro").value;

   var dDatInicio 	= new Date(dDtExePro.substr(6,4)+"/"+dDtExePro.substr(3,2)+"/"+dDtExePro.substr(0,2))
   var dDatFim 	= new Date(dDatInt.substr(6,4)+"/"+dDatInt.substr(3,2)+"/"+dDatInt.substr(0,2))
   }else{
	   lExistdtExe = false;
   }

   //Desabilita botoes
   setDisable("bIncTabSolSer",true);
   setDisable("bSaveTabSolSer",true); 

   //--------------------------------------------------------------------
   //³ Verifica se o paciente ja foi internado								  ³
   //--------------------------------------------------------------------
   if (cChavAut != "") {
	   if (lExistdtExe) {
		   if (dDatInicio < dDatFim) {
			   alert("Data da evolução anterior a data de internação! - ("+dDatInt+")");
			   //Habilita botoes
			   setDisable("bIncTabSolSer",false);
			   return;
		   }        
	   }
	   if (cGralau != '1'){
		   if (dDatAlt.replace(/  /g,"").replace('//',"") != '') {
			   alert("Data da alta já informada!\nSomente disponível para visualização! - ("+dDatAlt+")");
			   //Habilita botoes
			   setDisable("bIncTabSolSer",false);
			   return;
		   }        
	   }
   
   }   
   //--------------------------------------------------------------------
   // Monta conteudo das tabelas solicitacao e execucao					  
   //--------------------------------------------------------------------
   if (wasDef( typeof(oTabProSer) ) ){
	   aMatAux = [["TabSolSer",oTabSolSer],["TabProSer",oTabProSer]];
   }else{
	   aMatAux = [["TabSolSer",oTabSolSer]];
   }
   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   cStringEnvTab = "";
   aMat = aMatAux;
   for (var i = 0; i < aMat.length; i++) {
	   aMatAux = aMat[i]
	   //Se o grid foi preenchido
	   if(typeof aMatAux[1] != "string" && aMatAux[1].aCols.length > 0){
		   //Recupera os dados do grid
		   oTable = aMatAux[1].getObjCols();
					   
		   fMontMatGerInt('A', aMatAux[0]);
		   
		   aMatCampAux = aMatCap.split("|");
		   for (var y = 1; y < oTable.rows.length; y++) {
			   nf = 0;                  
			   cStringEnvTab += "cSeq@"+getTC(oTable.rows[y].cells[0])+"$";
			   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {
			   
				   cCampo = aMatCampAux[x - 2].split("$")[1];
				   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
					   celula = oTable.rows[y].cells[x + 1 - nf];
					   
					   if (typeof celula.value == 'undefined' || celula.value == '')
							conteudo = getTC(celula);
					   else conteudo = celula.value;	
					   
					   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
				   }
				   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;
			   }      
			   cStringEnvTab += "|";
		   }
	   }
   }
   //--------------------------------------------------------------------
   // Define parametros para uso na funcao de resultado					  
   //--------------------------------------------------------------------
   fMontMatGerInt(cTp, cTable);
   //--------------------------------------------------------------------
   // Matriz de campos													  
   //--------------------------------------------------------------------
   var aMatCol = aMatCap.split("|");
   e = eval("o"+cTable)
   if (e != "" && e.aCols.length > 0){
	   var oTable  = e.getObjCols();
   }else{
	   var oTable = null
   }
   //--------------------------------------------------------------------
   // Tratamento inclusao ou alteracao									  
   //--------------------------------------------------------------------
   if (cTp == 'I' || cTp == 'A') {
	   switch (cTable) {
		   case "TabSolSer":
			   if (document.getElementById('cQtdSSol').value == "" || document.getElementById('cQtdSSol').value == "0") {
				   alert('Informe a quantidade de Serviço');
				   document.getElementById('cQtdSSol').focus();
				   //Habilita botoes
				   setDisable("bIncTabSolSer",false);
				   return;
			   }               
			   if (cTp == 'I')
				   document.getElementById('cQtdAutSSol').value = document.getElementById('cQtdSSol').value;
			   break;   
		   case "TabProSer":
			   if (document.getElementById('cQtdSPro').value == "" || document.getElementById('cQtdSPro').value == "0") {
				   alert('Informe a quantidade de Serviço');   
				   document.getElementById('cQtdSPro').focus();
				   //Habilita botoes
				   setDisable("bIncTabSolSer",false);
				   return;
			   }
			   //--------------------------------------------------------------------
			   // Atribui qtd sol para qtd aut										  
			   //--------------------------------------------------------------------
			   if (cTp == 'I')
				   document.getElementById('cQtdSAutPro').value = document.getElementById('cQtdSPro').value;
			   //--------------------------------------------------------------------
			   // Verifica se o campo tem conteudo									  
			   //--------------------------------------------------------------------
			   if ( document.getElementById('cResAutPro').value == '') {
				   alert('Informe o Responsável pela Autorização');     
				   document.getElementById('cResAutPro').focus();					
				   //Habilita botoes
							   setDisable("bIncTabSolSer",false);
				   return;
			   }	
			   break;
	   }
	   //--------------------------------------------------------------------
	   // Verifica duplicidade												   
	   //--------------------------------------------------------------------
	   var nCol 		  = 0;
	   if (typeof oTable != "string" && oTable != null){
		   var nQtdLinTab  = oTable.rows.length;
	   }else{
		   var nQtdLinTab = 0
	   }
	   var cString 	  = "1|";
	   var cContChave    = document.getElementById(cChave).value;
	   if (cContChave == "") {
		  alert("Serviço não informado");
		  document.getElementById(cChave).focus();
		  //Habilita botoes
		  setDisable("bIncTabSolSer",false);
		  return;
	   }
	   //--------------------------------------------------------------------
	   // Monta a sequencia e matriz de retorno								   
	   //--------------------------------------------------------------------
	   if (document.getElementById(aMatAux[1]) != null) {
		   if (typeof document.getElementById(aMatAux[1]).length != 'undefined') {
			   if (cTp == 'I') 
					cString = String(document.getElementById(aMatAux[1]).length + 1) + "|";
			   else cString = String(document.getElementById(aMatAux[1]).length) + "|";
		   }
	   }
	   //--------------------------------------------------------------------
	   // Cbos do executante ou solicitante									  
	   //--------------------------------------------------------------------
	   cCbos = "";
	   if (cChavAut == '') {
		   cCbos = document.getElementById("cCbosSol").value;
	   }
	   //--------------------------------------------------------------------
	   // Monta envio das variaveis de sessao GET								  
	   //--------------------------------------------------------------------
	   cQueryString =	"&cRda="+( (cChavAut != "" && cRdaSolT != "") ? cRdaSolT : cRda )+
					   "&cCodLoc="+( (cChavAut != "" && cRdaSolT != "") ? "" : cCodLoc )+
					   "&cProSol="+document.getElementById('cProSol').value+
					   "&cCid="+document.getElementById('cCid').value+            
					   "&cNumAut="+cChavAut+
					   "&cCbos="+cCbos+
					   "&cChvBD6="+document.getElementById('cChvBD6').value+
					   "&cProExe="+document.getElementById('cProfSolT').value+
					   "&cOpeSolT="+document.getElementById('cOpeSolT').value+
					   "&cAteRN="+document.getElementById('cAtenRN').value+
					   "&cCarSolicit="+document.getElementById('cCarSolicit').value+
					   "&cRegInt="+cRegInt+
					   "&cChkPro="+( (cChavAut != "" && cRdaSolT != "") ? '1' : '0' );
	   
	   if (document.getElementById("cIndCliSol") != null) {
		   cQueryString += "&cIndCli="+(document.getElementById('cIndCliSol').value == "" ? "" : "1");
	   }
			   
	   cCamGer = "";
	   for (var i = 0; i < aMatCol.length; i++) {
		   var aMatColAux = aMatCol[i].split("$");
		   cCampo = document.getElementById(aMatColAux[0]);
		   if (typeof cCampo != 'undefined' && cCampo != null && aMatNGet.indexOf(aMatColAux[1])==-1) {
			   cQueryString += "&" + aMatColAux[1] + "=" + cCampo.value;
		   }
	   }
	   //--------------------------------------------------------------------
	   // Validacoes															  
	   //--------------------------------------------------------------------
	   if (cTable != "TabProSer") { 
	   
		   for (var i = 0; i < nQtdLinTab; i++) {
			   for (var y = 0; y < aMatCol.length; y++) {
				   var aMatColAux = aMatCol[y].split("$");
				   if (aMatColAux[0] == cChave) {
					   nCol = y;
					   break;
				   }	
			   }
			   if (cTp == 'A') nCol++;			 
			   //--------------------------------------------------------------------
			   // Verfica se existe um registro igual na tabela						  
			   //--------------------------------------------------------------------
			   lResult = false;   
			   if ( i+1 != parseInt(nRecno) && getTC(oTable.rows[i].cells[nCol+2]) == cContChave) {
				   modalBS("Atenção", "<p>Este procedimento já foi informado, utilize o campo quantidade</p>", "@Fechar~closeModalBS();", "white~#960000", "large");
				   //Habilita botoes
				   setDisable("bIncTabSolSer",false);
				   return;
			   }
		   }
		   
		   //--------------------------------------------------------------------
		   // verifica se algum campo foi alterado			   					   
		   //--------------------------------------------------------------------
		   cSt = "0";
		   if (cTp == 'A') {
			   //--------------------------------------------------------------------
			   // Verifica se algum campo que necessita de checar a regra novamente foi alterado
			   //--------------------------------------------------------------------
			   lResult = true;
			   var nLenTable = oTable.rows[nRecno - 1].cells.length -1;
			   for (var y = 2; y < nLenTable ; y++) {
				   var aMatColAux = aMatCol[y - 2].split("$");
				   cCampo = document.getElementById(aMatColAux[0]);
				   if ( getTC(oTable.rows[nRecno - 1].cells[y]) != cCampo.value) {
					   cSt = "1";
					   if (aValAlt.indexOf(aMatColAux[0]) != -1) lResult = false;
				   }
			   }
		   }
		   
	   } else if (cTp == 'A') {
		   //--------------------------------------------------------------------
		   // Verifica se alguma campo que necessita de checar a regra novamente foi alterado
		   //--------------------------------------------------------------------
		   for (var i = 1; i < nQtdLinTab; i++) {
			   cSt = "0";
			   if (oTable.rows[i].style.backgroundColor != "") {
				   lResult = true;
				   for (var y = 2; y < oTable.rows[i].cells.length; y++) {
					   var aMatColAux = aMatCol[y - 2].split("$");
					   cCampo = document.getElementById(aMatColAux[0]);
					   if ( getTC(oTable.rows[i].cells[y]) != cCampo.value) {
						   cSt = "1";
						   if (aValAlt.indexOf(aMatColAux[0]) != -1) lResult = false;
					   }
				   }
			   }
		   }
	   }                 
	   cString += aMatRet + "|" + cStringEnvTab + "|";    
	   nRecnoX = nRecno;
	   //--------------------------------------------------------------------
	   // Executa o metodo													  
	   //--------------------------------------------------------------------
	   if (!lResult) Ajax.open("W_PPLSAUTITE.APW?cString=" + cString + cQueryString, { 
						   callback: CarregaMontItensInt,
						   error: ExibeErroInt 
					  });
   }

   e = eval("o"+cTableR)

   if(typeof e != "string" && e.aCols.length > 0){
	   var oTable 	= e.getObjCols();
   }else{
	   var oTable = null
   }
   
   var aMatC	= aMatCap.split("|");
   var nPosPro = 0;
   var nPosQtd = 0;
   //--------------------------------------------------------------------
   // Procura o campo correspondente										  
   //--------------------------------------------------------------------
   for (var y = 1; y < aMatC.length; y++) {

		  if (aMatC[y].indexOf('cCodPro') != -1) nPosPro = y + ( (cTpR=='I') ? 1 : 2 ) ;
		  
		  if (aMatC[y].indexOf('cQtdSSol') != -1) {
			  nPosQtd = y + ( (cTpR=='I') ? 1 : 2 );
			  break;
		  }	
   }
   //--------------------------------------------------------------------
   // Calculo de valores primeiro campo recebe segundo campo o valor do	  
   // campo e pego da tabela												  
   //--------------------------------------------------------------------
   if (typeof aCalVal != 'undefined' && aCalVal != null) {
	   var aCalValAux = aCalVal.split("|");
	   for (var i = 0; i < aCalValAux.length; i++) {
		   if (aCalValAux[i] != "") {
			   var aMatCamp = aCalValAux[i].split("$");
			   //--------------------------------------------------------------------
			   // Para pegar os campos de informacao e recebimento					  
			   //--------------------------------------------------------------------
			   if (typeof aMatCamp[0] != 'undefined' && aMatCamp[0] != null && typeof aMatCamp[1] != 'undefined' && aMatCamp[1] != null) {
				   //--------------------------------------------------------------------
				   // Descobrir a coluna na tabela										  
				   //--------------------------------------------------------------------
				   for (var x = 0; x < aMatCol.length; x++) {
					   var aMatColAux = aMatCol[x].split("$");
					   if (aMatColAux[0] == aMatCamp[1]) {
						   nCol = x;
						   break;
					   }
				   }
				   if (cTp != 'I') nCol++;
				   //--------------------------------------------------------------------
				   // atualiza os campos com base no valor da tabela						  
				   //--------------------------------------------------------------------
				   var nValor = 0;
				   var cCampo = document.getElementById(aMatCamp[0]);
				   for (var x = 1; x < oTable.rows.length; x++) {
					   nValor += parseInt( getTC(oTable.rows[x].cells[nCol + 1]).replace(/\D/g, ""));
				   }
				   cCampo.value = MaskMoeda(nValor);
			   }
		   }
	   }
   }
}

//--------------------------------------------------------------------
// Pega o retorno do processamento										  
//--------------------------------------------------------------------
function CarregaMontItensInt(v) {                       
   var lAto 	 = false;                 
   var aResult  = v.split("|");
   var cTitulo  = aResult[0]; 				//Titulo do resultado autorizado,negado ou autorizado parcial
   var aMatRet  = aResult[1].split("~"); 	//Retorno para grid campos e resultado do campo
   var cTexto 	 = aResult[5]; 				//Procedimento autorizados ou negados resultado
   var cLembr = aResult[6] == "0" ? "" : aResult[6]; //Lembrete do Procedimento na Tabela Padrão (BR8_LEMBRE)
   
   //Para utilizar esta versão do JUSER, é necessário atualizar os fontes
   //PLSMFUN, PPLMFUN, WSPLSXFUN e WSCLIENT_WSPLSXFUN do dia 08-07-16 ou superior. 
   var cAlerta  = aResult[7];				 //Alertas do procedimento 
   var cTitComp = aResult[8];				//complemento do titulo 
   var cTipProc = aResult[9];				//Tipo de Procedimento 
   
   setDisable('bIncTabSolSer', false); 
   
   if (typeof cTitComp != 'undefined') { 
	   
	   if (cTitulo == '1') { 
	   
		   cTitulo = cTitComp;
	   
	   } else {
		   cTitulo += cTitComp;
	   }
   } 
   
   //--------------------------------------------------------------------
   // Alimentar campos de retorno											  
   //--------------------------------------------------------------------
   for (var i = 0; i < aMatRet.length; i++) {
	   aRetAux = aMatRet[i].split(";");
	   cCampo  = document.getElementById(aRetAux[0]);

	   if (typeof cCampo != 'undefined' && cCampo != null) {
		   cCampo.value = aRetAux[1];
	   }	
   }
   //--------------------------------------------------------------------
   // Se vai incluir ou alterar a linha campo alimentado pela aMatRet 	  
   //--------------------------------------------------------------------
   if (typeof cTableR != 'undefined' && typeof aMatCap != 'undefined' && typeof aMatBut != 'undefined') {
	   cCampo = document.getElementById("cStatusAut");
	   if (typeof cCampo != 'undefined') {

		   if (cCampo.value == '5') {
			   lAto = true;
			   cCampo.value = '1';
		   }

		   if (cTpR == 'I') {
		   
			   fGetDadGen(0, cTableR ,3,true,cCampo.value,"",cCampoDefault.replace(/\|/g,","));
			   
			   
			   var cTpAut 	  	 = "1";

			   var cCodPad = document.getElementById("cCodPadSSol").value;

			   var cCodPro 	 = document.getElementById("cCodProSSol").value;
			   var nQtdAut 	 = document.getElementById("cQtdAutSSol").value;
			   var nQtdSol 	 = document.getElementById("cQtdSSol").value;
			   var cStatus 	 = document.getElementById("cStatusAut").value;

			   //Se for um pacote, adiciona todos os itens do mesmo.
			   Ajax.open("W_PPLSITEPCT.APW?cCodPct=" + (cCodPad + cCodPro) + "&qtdAutSSol=" + nQtdAut + "&cQtdSSol=" + nQtdSol +"&cStatusAut=" +cStatus  + "&cTpAut=" + cTpAut, {
				   callback: AdicionProcRelSolPct,
				   error: ExibeErro
			   });

			   e = eval("o"+"TabSolSer")
			   if(typeof e != "string" && e.aCols.length > 0){
				   var oTable 	= e.getObjCols();
			   }else{
				   var oTable = null
			   }

			   var aMatC	= aMatCap.split("|");

			   if(document.getElementById('cQtdDSol') != 'undefined')
				   fAtualizaDiaria("I", nQtdSol, aMatC, oTable, cTipProc, cCodPro, "0");

		   } else{ 
			   fGetDadGen(nRecnoX, cTableR ,4,true,cCampo.value,"",cCampoDefault.replace(/\|/g,","));

			   e = eval("o"+"TabSolSer");

			   if(typeof e != "string" && e.aCols.length > 0){
				   var oTable 	= e.getObjCols();
			   }else{
				   var oTable = null
			   }

			   var cCodPro 	 = document.getElementById("cCodProSSol").value;
			   var nQtdAut 	 = document.getElementById("cQtdAutSSol").value;
			   var aMatC	= aMatCap.split("|");

			   if(document.getElementById('cQtdDSol') != 'undefined')
				   fAtualizaDiaria("A", nQtdSol, aMatC, oTable, cTipProc, cCodPro, nRecnoX);
		   } 
		   //--------------------------------------------------------------------
		   // Retorno o valor original											  
		   //--------------------------------------------------------------------
		   cCampo.value == "0";
	   }
   } 
   //--------------------------------------------------------------------
   // Atualiza quantidade de diarias solicitadas							  
   //--------------------------------------------------------------------
   e = eval("o"+cTableR)
   if(typeof e != "string" && e.aCols.length > 0){
	   var oTable 	= e.getObjCols();
   }else{
	   var oTable = null
   }
	   
   var aMatC	= aMatCap.split("|");
   var nPosPro = 0;
   var nPosQtd = 0;
   //--------------------------------------------------------------------
   // Procura o campo correspondente										  
   //--------------------------------------------------------------------
   for (var y = 1; y < aMatC.length; y++) {

		  if (aMatC[y].indexOf('cCodPro') != -1) nPosPro = y + ( (cTpR=='I') ? 1 : 2 ) ;
		  
		  if (aMatC[y].indexOf('cQtdSSol') != -1) {
			  nPosQtd = y + ( (cTpR=='I') ? 1 : 2 );
			  break;
		  }	
   }
   //--------------------------------------------------------------------
   // Atualiza campo de diaria											  
   //--------------------------------------------------------------------
   if(typeof cTpPD == "undefined") cTpPD = ''; //se não existir a variavel eu crio (nova prorrogação de internacao)
   if ( nPosPro != 0 && nPosQtd != 0 && oTable != null) {              
   
	   /*if(wasDef( typeof cTp) && (cTp.value == 11)){
	   document.getElementById("cQtdDSol").value = 0;
	   }*/

	   for (var y = 0; y < oTable.rows.length; y++) {
		   //--------------------------------------------------------------------
		   // Somente se nao for negado e o campo tiver o tpproc igual a 4		  
		   //--------------------------------------------------------------------
		   if ( oTable.rows[y].className != "TextoNegPeq" && cTpPD.indexOf( getTC(oTable.rows[y].cells[nPosPro]).replace( /\s*$/, "" ) ) != -1 ) {
				  document.getElementById("cQtdDSol").value = parseInt(document.getElementById("cQtdDSol").value ,10 ) + parseInt( getTC(oTable.rows[y].cells[nPosQtd]) ,10 );
		   }
	   }
   }	
   //--------------------------------------------------------------------
   // Mostra o resultado modal so mostra se for negado					  
   //--------------------------------------------------------------------
   if ( cTitulo != "1"  && cTitulo != ""  || cAlerta != 'undefined' && cAlerta != "") { 
	   
	   if (cAlerta != "") {
		   cTexto += cAlerta;
		   ShowModal(cTitulo, cTexto, false, false, true, undefined, (cLembr != "" ? "@Fechar~RepShowModal('Lembrete:', '" + cLembr + "');" : ""));
	   } else {
		   ShowModal(cTitulo, cTexto, undefined, undefined, undefined, undefined, (cLembr != "" ? "@Fechar~RepShowModal('Lembrete:', '" + cLembr + "');" : ""));
	   }
	   
   } else {
	   if (cLembr != "" && cLembr != "0") {
		   ShowModal("Lembrete", cLembr);
	   }
   }

   //--------------------------------------------------------------------
   // Se for pagamento no ato												   
   //--------------------------------------------------------------------
   if ( lAto )	alert("Realizar o pagamento na Operadora.\nPara este procedimento deve ser efetuado o pagamento no ato.");
}

//--------------------------------------------------------------------
// Processa 															  
//--------------------------------------------------------------------
function fProcFormInt(formulario) {
   var lDigOff = false;
   var lProrroga = false;
   var cDataServ = '';
   var cDataCmp = '';
   var nDataSelec = 0;
   
   if ($("#cTipoOrigem").val() != undefined && ($("#cTipoOrigem").val() != "" ) )  //r7
   {
	   lDigOff = true;
	   modalBS('<i class="fa fa-exclamation-triangle" style="font-weight: bold; color: #000; text-shadow: 0 1px 0 #fff; filter: alpha(opacity=20); opacity: .2;"></i>&nbsp;&nbsp;&nbsp;Alerta', '<p>Tem certeza que deseja finalizar a guia?</p>', "@Sim, conclui a digitação!~confirmaInt('1')@Não, desejo continuar posteriormente!~confirmaInt('2');", "white~ #f8c80a", "large");
   } else {	
   document.forms[0].action = "W_PPLPROCGUI.APW";
   }
   
   if (!lDigOff){
	   // Valida formulario													   
	   //--------------------------------------------------------------------
	   if( !valida() ) return;
	   //--------------------------------------------------------------------
	   // Verfica se foi digitado algum procedimento							   
	   //--------------------------------------------------------------------
	   var lVld = false;
	   if (document.getElementById("cNumAut").value=="") {
		   if(typeof oTabSolSer == "string"){
			   lVld = true;
			   cMsg = 'Solicitação';
		   }	
	   } else {
		   cMsg = 'Prorrogação';
		   lProrroga = true;
		   if(typeof oTabProSer == "string"){
			   lVld = true;
		   } else {           
			   lVld = true;
			var oTable  = oTabProSer.getObjCols();
		   if(oTable == null){
			 alert("Informe pelo menos uma prorrogação");
			 return;
		   }
			   for (var y = 0; y < oTable.rows.length; y++) {
				   lVld = false;
				   break                                                
			   }        	
		   }	
	   }	 	                                   
	   //--------------------------------------------------------------------
	   // aviso																   
	   //--------------------------------------------------------------------
	   if (lVld) {
		   alert("Informe pelo menos um serviço para a " + cMsg);
		   return;
	   }
	   
	   // valida a data do campo data sugerida(campo 021) 
	   cDataCmp    = document.getElementById('dDSPrAH').value;
	   nDataSelec  = parseInt(cDataCmp.split("/")[2].toString() + cDataCmp.split("/")[1].toString() + cDataCmp.split("/")[0].toString());
	   cDataServ = document.getElementById('cDataServ');

	   if(nDataSelec < parseInt(cDataServ.value)){

		   ShowModal("Atenção", "A data sugerida (campo 021) não pode ser menor do que a data atual!");
		   document.getElementById('dDSPrAH').focus();
		   return;
	   } 
	   
	   //--------------------------------------------------------------------
	   // Monta conteudo das tabelas solicitacao e execucao					  
	   //--------------------------------------------------------------------
	   if (document.getElementById("cNumAut").value=="")
			aMatAux = "TabSolSer";
	   else aMatAux = "TabProSer";
	   //--------------------------------------------------------------------
	   // Carrega as linhas das tabelas para processamento					   
	   //--------------------------------------------------------------------
	   cStringEnvTab = "";                                     
	   var nSeq 	  = 0;
	   //--------------------------------------------------------------------
	   // Pega a sequencia de maior numero
	   //--------------------------------------------------------------------
	   if (document.getElementById("cNumAut").value!="") {
		   var aMatAnt = "TabSolSer|TabProSer";
		   aMat 		= aMatAnt.split("|");
	   
		   for (var i = 0; i < aMat.length; i++) {
			   e = eval("o" + aMat[i])
			   oTable = e.getObjCols();
			   
			   for (var y = 1; y < oTable.rows.length; y++) {
				   
					   if ( oTable.rows[y].innerHTML.indexOf('chkbox') == -1) {     
					   if ( parseInt( getTC(oTable.rows[y].cells[0]) , 10 ) > nSeq ) {
						   nSeq = parseInt( getTC(oTable.rows[y].cells[0]) , 10 );
					   }	
				   }            	
			   }
		   }        
	   } 
	 
	   aMat = aMatAux.split("|");
	   //--------------------------------------------------------------------
	   // Monta envio para processamento
	   //--------------------------------------------------------------------
	   for (var i = 0; i < aMat.length; i++) {
		   e = eval("o" + aMat[i]);
		   oTable = e.getObjCols();
		   
		   fMontMatGerInt('A', aMat[i]);
		   
		   aMatCampAux = aMatCap.split("|");
		   for (var y = 0; y < oTable.rows.length; y++) {
			   nf = 0;                  
			   celula = oTable.rows[y].cells[4];
			   if ((!lProrroga) || (lProrroga && ( isEmpty(getTC(celula))  ))){
			   
				   nSeq = nSeq + 1;
								   
				   cStringEnvTab += "cSeq@" + parseInt( nSeq , 10 ) + "$";
				   
				   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {
				   
					   cCampo = aMatCampAux[x - 2].split("$")[1];
					   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
						   celula = oTable.rows[y].cells[x + 1 - nf];
						   
						   if (typeof celula.value == 'undefined' || celula.value == '')
								conteudo = getTC(celula);
						   else conteudo = celula.value;	
						   
						   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
					   }
					   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;
					 }      
				   cStringEnvTab += "|";
			   }
		   }
	   }           
	   if (cStringEnvTab == ''){
		   alert("Informe pelo menos um serviço para a " + cMsg);
		   return;
	   }
	   document.getElementById("cMatTabES").value = cStringEnvTab + "|";
	   //--------------------------------------------------------------------
	   // Trata Campos														  
	   //--------------------------------------------------------------------                   
	   setDisable("cCbosSol",false);
	   setDisable("cCnpjSolT",false);
	   setDisable("cNomeSolT",false);
	   setDisable("cCnpjCpfSol",false);
	   setDisable("cNomeRdaSol",false);
	   
	   setDisable("bIncTabProSer",true);
	   setDisable("bconfirma",true);
	   setDisable("bimprimir",false);
	   setDisable("bcomplemento",false);
	   setDisable("bAnexoDoc",false);
	   //--------------------------------------------------------------------
	   // Metodo de envio de formulario pelo ajax								  
	   //--------------------------------------------------------------------
	   Ajax.send(formulario, { 
			   callback: CarregaProcFormInt,
			   error: ExibeErro 
	   });
	   document.forms[0].action = "";
   }
}  

//--------------------------------------------------------------------
// Pega o retorno do processamento										  
//--------------------------------------------------------------------
function CarregaProcFormInt(v) {
   var aResult = v.split("|");
   var cTexto  = aResult[10]; 				//Procedimento autorizados ou negados resultado
   var cTitulo = aResult[11]; 				//Titulo do resultado autorizado,negado ou autorizado parcial
   var cMostra = aResult[12];
   var aSenPro = aResult[13].split("@");	//Senhas por procedimento
   var cAutori = aResult[0];        
   var aDadInt = aResult[4].split("*"); 	//Dados da Internacao   
   var cSenha  = "";

   //Para exibição de senha na prorrogação de internção
   if (document.getElementById("cPLPRGSN") != null && document.getElementById("cPLPRGSN").value == "1") cSenha = "<br/> Senha: " + aResult[1];
   //--------------------------------------------------------------------
   // Informacoes	da autorizacao											  
   //--------------------------------------------------------------------
   if (aResult[0] != "") document.getElementById("cNumAut").value = aResult[0].substr(0, 4) + "." + aResult[0].substr(4, 4) + "." + aResult[0].substr(8, 2) + "-" + aResult[0].substr(10, 8); //Numero da autorizacao
   //--------------------------------------------------------------------
   // Alimenta campos														  
   //--------------------------------------------------------------------
   document.getElementById("cSenha").value   =  aResult[1]; //Senha
   document.getElementById("dDtAut").value   = aResult[2]; //Data da Autorizacao
   document.getElementById("dDtValid").value = aResult[3]; //Validade da Senha
   //--------------------------------------------------------------------
   // Dados da autorizacao												  
   //--------------------------------------------------------------------
   if (aDadInt.length > 0 && aDadInt[0] == 'I') {
	   document.getElementById("cObs").value			= aDadInt[1];
	   document.getElementById("dDPrAH").value 		= aDadInt[2];
	   document.getElementById("cQtdDAut").value		= aDadInt[3];
	   document.getElementById("cTpAcom").value		= aDadInt[4];
	   document.getElementById("cCnpjCpfAut").value	= aDadInt[5];
	   
	   if (aDadInt.length >= 7){
		   document.getElementById("cNomeRdaAut").value	= aDadInt[6];
	   }
	   
	   if (aDadInt.length >= 8){
		   document.getElementById("cCnesAut").value  		= aDadInt[7];
	   }
	   
	   if (wasDef( typeof(cDesAcomPro) ) && aDadInt.length >= 9   ){
		   document.getElementById("cDesAcomPro").value	= aDadInt[8];
	   }
   //--------------------------------------------------------------------
   // Atualiza procedimentos da prorrogacao com a senha					  
   //--------------------------------------------------------------------
   } else if (aDadInt[0] == 'P') {
	   var oTable  	= oTabProSer.getObjCols();
	   var nQtdLinTab  = oTable.rows.length;             
	   var nQtdCell 	= oTable.rows[0].cells.length;
	   var nPosChk 	= 1;
	   var nPosSenha	= 0;
	   var nPosQtdAut	= 0;
	   //--------------------------------------------------------------------
	   // Verifica posicao da celula
	   //--------------------------------------------------------------------
	   for (var i = 0; i < nQtdCell; i++) {
		   nPosSenha 	= 4;
	   }
	   //--------------------------------------------------------------------
	   // Verifica nas linhas do grid qual procedimento nao tem a senha		  
	   //--------------------------------------------------------------------
	   nSen = 0
	   if (nPosSenha != 0) {//&& nPosQtdAut != 0) 
		   for (var i = 0; i < nQtdLinTab; i++) {
			   if ( isEmpty(getTC(oTable.rows[i].cells[nPosSenha]))  ) {
				   setTC(oTable.rows[i].cells[nPosSenha],aSenPro[nSen++]);
			   }
		   }
	   }
   }
   
   //--------------------------------------------------------------------
   // Para mostrar o numero da autorizacao								  
   //--------------------------------------------------------------------
   if (cTexto == "") {
	   cTexto = "<center>" + document.getElementById("cNumAut").value + cSenha + "</center>";
   } else {
	   cTexto = "<center>" + document.getElementById("cNumAut").value + cSenha+ "</center><br>" + cTexto;
   }
   //--------------------------------------------------------------------
   // Mostra o resultado modal											  
   //--------------------------------------------------------------------
   var cFuncDoc = "";
   if(wasDef( typeof cTp) && (cTp.value == 1 || cTp.value == 2 || cTp.value == 3 || cTp.value == 7 || cTp.value == 8 || cTp.value == 9 || cTp.value == 11 )){
		   cFuncDoc =  "@Anexar Documentos~anexoDocGui('" + aResult[0] + "')";
   }
   ShowModal(cTitulo, cTexto, false, false, false, "actionVoltar();"+cFuncDoc);
}  


//--------------------------------------------------------------------
// Monta as rdas														  
//--------------------------------------------------------------------
function fRdaInt(cRda, cCodLoc) {
   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
	   callback: CarregaRdaInt, 
	   error: ExibeErro 
   });
}
//--------------------------------------------------------------------
// Monta campos conforme processamento da rdas							  
//--------------------------------------------------------------------
function CarregaRdaInt(v) {
   var aResult  = v.split("|");
   var aResuEsp = (aResult[24].substring(1)).split("~");
   var aProsol  = aResult[19].split("@");
   //--------------------------------------------------------------------
   // Prepara para desabilitar solicitacao ou execucao					  
   //--------------------------------------------------------------------
   lHab = (document.getElementById("cNumAut").value == "");
   //--------------------------------------------------------------------
   // Local de atendimento												  
   //--------------------------------------------------------------------
   document.getElementById("cCodLoc").value = aResult[22];
   //--------------------------------------------------------------------
   // Solicitacao															   
   //--------------------------------------------------------------------
   if (lHab) {
	   //--------------------------------------------------------------------
	   // Dados da Autorizacao de Solicitacao									   
	   //--------------------------------------------------------------------
	   //document.getElementById("dDtAut").value			= "";
	   document.getElementById("cSenha").value			= "";
	   document.getElementById("dDtValid").value		= "";
	   //--------------------------------------------------------------------
	   // Dados do Solicitante												   
	   //--------------------------------------------------------------------
	   document.getElementById("cRegAns").value		= aResult[1];
	   document.getElementById("cCnpjCpfSol").value	= aResult[2];
										   
	   if (document.getElementById("cCnpjSolT") != null) {
		   document.getElementById("cCnpjSolT").value	= aResult[2];  
	   }
	   document.getElementById("cNomeRdaSol").value 	= aResult[3];     
	   
	   if (document.getElementById("cNomeSolT") != null) {
		   document.getElementById("cNomeSolT").value 		= aResult[3];
	   }
		  
	   //--------------------------------------------------------------------
	   // Dados do solicitante												   
	   //--------------------------------------------------------------------
		  document.getElementById("cNomeRdaSol").value 	= aResult[3];
	   document.getElementById("cCodSigSol").value	= aResult[16];
	   document.getElementById("cNumCrSol").value 	= aResult[17];
	   document.getElementById("cEstSigSol").value	= aResult[18];
	   if (aResult[14].toUpperCase() == 'F') {
		   if(aProsol[1]!= undefined && aProsol[1].trim() != "") {
			   document.getElementById("cProSol").value = aProsol[1];
			   document.getElementById("cProSolDesc").value = aProsol[0];
			}
	   }
	   //--------------------------------------------------------------------
	   // Monta especialidades												   
	   //--------------------------------------------------------------------
	   setTC(document.getElementById("cCbosSol"),"");
	   var e = document.getElementById("cCbosSol");
	   for (var i = 0; i < aResuEsp.length; i++) {
		   var aIten = aResuEsp[i].split("$");
		   e.options[i] = new Option(aIten[1], aIten[0]);
	   }
	   //--------------------------------------------------------------------
	   // Se e fisica ou juridica												   
	   //--------------------------------------------------------------------
	   if (aResult[14].toUpperCase() == 'F') {
		   setDisable('BIncSol',true);
		   setDisable('BHelp15',true);
	   } else {
		   setDisable('BIncSol',false);
		   setDisable('BHelp15',false);
	   }
   }	
   
   //--------------------------------------------------------------------
   // Ajusta o compo do executante e formata a tela para a solicitacao	   
   //--------------------------------------------------------------------
   fAjusFormInt(lHab);
}

//--------------------------------------------------------------------
// Monta contratado solicitado											  
//--------------------------------------------------------------------
function fRdaSolT(cNomeSolT) {
   //--------------------------------------------------------------------
   // Executa o metodo													  
   //--------------------------------------------------------------------
   Ajax.open("W_PPSDADRSOL.APW?cNomeSolT=" + cNomeSolT, { 
	   callback: CarregaRdaSolT, 
	   error: ExibeErro 
   });
}
//--------------------------------------------------------------------
// Carrega campos conforme processamento Profissional de saude			  
//--------------------------------------------------------------------
function CarregaRdaSolT(v) {
   var aResult = v.split("|");
   //--------------------------------------------------------------------
   // Alimenta variaveis													  
   //--------------------------------------------------------------------
   document.getElementById("cCnpjSolT").value = aResult[0];
   document.getElementById("cRdaSolT").value  = aResult[1];
   document.getElementById("cProfSolT").value = aResult[2];
   document.getElementById("cOpeSolT").value  = aResult[3];
}                
//--------------------------------------------------------------------
// Monta os Solicitantes/Executante									  
//--------------------------------------------------------------------
cBusca    = "";
cTimeOut  = 0;
cProfAntG = "";

//--------------------------------------------------------------------
// Carrega campos conforme processamento Profissional de saude			  
//--------------------------------------------------------------------
function CarregaProSaudeFilInt(v) {
   var aResult = v.split("|");   
   //--------------------------------------------------------------------
   // Verfiica se e solicitacao ou execucao
   //--------------------------------------------------------------------
   if (cTpProfG == "S") {
	   setTC(document.getElementById("cProSol"),"");
	   var e = document.getElementById("cProSol");
   }
   //--------------------------------------------------------------------
   // Alimenta o combo
   //--------------------------------------------------------------------
   for (var i = 0; i < aResult.length; i++) {
	   var aProf = aResult[i].split("%");
	   if (aProf.length>1 && aProf[1] != '')
		   e.options[i] = new Option(aProf[1], aProf[0]);
   }	                 
   //--------------------------------------------------------------------
   // carrega campos do prestador
   //--------------------------------------------------------------------
   if (cProfAntG != e.value) {
	   cProfAntG = e.value;
	   fProfSauInt(e.value,cTpProfG);
   }
}  

//--------------------------------------------------------------------                  
// Monta os Solicitantes												  
//--------------------------------------------------------------------
function fProfSauInt(cProSaud, cTpProf) {
   //--------------------------------------------------------------------
   // Executa o metodo													  
   //--------------------------------------------------------------------
   Ajax.open("W_PPCBOSPSAU.APW?cProSaud=" + cProSaud, { 
	   callback: CarregaProSaudeInt, 
	   error: ExibeErro,
	   showProc: false 
   });
}
//--------------------------------------------------------------------
// Carrega campos conforme processamento Profissional de saude			  
//--------------------------------------------------------------------
function CarregaProSaudeInt(v) {
   var aResult = v.split("|");
   //--------------------------------------------------------------------
   // alimenta variaveis													  
   //--------------------------------------------------------------------
   document.getElementById("cCodSigSol").value	= aResult[0];
   document.getElementById("cNumCrSol").value	= aResult[1];
   document.getElementById("cEstSigSol").value	= aResult[2];
   document.getElementById("cNomeRdaSol").value	= aResult[3];
   if (aResult.length >= 6){			    
			   if ( typeof(aResult[6]) != 'undefined' ) {
					setTC(document.getElementById("cCbosSol"),"");			
				   var aEspeci = aResult[6].split('$');		
				   var e = document.getElementById("cCbosSol");
				   for (var i = 0; i < aEspeci.length; i++) {
					   var aIten = aEspeci[i].split("#");
					   if (aIten[0] != '') {                  
						   e.options[i] = new Option(aIten[1], aIten[0]);
						}	
				   }
			   }else{        
				   var cRda 	= document.getElementById("cRda").value;
				   var cCodLoc = document.getElementById("cCodLoc").value;
				   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
					   callback: CarrEspAntInt, 
					   error: ExibeErro
				   });    
			   }
		   }else{        
				   var cRda 	= document.getElementById("cRda").value;
				   var cCodLoc = document.getElementById("cCodLoc").value;
				   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
					   callback: CarrEspAntInt, 
					   error: ExibeErro
				   });    
		   }
}                                           

function CarrEspAntInt(v){
   var aResult = v.split("|");
   var aResuEsp = (aResult[24].substring(1)).split("~");
   //--------------------------------------------------------------------
   // Monta especialidades												   
   //--------------------------------------------------------------------
   setTC(document.getElementById("cCbosSol"),"");
   var e = document.getElementById("cCbosSol");
   for (var i = 0; i < aResuEsp.length; i++) {
	   var aIten = aResuEsp[i].split("$");
	   e.options[i] = new Option(aIten[1], aIten[0]);
   }
}  

//--------------------------------------------------------------------
// Checa se o procedimento e valido									  
//--------------------------------------------------------------------
function fChkCodProInt(cCmpPad, cCmpPro, cCmpDesc, cTpProc,cCmpMatric,cCmpRda) {
   cCampoRef 	 = cCmpPro;
   cCampoRefDes = cCmpDesc;
   cRda = '';
   //--------------------------------------------------------------------
   // Limpa descricao do procedimento										  
   //--------------------------------------------------------------------
   document.getElementById(cCmpDesc).value = "";

   cCodPad = document.getElementById(cCmpPad).value;
   cCodPro = document.getElementById(cCmpPro).value;
   cMatric = document.getElementById(cCmpMatric).value;
   if  (document.getElementById(cCmpRda) != null){
	   cRda = document.getElementById(cCmpRda).value;
   }
   if (cCodPad == "") {
	   alert("Informe o código da tabela");
	   document.getElementById(cCmpPad).focus();
	   return false;
   }

   if (cCodPro == "") return true;

   Ajax.open("W_PPLSCHKSER.APW?cCodPadPro=" + ( cCodPad + cCodPro ) + "&cTpProc=" + cTpProc + "&cMatric=" + cMatric + "&cRda=" + cRda, { 
	   callback: CarregaDeskProInt, 
	   error: ExibeErro 
   });
}
//--------------------------------------------------------------------
// fChkQtdPro  Data   01/10/13   
//Desc.      Valida a exibição do lembrete do procedimento com base     
//               na quantidade solicitada.                                  
//--------------------------------------------------------------------
function fChkQtdProInt(cCodPad,cCodPro,nQtdPro) {  

var cCodPad = document.getElementById(cCodPad).value;
var cCodPro = document.getElementById(cCodPro).value;
var nQtdPro = document.getElementById(nQtdPro).value; 
	   Ajax.open("W_PPLSQTD.APW?cCodPad=" + cCodPad  + "&cCodPro=" + cCodPro + "&nQtdPro=" + nQtdPro, {  
	   callback: CarregaQTDInt, 
	   error: ExibeErro 
   });
} 

//--------------------------------------------------------------------
// Exibe a tela de lembrete do procedimento.							  
//--------------------------------------------------------------------  
function CarregaQTDInt(v) {  
   if (v != null){
	   var aResult = v.split("|");  
	   alert(aResult[1]); 
   }
}
//--------------------------------------------------------------------
// Mostra a descricao do procedimento									  
//--------------------------------------------------------------------
function CarregaDeskProInt(v) {
   var aResult = v.split("|");
   if(typeof cTpPD == "undefined") cTpPD = ''; //se não existir a variavel eu crio (nova prorrogação de internacao)
   if(typeof cCampoRefDes != 'undefined') document.getElementById(cCampoRefDes).value = aResult[0];
   
   document.getElementById(cCampoRefDes).value = document.getElementById(cCampoRefDes).value.replace( /\?/, "" );
   //--------------------------------------------------------------------
   // Tratamento para indicação clinica									   
   //--------------------------------------------------------------------
   if (aResult[1]=='1') document.getElementById("cCmpIndCli").value += cCodPro+"~";
   if (aResult[2]=='4') cTpPD += cCodPro+"~";
   
   if (aResult[5] == "forbla") {
	   alert(aResult[6]);
   }	
}

function INTLoad(){
cVazio = "";
cVirgula = ",";
//--------------------------------------------------------------------
// Carrega dados da rda												   
//--------------------------------------------------------------------
fRdaInt(document.getElementById("cRda").value,document.getElementById("cCodLoc").value);
document.getElementById("cCodPadSSol").value=document.getElementById("cmvTabDef").value;
document.forms[0].cCodPadSSol.className = "form-control TextoInputOB"; //deixo os campos em destaque
document.forms[0].cCodProSSol.className ="form-control TextoInputOB"; //deixo os campos em destaque
document.forms[0].cQtdSSol.className ="form-control TextoInputOB";//deixo os campos em destaque
if (document.forms[0].cProSol != undefined){
   document.forms[0].cProSol.className ="form-control ComboSelectOB";//deixo os campos em destaque 
   }
if (document.forms[0].cProSolDesc != undefined){
   document.forms[0].cProSolDesc.className ="form-control TextoInputOB";//deixo os campos em destaque 
   }

setDisable('bimprimir',true);
setDisable("bAnexoDoc",true);
if (document.getElementById("bSaveTabSolSer") != null){
   setDisable('bSaveTabSolSer',true);
}
if (document.getElementById("bSaveTabProSer") != null){
   setDisable('bSaveTabProSer',true);
}
//--------------------------------------------------------------------
// Tratamento dos campos												   
//--------------------------------------------------------------------
var oForm = new xform( document.forms[0] );
   oForm.add( document.forms[0].cCodPadSSol	,"numero", false, true );
   oForm.add( document.forms[0].cCodProSSol	,"numero", false, true );
   oForm.add( document.forms[0].cQtdSSol		,"numero", false, true );
   oForm.add( document.forms[0].cCodPadSPro	,"numero", false, true );
   oForm.add( document.forms[0].cCodProSPro	,"numero", false, true );
   oForm.add( document.forms[0].cQtdSPro		,"numero", false, true );
   oForm.add( document.forms[0].cQtdDSol		,"numero", false, true );
   oForm.add( document.forms[0].cCarSolicit	,"tudo"	 , false, false );
   oForm.add( document.forms[0].cTpIntern		,"tudo"	 , false, false );
   oForm.add( document.forms[0].cRegInter		,"tudo"	 , false, false );
   oForm.add( document.forms[0].cIndCliSol		,"tudo"	 , false, false );
   oForm.add( document.forms[0].cCid			,"tudo"	 , false, false );
   //Var private
   cTpPD = '';
   
   alterarCamposGuias();
}

//--------------------------------------------------------------------
// Verifica se o numero da liberacao existe e mostra os dados			  
//--------------------------------------------------------------------
function fChamAnexo(cNumeLib,cTp) {
   //--------------------------------------------------------------------
   // Verifica se foi informado a chave									  
   //--------------------------------------------------------------------
   if (cNumeLib == "") {
	   alert("Informe o numero da Solicitacao");
	   return;
   }
   
   //valida a quantidade de caracteres digitados 
   if(!fValQtdCarac(cNumeLib.replace(/\.|-/gi,""),18)){
	   return;                                                                                                   
   }
   
   setDisable('bimprimir',true);
   setDisable("bAnexoDoc",true);
   //--------------------------------------------------------------------
   // Retira a mascara													  
   //--------------------------------------------------------------------
   cNumeLib = cNumeLib.replace(/\D/g, "");               
   //--------------------------------------------------------------------
   // Executa o metodo													  
   //--------------------------------------------------------------------
   Ajax.open("W_PPLSANX.APW?cNumeAut=" + cNumeLib + "&cTp=" + cTp, { 
	   callback: CarregaDad2,
	   error: ExibeErro 
   });
}

//--------------------------------------------------------------------
// Pega o retorno														  
//--------------------------------------------------------------------
function CarregaDad2(v) {   
   var cPSol 		= "";
   var cNSol 		= "";
   var aMatCabIte 	= v.split("<");
   var aMatCab 	= aMatCabIte[0].split("|");
   cCampoRefL 		= "";
   //--------------------------------------------------------------------
   // Verifico se a estrutura dos itens foram enviadas					  
   //--------------------------------------------------------------------
   if (typeof aMatCabIte[1] == "undefined") {
	   alert("Estrutura indefinada");
	   return;
   }
   
   //--------------------------------------------------------------------
   // Verifico se o anexo pode estar sendo duplicado					  
   //--------------------------------------------------------------------	
   if ((aMatCabIte.length) > 2){
	   DupGuiMod(aMatCabIte[2]);
   }
   
   var aMatIte = aMatCabIte[1].split("~");
   //--------------------------------------------------------------------
   // Exibi criticas de procedimentos que nao podem ser executados		  
   //--------------------------------------------------------------------
   if (typeof aMatCab[aMatCab.length-1] != "undefined") {
	   if (aMatCab[aMatCab.length-1] != "") alert(aMatCab[aMatCab.length-1]);
   }
   //--------------------------------------------------------------------
   // Cabecalho e dados do executante caso for somente um					  
   //--------------------------------------------------------------------
   for (var i = 0; i < (aMatCab.length - 1); i++) {
	   var aCamVal = aMatCab[i].split("!");
	   //--------------------------------------------------------------------
	   // Somente se foi passado o nome do campo								  
	   //--------------------------------------------------------------------
	   if (aCamVal[0] != "") {
		   var cCampo = document.getElementById(aCamVal[0]);
		   if (cCampo != null) {
			   cCampo.value = aCamVal[1];              
		   }
	   }
   }
   
   Ajax.open("W_PPLBENINT.APW?cNumCart=" + document.getElementById('B4A_USUARI').value, { 
	   callback: changeProtocAnexos,
	   error: true 
   });
}
		  
function fMontItAne(cTp, cTable,nRecno,cTpAnexo) {
   cTpR 		 = cTp;
   cTableR 	 = cTable;
   
   //Desabilita botoes
   if(cTp == 'A'){ //Ajuste caso for alteração pois no "Tratamento inclusao ou alteracao" quando você alterava um procedimento já existente, trazia como falso o disable impossibilitando o salvamento desse procedimento.
		setDisable("bIncTabSolAne",true);
   } else{
		setDisable("bIncTabSolAne",false);
   }

   setDisable("bSaveTabSolAne",false);

   //--------------------------------------------------------------------
   // Numero da liberacao													  
   //--------------------------------------------------------------------
   var cChavSol = '';
   //--------------------------------------------------------------------
   // Monta conteudo das tabelas solicitacao e execucao					  
   //--------------------------------------------------------------------
   aMatAux = "TabSolAne$oTabSolAne";
   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   cStringEnvTab = "";
   aMat = aMatAux.split("|");
   for (var i = 0; i < aMat.length; i++) {
	   aMatAux = aMat[i].split("$")
	   //Se o grid foi preenchido
	   if(typeof eval(aMatAux[1]) != "string" && eval(aMatAux[1]).aCols.length > 0){
		   //Recupera os dados do grid
		   oTable = eval(aMatAux[1]).getObjCols();
		   
		   fMontMatGer('A', aMatAux[0]);
		   
		   aMatCampAux = aMatCap.split("|");
		   for (var y = 1; y < oTable.rows.length; y++) {
			   nf = 0;                  
			   cStringEnvTab += "cSeq@"+getTC(oTable.rows[y].cells[0])+"$";
			   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {
			   
				   cCampo = aMatCampAux[x - 2].split("$")[1];
				   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
					   celula = oTable.rows[y].cells[x + 1 - nf];
					   
					   if (typeof celula.value == 'undefined' || celula.value == '')
							conteudo = getTC(celula);
					   else conteudo = celula.value;	
					   
					   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
				   }
				   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;
			   }      
			   cStringEnvTab += "|";
		   }
	   }
   }
   //--------------------------------------------------------------------
   // Define parametros para uso na funcao de resultado					  
   //--------------------------------------------------------------------
   fMontMatAne(cTpAnexo, cTable);
   //--------------------------------------------------------------------
   // Matriz de campos													  
   //--------------------------------------------------------------------
   var aMatCol = aMatCap.split("|");
   if (eval(aMatAux[1]) != "" && eval(aMatAux[1]).aCols.length > 0){
	   var oTable  = eval(aMatAux[1]).getObjCols();
   }else{
	   var oTable = null
   }
   //--------------------------------------------------------------------
   // Tratamento inclusao ou alteracao									  
   //--------------------------------------------------------------------
   if (cTp == 'I' || cTp == 'A') {
	   
	   if (cTp == 'A'){  
		   if (!bIncTabSolAne.disabled){
			   ShowModal("Atenção","Não foi possível concluir este processo, pois não existem itens no grid de procedimentos.",true,false,true);	
			   setDisable('bSaveTabSolAne', true);
			   //Habilita botoes
			   setDisable("bIncTabSolAne",false);
			   return;
		   }
	   } 
	   
	   switch (cTable) {
		   case "TabSolAne":
			   if ((document.getElementById('B4C_DATPRO') != null) && (document.getElementById('B4C_DATPRO').value == "")) {
				   alert('Informe a data para o serviço');
				   document.getElementById('B4C_QTDPRO').focus();
				   //Habilita botoes
				   setDisable("bIncTabSolAne",false);
				   return;
			   }
			   if (document.getElementById('B4C_CODPRO').value == "") {
				   
				   alert('Informe o codigo para o serviço');
				   document.getElementById('B4C_QTDPRO').focus();
				   //Habilita botoes
				   setDisable("bIncTabSolAne",false);
				   return;
			   
			   }else if (document.getElementById('B4C_QTDPRO').value == "" || document.getElementById('B4C_QTDPRO').value == "0") {
				   
				   alert('Informe a quantidade de serviço');
				   document.getElementById('B4C_QTDPRO').focus();
				   //Habilita botoes
				   setDisable("bIncTabSolAne",false);
				   return;
				   
			   }else if (document.getElementById('B4A_GUIREF').value == "" ){ 
				   
				   alert('Informe o numero da guia referenciada.');
				   document.getElementById('B4A_GUIREF').focus();
				   //Habilita botoes
				   setDisable("bIncTabSolAne",false);
				   return;
				   
			   }else if (document.getElementById('B4A_GUIREF').value == "" ) { 
					
				   alert('Informe o numero da guia referenciada.');
				   document.getElementById('B4A_GUIREF').focus();
				   //Habilita botoes
				   setDisable("bIncTabSolAne",false);
				   return;
				   
			   }else if(document.getElementById('B4C_UNMED') != null && document.getElementById('B4C_UNMED').value == ""){
					   alert('Informe a unidade de medida.');
					   document.getElementById('B4C_UNMED').focus();
					   //Habilita botoes
					   setDisable("bIncTabSolAne",false);
					   return;	 
			   }else if (document.getElementById('B4C_VIAADM') != null && document.getElementById('B4C_VIAADM').value == ""){

					   alert('Informe a via de administração.');
					   document.getElementById('B4C_VIAADM').focus();
					   //Habilita botoes
					   setDisable("bIncTabSolAne",false);
					   return;
				   
			   }else if (document.getElementById('B4C_FREQUE') != null ){
				   
				   if(document.getElementById('B4C_FREQUE').value == "") {
					   
					   alert('Informe a frequência.');
					   document.getElementById('B4C_FREQUE').focus();
					   //Habilita botoes
					   setDisable("bIncTabSolAne",false);
					   return;
				   }
			   }                      
			   break;   		
		   }

		//--------------------------------------------------------------------
		// VaLiDa formulario dos Itens												   
		//--------------------------------------------------------------------   
		if (!fValCampoObrig("B4C")){ 
			return;
		}
	   //--------------------------------------------------------------------
	   // Verifica duplicidade												   
	   //--------------------------------------------------------------------
	   var nCol 		= 0;
	   if (typeof oTable != "string" && oTable != null){
		   var nQtdLinTab  = oTable.rows.length;
	   }else{
		   var nQtdLinTab = 0
	   }
	   var cString 	= '1'+"|";
	   var cContChave  = document.getElementById('B4C_CODPRO').value;
	   if (cContChave == "") {
		  alert("Serviço não informado");
		  document.getElementById(cChave).focus();
		  //Habilita botoes
		  setDisable("bIncTabSolAne",false);
		  return;
	   }
	   //--------------------------------------------------------------------
	   // Monta a sequencia e matriz de retorno								   
	   //--------------------------------------------------------------------
	   if (document.getElementById(aMatAux[1]) != null) {
		   if (typeof document.getElementById(aMatAux[1]).length != 'undefined') {
			   if (cTp == 'I') 
					cString = String(document.getElementById(aMatAux[1]).length + 1) + "|";
			   else cString = String(document.getElementById(aMatAux[1]).length) + "|";
		   }
	   }
	   //--------------------------------------------------------------------
	   // Monta envio das variaveis de sessao GET								  
	   //--------------------------------------------------------------------
	   cQueryString =	"&cMatric="+document.getElementById('B4A_USUARI').value+
					   "&cTp="+cTpAnexo;
					   
	   if (document.getElementById('B4A_CIDPRI') != null){				
		   cQueryString +=	"&cCid="+document.getElementById('B4A_CIDPRI').value;
	   }else{
		   cQueryString +=	"&cCid=''"
	   }				
	   cCamGer = "";
	   for (var i = 0; i < aMatCol.length; i++) {
		   var aMatColAux = aMatCol[i].split("$");
		   cCampo = document.getElementById(aMatColAux[0]);
		   if (typeof cCampo != 'undefined' && cCampo != null && aMatNGet.indexOf(aMatColAux[1])==-1) {
			   cQueryString += "&" + aMatColAux[1] + "=" + cCampo.value;
		   }
	   }                   
	   
	   //--------------------------------------------------------------------
	   // Verifica duplicidade												  
	   //--------------------------------------------------------------------
	   for (var i = 0; i < nQtdLinTab; i++) {
		  
		  for (var y = 0; y < aMatCol.length; y++) {
			   var aMatColAux = aMatCol[y].split("$");
			   if (aMatColAux[0] == cChave) {
				   nCol = y;
				   break;
			   }	
		   }
		  
		   //--------------------------------------------------------------------
		   // Verfica se existe um registro igual na tabela						  
		   //--------------------------------------------------------------------
		   var lResult = false;   
		   if ( (cTp == 'I' || i+1 != parseInt(nRecno)) && getTC(oTable.rows[i].cells[nCol+3]) ==	cContChave) {
			   modalBS("Atenção", "<p>Este procedimento já foi informado, utilize o campo quantidade</p>", "@Fechar~closeModalBS();", "white~#960000", "large");
			   //Habilita botoes
			   setDisable("bIncTabSolAne",false);
			   return;
		   }
	   }
	   
	   //--------------------------------------------------------------------
	   // verifica se algum campo foi alterado			   					   
	   //--------------------------------------------------------------------
	   if (cTp == 'A') {
		   cSt = "0";
		   //--------------------------------------------------------------------
		   // Verifica se algum campo que necessita de checar a regra novamente foi alterado
		   //--------------------------------------------------------------------
		   lResult = true;
		   var nLenTable = oTable.rows[nRecno-1].cells.length -1;
		   for (var y = 2; y < nLenTable ; y++) {
			   var aMatColAux = aMatCol[y - 2].split("$");
			   cCampo = document.getElementById(aMatColAux[0]);
			   if (getTC(oTable.rows[nRecno-1].cells[y]) != cCampo.value) {
				   cSt = "1";
				   if (aValAlt.indexOf(aMatColAux[0]) != -1) lResult = false;
			   }
		   }
		   
		   //--------------------------------------------------------------------
		   // Altera a tabela sem checar a regra novamente								  
		   //--------------------------------------------------------------------
		   if (lResult) {
				   fGetDadGen(nRecno, cTable ,4,true,cCampo.value,"",cCampoDefault.replace(/\|/g,","));
				   setDisable('bIncTabSolAne', false); 
				   //Habilita botoes
				   setDisable("bIncTabSolAne",false);
				   return;
		   }
	   } 
	   
	   cString += aMatRet + "|" + cStringEnvTab + "|";            
	   //--------------------------------------------------------------------
	   // Executa o metodo													  
	   //--------------------------------------------------------------------
	   if (!lResult) Ajax.open("W_PPLSAUTANE.APW?cString=" + cString + cQueryString, { 
						   callback: CarregaMontItensAnexo,
						   error: ExibeErro 
					  });
   }
   //--------------------------------------------------------------------
   // Calculo de valores primeiro campo recebe segundo campo o valor do	  
   // campo e pego da tabela												  
   //--------------------------------------------------------------------
   if (typeof aCalVal != 'undefined' && aCalVal != null) {
	   var aCalValAux = aCalVal.split("|");
	   for (var i = 0; i < aCalValAux.length; i++) {
		   if (aCalValAux[i] != "") {
			   var aMatCamp = aCalValAux[i].split("$");
			   //--------------------------------------------------------------------
			   // Para pegar os campos de informacao e recebimento					  
			   //--------------------------------------------------------------------
			   if (typeof aMatCamp[0] != 'undefined' && aMatCamp[0] != null && typeof aMatCamp[1] != 'undefined' && aMatCamp[1] != null) {
				   //--------------------------------------------------------------------
				   // Descobrir a coluna na tabela										  
				   //--------------------------------------------------------------------
				   for (var x = 0; x < aMatCol.length; x++) {
					   var aMatColAux = aMatCol[x].split("$");
					   if (aMatColAux[0] == aMatCamp[1]) {
						   nCol = x;
						   break;
					   }
				   }
				   if (cTp != 'I') nCol++;
				   //--------------------------------------------------------------------
				   // atualiza os campos com base no valor da tabela						  
				   //--------------------------------------------------------------------
				   var nValor = 0;
				   var cCampo = document.getElementById(aMatCamp[0]);
				   for (var x = 1; x < oTable.rows.length; x++) {
					   nValor += parseInt(getTC(oTable.rows[x].cells[nCol + 1]).replace(/\D/g, ""));
				   }
				   cCampo.value = MaskMoeda(nValor);
			   }
		   }
	   }
   }
}

//--------------------------------------------------------------------
// Pega o retorno do processamento										  
//--------------------------------------------------------------------
function CarregaMontItensAnexo(v) {                       
   var lAto 	= false;
   var aResult = v.split("|");
   var cTitulo = aResult[0]; 				//Titulo do resultado autorizado,negado ou autorizado parcial
   var aMatRet = aResult[1].split("~"); 	//Retorno para grid campos e resultado do campo
   var cTexto 	= aResult[5]; 				//Procedimento autorizados ou negados resultado
   
   setDisable('bIncTabSolAne', false); 
   
   //--------------------------------------------------------------------
   // Alimentar campos de retorno											  
   //--------------------------------------------------------------------
   for (var i = 0; i < aMatRet.length; i++) {
	   aRetAux = aMatRet[i].split(";");
	   cCampo = document.getElementById(aRetAux[0]);

	   if (typeof cCampo != 'undefined' && cCampo != null) 
		   cCampo.value = aRetAux[1];
   }
   //--------------------------------------------------------------------
   // Se vai incluir ou alterar a linha campo alimentado pela aMatRet 	  
   //--------------------------------------------------------------------
   if (typeof cTableR != 'undefined' && typeof aMatCap != 'undefined' && typeof aMatBut != 'undefined') {
	   cCampo = document.getElementById("cStatusAut");
	   if (typeof cCampo != 'undefined') {

		   if (cCampo.value == '5') {
			   cCampo.value = '1';
		   }

		   if (cTpR == 'I') {
				   fGetDadGen(0, cTableR ,3,true,cCampo.value,"",cCampoDefault.replace(/\|/g,","));
		   }else{
			   fGetDadGen(document.getElementById(cTableR+"_RECNO").value, cTableR ,4,true,cCampo.value,"",cCampoDefault.replace(/\|/g,","));
		   }
		   //--------------------------------------------------------------------
		   // Retorno o valor original											  
		   //--------------------------------------------------------------------
		   cCampo.value == "0";
	   }
   }                                                                       
   //--------------------------------------------------------------------
   // Mostra o resultado modal so mostra se for negado					  
   //--------------------------------------------------------------------
   if ( cTitulo != "1" ) ShowModal(cTitulo, cTexto);
   //--------------------------------------------------------------------
   // Se for pagamento no ato												   
   //--------------------------------------------------------------------
}

//--------------------------------------------------------------------
// Monta matriz genericas												   
//--------------------------------------------------------------------
function fMontMatAne(cTp,cTable) {                  
		   //--------------------------------------------------------------------
		   // Monta matriz genericas												   
		   //--------------------------------------------------------------------
		   switch (cTp)	{                                          
			   case "07":
				   aMatCap 		 = ( (cTp=='I') ? 'Chk$NIL|' : "" ) + 'B4C_DATPRO$dDatPro|B4C_CODPAD$cCodPad|B4C_CODPRO$cCodPro|B4C_DESPRO$cDesPro|B4C_QTDPRO$nQtdSol|B4C_UNMED$cUniMed|B4C_VIAADM$cViaAdm|B4C_FREQUE$cFreque|B4A_GUIREF$cGuiRef';
				   aMatBut 		 = 'bISolSer|bASolSer|bESolSer';
				   aMatRet 		 = 'cStatusAut~cQtdAutSSol';
				   cChave 			 = 'B4C_CODPRO';
				   cCampoDefault	 = 'B4C_DATPRO;aInipadB4C_DATPRO|B4C_CODPAD;aInipadB4C_CODPAD|B4C_QTDPRO;aInipadB4C_QTDPRO|B4C_VIAADM;aInipadB4C_VIAADM|B4C_FREQUE;aInipadB4C_FREQUE';
				   aValAlt			 = 'B4C_CODPAD|B4C_CODPRO|B4C_QTDPRO';
				   aCalVal			 = '';
				   aMatConv 		 = '';
				   aMatNGet 		 = 'B4C_DESPRO';     
				   break;  
			   case "08":
				   aMatCap 		 = ( (cTp=='I') ? 'Chk$NIL|' : "" ) + 'B4C_DATPRO$dDatPro|B4C_CODPAD$cCodPad|B4C_CODPRO$cCodPro|B4C_DESPRO$cDesPro|B4C_QTDPRO$nQtdSol';
				   aMatBut 		 = 'bISolSer|bASolSer|bESolSer';
				   aMatRet 		 = 'cStatusAut~cQtdAutSSol';
				   cChave 			 = 'B4C_CODPRO';
				   cCampoDefault	 = '';
				   aValAlt			 = '';
				   aCalVal			 = '';
				   aMatConv 		 = '';
				   aMatNGet 		 = 'B4C_DESPRO';
				   break;  
			   case "09":
				   aMatCap 		 = ( (cTp=='I') ? 'Chk$NIL|' : "" ) + 'B4C_CODPAD$cCodPad|B4C_CODPRO$cCodPro|B4C_DESPRO$cDesPro|B4C_OPCAO$cOpcao|B4C_QTDPRO$nQtdSol|B4C_VLRUNT$nVlrUnt|B4C_QTDSOL$nQtdSol|B4C_VLRUNA$nVlrUna|B4C_REGANV$cRegAnv|B4C_REFMAF$cRefMaf|B4C_AUTFUN$cAutFun|B4A_GUIREF$cGuiRef';
				   aMatBut 		 = 'bISolSer|bASolSer|bESolSer';
				   aMatRet 		 = 'cStatusAut~cQtdAutSSol';
				   cChave 			 = 'B4C_CODPRO';
				   cCampoDefault	 = 'B4C_CODPAD;aInipadB4C_CODPAD|B4C_OPCAO;aInipadB4C_OPCAO|B4C_VLRUNT;aInipadB4C_VLRUNT|B4C_QTDPRO;aInipadB4C_QTDPRO|B4C_QTDSOL;aInipadB4C_QTDSOL|B4C_VLRUNA;aInipadB4C_VLRUNA|B4C_REGANV;aInipadB4C_REGANV|B4C_REFMAF;aInipadB4C_REFMAF|B4C_AUTFUN;aInipadB4C_AUTFUN';
				   aValAlt			 = 'B4C_CODPAD|B4C_CODPRO|B4C_QTDPRO';
				   aCalVal			 = '';
				   aMatConv 		 = '';
				   aMatNGet 		 = 'B4C_DESPRO';
				   break;   
		   }
}                              
														
//--------------------------------------------------------------------
// Processa 															  
//--------------------------------------------------------------------
function fProcFormAnex(formulario,aCmpGuia) {
   var aMatAux2 = ""
   document.forms[0].action = "W_PPLPRANEXO.APW";
   
   
   if(document.getElementById("cTp").value != "08"){
   
   
	   //--------------------------------------------------------------------
	   // Verfica se foi digitado algum procedimento							   
	   //--------------------------------------------------------------------
	   lVld = false;
	   if (typeof oTabSolAne == "string") { 
		   lVld = true;
		   cMsg = "Informe pelo menos um serviço para a Solicitação";
	   }
	   //--------------------------------------------------------------------
	   // aviso																   
	   //--------------------------------------------------------------------
	   if (lVld) {
		   alert(cMsg);
		   return;
	   }
   }
   //--------------------------------------------------------------------
   // VaLiDa formulario do cabeçalho												   
   //--------------------------------------------------------------------   
   if (!fValCampoObrig("B4A")){ 
	   return;
   } 
   
   
   if(document.getElementById("cTp").value != "08"){
   
   
	   aMatAux = "TabSolAne$oTabSolAne";
	   //--------------------------------------------------------------------
	   // Carrega as linhas das tabelas para processamento					   
	   //--------------------------------------------------------------------
	   aMat   		  = aMatAux.split("|");
	   cStringEnvTab = "";
	   
	   for (var i = 0; i < aMat.length; i++) {
		   
		   aInfoAux = aMat[i].split("$")
		   oTable = eval(aInfoAux[1]).getObjCols();
		   //Associa a coluna com a variável do post
		   fMontMatAne(document.getElementById("cTp").value , aInfoAux[0]);
		   aMatCampAux = aMatCap.split("|");    
		   
		   for (var y = 0; y < oTable.rows.length; y++) {
			   nf 	 = 0;
								   
			   cStringEnvTab += "cSeq@" + y + "$";

			   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {
				   
				   if (aMatCampAux[x - 2] != undefined){
					   cCampo = aMatCampAux[x - 2].split("$")[1];
					   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
						   celula = oTable.rows[y].cells[x + 1 - nf];
						   
						   if (typeof celula.value == 'undefined' || celula.value == '')
							   conteudo = getTC(celula);
						   else  conteudo = celula.value;	
						   
						   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
					   }
					   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;
				   }
			   }
			   cStringEnvTab += "|";
		   }
	   }
	   document.getElementById("cMatTabES").value = cStringEnvTab + "|";
   }
   //=========================================================================
   //³ Metodo de envio de formulario pelo ajax								  ³
   //=========================================================================
   Ajax.send(formulario, { 
		   callback: CarregaProcFormAne,
		   error: ExibeErro 
   });
   document.forms[0].action = "";
   //--------------------------------------------------------------------
   // Desabilita os campos												  
   //--------------------------------------------------------------------
}       
//--------------------------------------------------------------------
// Pega o retorno do processamento										  
//--------------------------------------------------------------------
function CarregaProcFormAne(v) {
   var aResult = v.split("|");
   var cSenha  = "";
   var cTexto  = aResult[10]; //Procedimento autorizados ou negados resultado
   var cTitulo = aResult[11]; //Titulo do resultado autorizado,negado ou autorizado parcial
   var cMostra = aResult[12];
   var cAutori = aResult[0];        
   setDisable('bconfirma',true);
   setDisable('bconfirmanovo',true);
   setDisable('bimprimir',false);
   setDisable("bAnexoDoc",false);
   //--------------------------------------------------------------------
   // Informacoes	da autorizacao											  
   //--------------------------------------------------------------------
   if (aResult[0] != "") document.getElementById("cNumAut").value = aResult[0].substr(0, 4) + "." + aResult[0].substr(4, 4) + "." + aResult[0].substr(8, 2) + "-" + aResult[0].substr(10, 8); //Numero da autorizacao
   //--------------------------------------------------------------------
   // Implementa Senha na exibicao										  
   //--------------------------------------------------------------------
   if (aResult[1] != "") cSenha = "<br/> Senha: " + aResult[1];

   //--------------------------------------------------------------------
   // Para mostrar o numero da autorizacao								  
   //--------------------------------------------------------------------
   if (cTexto == "") {
	   cTexto = "<center>" + document.getElementById("cNumAut").value + cSenha + "</center>";
   } else {
	   cTexto = "<center>" + document.getElementById("cNumAut").value + cSenha + "</center><br>" + cTexto;
   }
   //--------------------------------------------------------------------
   // Mostra o resultado modal											  
   //--------------------------------------------------------------------
   var cFuncDoc = "";
   if(wasDef( typeof cTp) && (cTp.value == 1 || cTp.value == 2 || cTp.value == 3 || cTp.value == 7 || cTp.value == 8 || cTp.value == 9 || cTp.value == 11 )){
		   cFuncDoc =  "@Anexar Documentos~anexoDocGui('" + aResult[0] + "')";
   }
   ShowModal(cTitulo, cTexto, false, false, false, "actionVoltar();"+cFuncDoc);
}  
function ANEXLoad(){
cVazio = "";
cVirgula = ",";
   //--------------------------------------------------------------------
   // disabled
   //--------------------------------------------------------------------
   setDisable("bimprimir",true);
   setDisable("bAnexoDoc",true);

}

//--------------------------------------------------------------------
//varre o formulário validando os campos
//--------------------------------------------------------------------

function validaAnexo(cChave){
   obj=oForm
   ixx=obj.campos
   for(y=0;y<obj.total;y++){
	   //Valida email
	   if (ixx[y].tipo=="email" && !branco(ixx[y].campo.value)){
		   if(!verificaEmail(ixx[y].campo.value)){
			   alert(mensagens[1])
			   ixx[y].campo.focus()
			   return false
		   }
	   }

	   //Valida cpf
	   if (ixx[y].tipo=="cpf" && !branco(ixx[y].campo.value)){
		   if(!verificaCPF(ixx[y].campo.value)){
			   alert(mensagens[2])
			   ixx[y].campo.focus()
			   return false
		   }
	   }

	   //valida cgc
	   if (ixx[y].tipo=="cgc" && !branco(ixx[y].campo.value)){
		   if(!verificaCGC(ixx[y].campo.value)){
			   alert(mensagens[3])
			   ixx[y].campo.focus()
			   return false
		   }
	   }

	   //valida cgc ou cpf
	   if (ixx[y].tipo=="cgcoucpf" && !branco(ixx[y].campo.value)){
		   if(!verificaCPF(ixx[y].campo.value) && !verificaCGC(ixx[y].campo.value)){
			   alert(mensagens[4])
			   ixx[y].campo.focus()
			   return false
		   }
	   }

	   //valida data
	   if (ixx[y].tipo=="data" && !branco(ixx[y].campo.value)){
		   if(!ValData(ixx[y].campo.value)){
			   alert(mensagens[5])
			   ixx[y].campo.focus()
			   return false
		   }
	   }

	   //valida campos obrigatórios                                  
	   cCampo = ixx[y].campo.id;
	   if (!ixx[y].branco){
		   if (cChave != null){
			   if( (Trim(ixx[y].campo.value)=="") && (cChave.indexOf(cCampo) == -1) ){
				   
				   cCampo = ixx[y].campo.parentNode.textContent 
				   if (cCampo == ""){
					   cCampo = ixx[y].campo.parentNode.parentNode.textContent
				   }
				   
				   cCampo = cCampo.substr(0,cCampo.search("\\*"))	//	pesquisa marca de obrigatório "*" no campo
				   
				   if(cCampo != "") { 
					   ShowModal("Atenção",mensagens[6] + " [" + cCampo + "]",true,false,true); 
					   ixx[y].campo.focus();
					   return false;
				   }                            
			   }               
		   }else
			   if( (Trim(ixx[y].campo.value)=="")){
				   
				   cCampo = ixx[y].campo.parentNode.textContent 
				   
				   if (cCampo == ""){
					   cCampo = ixx[y].campo.parentNode.parentNode.textContent
				   }
				   
				   cCampo = cCampo.substr(0,cCampo.search("\\*"))	//	pesquisa marca de obrigatório "*" no campo
				   
				   if(cCampo != "") { 
					   ShowModal("Atenção",mensagens[6] + " [" + cCampo + "]",true,false,true); 
					   ixx[y].campo.focus();
					   return false;
				   }  
		   }
	   }
   }
   for(y=0;y<obj.total;y++){
	   if (ixx[y].dinheiro){ixx[y].campo.value=eval("x"+ixx[y].campo.name)};
	   if (ixx[y].tipo=="cgc" || ixx[y].tipo=="cpf" || ixx[y].tipo=="cgcoucpf" || ixx[y].tipo=="cep"){
	   ixx[y].campo.value=trimtodigits(ixx[y].campo.value)}
   }
   
   // valida e troca o ponto decimal e de milhar para os países de língua inglesa e espanhola
   if (cLanguage == "ENGLISH" || cLanguage == "SPANISH") {
	   for (y=0; y < obj.campos.length; y++) {
		   obj.campos[y].campo.value = obj.campos[y].campo.value.replace(".", "|");
		   obj.campos[y].campo.value = obj.campos[y].campo.value.replace(",", ".");
		   obj.campos[y].campo.value = obj.campos[y].campo.value.replace("|", ",");
	   }
   }
   
   return true
};



//====================================================
//FUNÇÕES DA GUIA DE HONORÝRIOS
//====================================================


//--------------------------------------------------------------------
// VINICIUS HELLENO - Aguarda a chamada do ajax para evitar requisicoes  
//desnecessarias no banco de dados									  
//--------------------------------------------------------------------
var timerAjax = null;
var timerFlag = false;
var cString = '';
var lVld2 = false;
var LastkeyID = 0;

function vwaitAjax(event,ctype){
	if(timerFlag == false){
		 timerFlag = true;
		 timerAjax = setTimeout(function(){xfProfSauClear(ctype); },400);
	}else{
		 clearTimeout(timerAjax);
		 timerFlag = false ;
		 vwaitAjax(event,ctype);
	}
}   

function vwaitAjaxHon(event,ctype){
	if(timerFlag == false){
		 timerFlag = true;
		 timerAjax = setTimeout(function(){fProfSauClearHon(ctype); },400);
	}else{
		 clearTimeout(timerAjax);
		 timerFlag = false ;
		 vwaitAjaxHon(event,ctype);
	}
}

function manutString(e){
   var keyID 	= (window.event) ? e.keyCode : e.which;
   //--------------------------------------------------------------------
   // Tratamento quando for backspace ou delete desviado pela fProfSauClear
   //--------------------------------------------------------------------
   lVld2 = (keyID >=64 && keyID <=93 || keyID >=97 && keyID <=125 || keyID >=48 && keyID <=62 || keyID == 95 || keyID == 8 || keyID == 46 || keyID == 32);
  if (lVld2) {
	   if (keyID == 8) {
		   cString = cString.substr(0,cString.length-1);
	   } else {
		   if (keyID == 46) {
			   cString = '';         
		   } else {
			   cString = cString + String.fromCharCode(keyID);
		   }
	   }                 
   }
   LastkeyID = keyID;
}
//--------------------------------------------------------------------
// Monta matriz genericas												  
//--------------------------------------------------------------------
function fMontMatGerHon(cTp, cTable) {
  //--------------------------------------------------------------------
  // Monta matriz genericas												  
  //--------------------------------------------------------------------
  switch (cTable) {
	   case "TabExeSer":
		   var d = new Date()
		   //--------------------------------------------------------------------ÄÄÄÄÄÄÄÄÄÄ
		   // aMatCap campos que apareceram na tabela o Chk e um check box para utilizacao na exclusao 
		   //--------------------------------------------------------------------ÄÄÄÄÄÄÄÄÄÄ
		   aMatCap 		 = ( (cTp=='I') ? 'Chk$NIL|' : "" ) + 'dDtExe$dDtExePro|cHorIniSExe$cHorIni|cHorFimSExe$cHorFim|cCodPadSExe$cCodPad|cCodProSExe$cCodPro|cDesProSExe$cDesPro|cQtdSExe$nQtdSol|cViaSExe$cViaAc|cTecSExe$cTecUt|nRedAcreSExe$nRedAcre|nVlrUniSExe$nVlrApr|nVlrTotSExe$nVlrTAp|cSeqBD6G$cSeqBD6G'; //rrr
		   aMatBut 		 = 'bIExeSer|bAExeSer|bEExeSer';	//Botoes que estao sendo usados (desabilita ou nao)
		   aMatRet 		 = 'cStatusAut~cQtdSExe';			//O que vai ser retornado da funcao (se foi autorizado ou nao) 	
		   cChave 			 = 'cCodProSExe';					//Chave da Tabela
		   cCampoDefault	 = 'cCodPadSExe;aInipadcCodPadSExe|cQtdSExe;aInipadcQtdSExe|dDtExe;aInipaddDtExe|nRedAcreSExe;aInipadnRedAcreSExe|nVlrUniSExe;aInipadnVlrUniSExe|nVlrTotSExe;aInipadnVlrTotSExe';// + d.toLocaleDateString() ;	//Nao deixar limpar os campos com valor NIL ou atribui o defaul inclusao/alteracao
		   aValAlt			 = 'cCodPadSExe|cCodProSExe|cQtdSExe';		//Campos que sao checados se teve alteracao ou nao	
		   aCalVal			 = '';										//Para calculo o segudo recebe a soma do primeiro	  
		   aMatConv 		 = '';										//Matriz para converter campos
		   aMatNGet 		 = 'cDesPro';
		   break;
		   
	   case "TabExe":
				   aMatCap 		 = 'nSeqRef$cSeqPro|cGraPartExe$cGrPar|cCpfExe$cCpfExe|cProExe$cProExe|cCodSigExe$cCodSigExe|cNumCrExe$cNumCrExe|cEstSigExe$cEstSigExe|cCbosExe$cCbosExe|cSeqBD7G$cSeqBD7G'; //rrr
				   aMatBut 		 = '';
				   aMatRet 		 = '';
				   cChave 			 = 'cGrPar';
				   cCampoDefault	 = '';
				   aValAlt			 = '';
				   aCalVal			 = '';
				   aMatConv 		 = '';
				   aMatNGet 		 = '';
				   aHeadProc 		 = 'ColChk$|Btn1$|Btn2$|DtExe$dDtExe|cHorIniSExe$cHorIni|cHorFimSExe$cHorFim|cCodPadSExe$cCodPad|cCodProSExe$cCodPro|cDesProSExe$cDesPro|cQtdSExe$nQtdSol|cViaSExe$cViaAc|cTecSExe$cTecUt|nRedAcreSExe$nRedAcre|nVlrUniSExe$nVlrApr|nVlrTotSExe$nVlrTAp';
				   break;
  }
}
//--------------------------------------------------------------------
// Monta matriz genericas carrega procedimento por procedimento		  
//--------------------------------------------------------------------
cBusca   = "";
cTimeOut = 0;
cProfAntG= "";

function fCarregaTabelaHon(aMatTabRel, aMatValG, cMostraSer,lAltera, cSeqRefAtu) {
  
var aMatTabAux = aMatTabRel.split('|')
var cSeqCont = '0';
var aCampos = Array();
var aLinhas = Array();
var nRep    = 0;
var aAliasB = ['6', '7'];
//--------------------------------------------------------------------
// Para as tabelas informadas											  
//--------------------------------------------------------------------
   for (var x = 0; x < aMatTabAux.length; x++) {
	   //--------------------------------------------------------------------
	   // Para habilitar o click ou nao na tabela e pegar o nome da tabela 	  
	   //--------------------------------------------------------------------
	   var aMatTab  = aMatTabAux[x].split('$');
	   var cTable 	 = aMatTab[0];
	   var cTipoAcao= aMatTab[1];
	   //--------------------------------------------------------------------
	   // Carrega variaveis													  
	   //--------------------------------------------------------------------
	   fMontMatGer('I', cTable);
	   //--------------------------------------------------------------------
	   // Se vai carregar na matriz original ou vai espelhar em outra matriz	  
	   //--------------------------------------------------------------------

	   var aMatCampVal = '';
	   var aMatCol 	= aMatCap.split("|");                        
	   var cTpAut 		= "1";
	   //--------------------------------------------------------------------
	   // Verifica toda a matriz com campos e valores							  
	   // associa o valor retornado ao campo do form							  
	   //--------------------------------------------------------------------
	   xHeader = ""
	   xCols = ""
	   var aHeader = new Array()
	   var aCols = new Array()

	   
	   //Coloquei aqui a inclusão do campo cseqbd6 e cseqbd7
	   //rrr
	   for (var nK = 0 ; nK < aAliasB.length; nK++) {
		   if (typeof document.getElementById('cSeqBD' + aAliasB[nK]) != 'undefined' && document.getElementById('cSeqBD' + aAliasB[nK]) != null) {
			   document.getElementById('cSeqBD' + aAliasB[nK]).style.display = 'none';
			   var nQtdLabel  = document.getElementsByTagName("label").length;
			   for (var nI = 0; nI < nQtdLabel; nI++) {
				   if ( (document.getElementsByTagName("label")[nI].innerHTML.trim().toUpperCase().match(new RegExp('CSEQBD' + aAliasB[nK]))) != null ) { 
					   document.getElementsByTagName("label")[nI].style.display = 'none';
				   }
			   }
		   }
	   }
	   
	   
	   for (var z = 0; z < aMatValG.length; z++){
		   var cValores = ""
		   var aMatVal = aMatValG[z];
		   for (var y = 0; y < aMatVal.length; y++) {
			   var aMatColVal 	= aMatVal[y].split("!");
			   var cCampo 		= aMatColVal[0]
			   var cConteudo 	= aMatColVal[1]    
			   //--------------------------------------------------------------------
			   // Conforme o tipo de autorizacao muda a cor da linha					  
			   //--------------------------------------------------------------------
			   if (cCampo == 'cStatus') {
				   cTpAut = ( (cConteudo=='S') ? "1" : "0" );
				   //indica a linha que será marcada como criticada
				   if(cTpAut == "0"){
					   aLinhas.push(z+1);
				   }
			   }
			   //--------------------------------------------------------------------
			   // Faz o De x Para da variável do protheus com a da guia				  
			   //--------------------------------------------------------------------
			   for (var i = 0; i < aMatCol.length; i++) {
				   var aMatCampoForm = aMatCol[i].split("$");
				   if (aMatCampoForm[1]==cCampo) { 
					   cCampo = aMatCampoForm[0];
					   if(cCampo=="dDtExe" && !isDitacaoOffline()){
						   
						   //Necessário a versão do WSPLSXFUN que cria o cDataServ na função MntHidden
						   cConteudo = cDataServ.value; 
					   }
					   break;
				   }	
			   }
			   if (typeof cCampo != 'undefined' && document.getElementById(cCampo) != null) {
				   document.getElementById(cCampo).value = cConteudo;
				   //--------------------------------------------------------------------
				   // Matriz para compatibilizar tabelas exemplo. solicitacao com execucao.  
				   // Como a quantidade de campos e diferente deve dizer onde o valor da	   
				   // solicitacao vai ficar na execucao									   
				   //--------------------------------------------------------------------
				   aMatCampVal += cCampo + "$" + cConteudo + "|"
				   cValores +=  cCampo + "$" + cConteudo + ";"
			   }
			   if (cCampo == 'cSeqMov') {
				   cSeqCont = cConteudo;
			   }
		   }	

		   //--------------------------------------------------------------------
		   // Insere e limpa a linha												  
		   //--------------------------------------------------------------------
		   if (!wasDef( typeof(cGrids) ) ){
			   if(wasDef( typeof(document.getElementById("cGrids")))){
				   cGrids = document.getElementById("cGrids")
			   }	
		   }
		   if (wasDef( typeof(cGrids) ) ){	
			   var aGrids = cGrids.value.split("@");
			   var nPos = 0
			   var nLen = aGrids.length		
			   
			   xHeader += "@"
			   for(nI=0; nI < nLen; nI++){
				   //Localiza o grid
				   nPos = aGrids[nI].indexOf(cTable+"~");
				   if(nPos > -1){
					   //Adiciona linha no xCols
					   xCols += "@"
					   //Retorna os campos do grid
					   aCampos = aGrids[nI].split("~")[1].split('|')[0].split(',') ;
					   aDescri = aGrids[nI].split("~")[1].split('|')[1].split(',') ;

					   var nLenCmp = aCampos.length; //Numero de campos do grid

					   var aLinha = cValores.split(";");

					   var aCmpVal = new Array();
					   //Separa campo e valor
					   for(nJ = 0; nJ < aLinha.length; nJ++){
						   aCmpVal.push(aLinha[nJ].split('$'));
					   }
					   //Cria o Array de valores
					   var aValores = new Array(nLenCmp)
					   for(nJ = 0; nJ < aLinha.length; nJ++){
						   var nCmp = 0;
						   var nPosCmp = false;
						   while(nPosCmp == false && nCmp < nLenCmp){
							   if ((typeof aCmpVal[nCmp]) != "undefined") {
								   nPosCmp = aCmpVal[nCmp][0] == aCampos[nJ];
							   }

							   nCmp++;
						   }
						   if(nPosCmp){
							   --nCmp
							   aValores[nJ] = aCmpVal[nCmp][1];
						   }
					   }
					   
					   if(z==0){
						   aHeader.push({name:'Alterar'});
						   aHeader.push({name:'Excluir'});
					   }
					   aCols.push([]);
					   nLenCols = aCols.length -1;
					   aCols[nLenCols].push({field:'RECNO', value:'0#' + Trim((z+1).toString())/*.trim()*/ + "," + '"' + cTable + '"' + ",4"});
					   aCols[nLenCols].push({field:'RECNO', value:'1#' + Trim((z+1).toString())/*.trim()*/ + "," + '"' + cTable + '"' + ',5,true,"","",cCampoDefault'}); //Bot? Excluir
					   
					   nLenCmp--;
					   for(nJ = 0; nJ < nLenCmp; nJ ++){

						   var cCampo  = aCampos[nJ];//Nome da variavel
						   var cValor = aValores[nJ];//Valor do campo
						   var cTitulo = aDescri[nJ];//Descricao do campo
						   if(cCampo != ""){
							   if(z==0){
								   aHeader.push({name: cTitulo }) ;
								   xHeader += cCampo + "|";
							   }
							   aCols[nLenCols].push({field:cCampo, value: cValor });  
							   
							   xCols += cValor;
							   xCols += (nJ != nLenCmp - 1 ) ? "|" : "";
						   }

					   }
				   
				   }
			   }
		   }
		   //Limpa os campos da tela
		   fLimpaCmpGridGen(aCampos,cCampoDefault.replace(/\|/g,","));
	   }
	   
	   if (cTipoAcao == '0') {
		   aBtnFunc = "[{info:'Alterar',img:'refresh.gif',funcao:''},{info:'Excluir',img:'004.gif',funcao:''}]";
	   }else{
		   aBtnFunc = "[{info:'Alterar',img:'refresh.gif',funcao:'fVisRecGen'},{info:'Excluir',img:'004.gif',funcao:'fGetDadGen'}]";
		   //var cSeqRefAtu = typeof cSeqRefAtu == "undefined"  ? "" : cSeqRefAtu

		   Ajax.open("W_PPLSETACMP.APW?cGrid=" + cTable + "&cHeader=" + xHeader + "&cCols=" + xCols +  "&aLinhas=" + aLinhas,  { //+ "&cSeqRefAtu=" + cSeqRefAtu, { 
			   /*callback: CarregaLiberacao,*/
			   error: ExibeErro 
		   });
	   }
   
	   if(cTable == "TabExeSer"){
			   oTabExeSer = new gridData(cTable,'630','300')
					   //--------------------------------------------------------------------
					   // Monta Browse 
					   //--------------------------------------------------------------------
					   oTabExeSer.load({	fFunName:'',
					   nRegPagina:1,
					   nQtdReg:getField("nQtdReg"),
					   nQtdPag:getField("nQtdPag"),
					   lOverflow:true,
					   lShowLineNumber:true,
					   lChkBox:false,
					   aBtnFunc:aBtnFunc,
					   aHeader: aHeader,
					   aCols: aCols,
					   cColLeg:"",
					   aCorLeg:"",
					   cWidth:"770"});
							   
										   
	   }else if(cTable == "TabSolSer"){
		   oTabSolSer = new gridData(cTable,'630','300')
					   //--------------------------------------------------------------------
					   //?Monta Browse 
					   //--------------------------------------------------------------------
					   oTabSolSer.load({	fFunName:'',
										   nRegPagina:1,
										   nQtdReg:getField("nQtdReg"),
										   nQtdPag:getField("nQtdPag"),
										   lOverflow:true,
										   lShowLineNumber:true,
										   lChkBox:false,
										   aBtnFunc:aBtnFunc,
										   aHeader: aHeader,
										   aCols: aCols,
										   cColLeg:"",
										   aCorLeg:"",
										   cWidth:"770"});
	   } else if (cTable == "TabExe"){
		   oTabExe = new gridData(cTable,'630','300')
					   //--------------------------------------------------------------------
					   // Monta Browse 
					   //--------------------------------------------------------------------
					   oTabExe.load({	fFunName:'',
					   nRegPagina:1,
					   nQtdReg:getField("nQtdReg"),
					   nQtdPag:getField("nQtdPag"),
					   lOverflow:true,
					   lShowLineNumber:true,
					   lChkBox:false,
					   aBtnFunc:aBtnFunc,
					   aHeader: aHeader,
					   aCols: aCols,
					   cColLeg:"",
					   aCorLeg:"",
					   cWidth:"770"});
					   
	   }
	   
	   for(nI=0;nI<aLinhas.length;nI++){
		   if(cTable == "TabExeSer"){
			   oTabExeSer.setLinhaCor(aLinhas[nI] ,'colfixeInd','#E49494')
		   }else{
			   oTabExe.setLinhaCor(aLinhas[nI] ,'colfixeInd','#E49494')
		   }
	   }
	   
   }
   
   //rrr
   //Ocultar linhas dos grid da BD7 e BD6, do sequencial de controle
   if (document.getElementById("cTp").value == '6') {
	   if( eval("o" + cTable).aCols.length > 0 ) {
		   var z = 0;
		   var w = 0;
		   var oCell = null;
		   var oTable = eval("o" + cTable).getObjCols();

		   while (z < oTable.rows.length){
			   for (var w = 0; w <= (oTable.rows[z].cells.length - 1); w++) {
				   var lAchou = false;
				   oCell = oTable.rows[z].cells[w];
				   //Encontrou a coluna do cSEQBD6
				   var idTb = eval("o" + cTable).cNameTab;
				   var nTam = (cTable == 'TabExeSer') ? 16 : 12;  
				   col = $( "#" + idTb + " tr th:nth-child(" + (nTam) + "), " + "#" + idTb + " tr td:nth-child(" + (nTam) +")");
				   col.hide();		
				   lAchou = true;				
			   }
			   if(lAchou)
				   break;
			   z++;
		   }
	   }
   }	
}


//--------------------------------------------------------------------
// Monta as rdas														  
//--------------------------------------------------------------------
function fExe(cB) {
   var cB = (wasDef( typeof cB)) ? cB : '';

	 if(document.getElementById("cTp").value != "5" && document.getElementById("cTp").value  != "6"){

		 Ajax.open("W_PPLSMONALL.APW?cBusca="+cB, { 
		  callback: CarregaExe, 
		  error: ExibeErro
	  });
 }

}

//--------------------------------------------------------------------
// Monta as rdas														  
//--------------------------------------------------------------------
function fSol(cB) {
   var cB = (wasDef( typeof cB)) ? cB : '';

	 Ajax.open("W_PPLSMONALL.APW?cBusca="+cB, {
	  callback: CarregaSol,
	  error: ExibeErro
  });

}

//--------------------------------------------------------------------
// Monta as rdas														  
//--------------------------------------------------------------------
function fExecut(cVar) {   
  var aResult = cVar.split("|");    

   if(document.getElementById("cTp").value == "5"){
		  document.getElementById("cRda").value = aResult[0];
  }     

  Ajax.open("W_PPLDADRDA.APW?cRda=" + aResult[0] + "&cCodLoc=" + "&lAll='true'", { 
	  callback: CarregaRda2, 
	  error: ExibeErro 
  });
}
//--------------------------------------------------------------------
// Monta campos conforme processamento da rdas							  
//--------------------------------------------------------------------
function CarregaExe(v) {
  
   CarregaProSaudeFilHon(v);

}


function CarregaSol(v) {

 var aResult = v.split("|");
 var i = 0;
 var j = 0;
 var lEntrou = false;
   //--------------------------------------------------------------------
 // Verfiica se e solicitacao ou execucao
 //--------------------------------------------------------------------
   var e = document.getElementById("cProSol");
	 if (LastkeyID == 46){
	   e.options[0] = new Option('-- Selecione um Solicitante --', '');
	   j = 1;
   }
   for (i; i < aResult.length; i++) {
	   var aProf = aResult[i].split("$");
	   if (aProf.length>1 && aProf[1] != '')
		   e.options[i+j] = new Option(aProf[1], aProf[0]);
		   if (aProf[0]!=''){
			   lEntrou = true;
		   }
   }
   if (!lEntrou){
	   e.options[0] = new Option('-- ['+cString+'] nao localizado --', '');
   }
   
}

function CarregaRda2(v) {
  var aResult = v.split("|");
  document.getElementById("cCnpjCpfExe").value	= aResult[2];
  document.getElementById("cCnesExe").value 		= aResult[4];
   
   setDisable("cNomExe",false);
   fExe()
}

function roundNumber(num, scale) {
   var number = Math.round(num * Math.pow(10, scale)) / Math.pow(10, scale);
   if(num - number > 0) {
	   return (number + Math.floor(2 * Math.round((num - number) * Math.pow(10, (scale + 1))) / 10) / Math.pow(10, scale));
   } else {
	   return number;
   }
}
//--------------------------------------------------------------------
// Calculo de valores													  
//--------------------------------------------------------------------
function fCalcValRedAcr(nVal, nQtd, cCampo, nRedAcr) {
  
  var nRedAcres;
  var nTotal;
  var cTotal;

  if(nRedAcr == null || nRedAcr.trim() == "") {
		   nRedAcres = 1.0;
	   nRedAcreSExe.value = "1.00";
  }else {
	   nRedAcres = parseFloat(nRedAcr.replace(",", "."));
  }
  if(nRedAcres == 0){
	nRedAcres = 1.0;
	nRedAcreSExe.value = "1.00";
  }
  if (nRedAcreSExe.value.indexOf(".") < 0  ) {
	 nRedAcreSExe.value = nRedAcreSExe.value + ".00"; 
  } else if (nRedAcreSExe.value.length < 4) {
	  var nDif = (4 - nRedAcreSExe.value.length);
	   for (var nI = 0; nI < nDif; nI++){
		   nRedAcreSExe.value += '0';
	   }
  }  

  if(nQtd == null || nQtd.trim() == "")
	 nQtd = "0";

  if(nVal == null || nVal.trim() == "") {
	 nVal = "0";
	 nVlrUniSExe.value = MaskMoeda("0".replace(/\D/g, ""));
  }	  

   if (nVal.length > 6) {
	   nVal = nVal.replace(".","");
   }

  nTotal = (parseFloat(nQtd.replace(",", ".")) * parseFloat(nVal.replace(",", "."))) * nRedAcres;
  nTotal = roundNumber(nTotal, 2);
  cTotal = nTotal.toFixed(2);
  if (cTotal.indexOf(".") < 0) {
	 cTotal = cTotal + ".00"; 
  }
  cCampo.value = MaskMoeda(cTotal.replace(/\D/g, ""));
}

function fCalcValHon(nVal, nQtd, cCampo) {
  cCampo.value = MaskMoeda((nQtd * nVal.replace(/\D/g, "")));
}
//--------------------------------------------------------------------
// Soma valores													  	  
//--------------------------------------------------------------------
function fSoma(nVal, cCampo) {
  return MaskMoeda( parseFloat(cCampo.value.replace(/\D/g, "")) + parseFloat(nVal.replace(/\D/g, "")) );
}

function fSubtrai(nVal, cCampo) {
  return MaskMoeda( parseFloat(cCampo.value.replace(/\D/g, "")) + parseFloat(nVal.replace(/\D/g, "")) );
}
//--------------------------------------------------------------------
// Verifica se o numero da autorizacao existe e mostra os dados		  
//--------------------------------------------------------------------
function fCalcValHonTot(cRetCam,cPesCam,cTable, cTipo) {
   var nf 			= 0;
   var y 			= 0;
   var x 			= 0;
   var cCampo 		= '';
   var celula		= '';
   var conteudo	= '';
   var oTable 		= '';
   var	aMatCampAux = aMatCap.split("|");
   var cTipoGuia = document.getElementById("cTp").value;
  
  
  if ( (cTable == "TabExeSer" && typeof oTabExeSer != "string" && oTabExeSer.aCols.length > 0)
	   || (cTable == "TabOutDesp" && typeof oTabOutDesp != "string" && oTabOutDesp.aCols.length > 0)
   ){
	   //Recupera os dados do grid
	   var oTable = cTable == "TabExeSer" ? oTabExeSer.getObjCols() : oTabOutDesp.getObjCols();
   
	   document.getElementById(cRetCam).value = '0,00';
	   //--------------------------------------------------------------------
	   // Le todas as linhas da tabela e faz a somatoria						  
	   //--------------------------------------------------------------------
	   for (var y = 0; y < oTable.rows.length; y++) {
	   
		   nf = 0;
		   //if(cTipo == '5')
		   //	nf = 1;
		   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {
			   if (oTable.rows[y].className != "TextoNegPeq") {
				   if( (x - 2) < aMatCampAux.length ){
					   if(aMatCampAux[x - 2] != "undefined"){
						   cCampo = aMatCampAux[x - 2].split("$")[1];
						   if (cCampo == cPesCam) {
							   
							   conteudo = getTC(oTable.rows[y].cells[x + 1 - nf]);
							   
							   if (conteudo.replace(/\D/g, "") != ''){
								   document.getElementById(cRetCam).value = fSoma(conteudo, document.getElementById(cRetCam));
							   }
								   
						   }
					   }
				   }
			   }	
		   }
	   }
   if (cTipoGuia == "5") {
	  document.getElementById("nTotPro").value = document.getElementById(cRetCam).value;
	  document.getElementById(cRetCam).value = MaskMoeda( parseFloat(document.getElementById(cRetCam).value.replace(/\D/g, "")) + totalArray );
   }
   }
   
}
//--------------------------------------------------------------------
// Verifica se o numero da autorizacao existe e mostra os dados (Inter/Honora) 
//--------------------------------------------------------------------
function fChamHoID(cNumeHoId,cTipo,cTpAut) {
   var cRda	= document.getElementById("cRda").value;
   
   cTipoGui = cTipo;
  //--------------------------------------------------------------------
  // Verifica se foi informado a chave									  
  //--------------------------------------------------------------------
  if (cNumeHoId == "") {
	   if ( cTipoGui == '3') 
			alert("Informe o numero da Guia de Internação");
	   else alert("Informe o numero da Guia de Honorário");
	  return;
  }              
  //--------------------------------------------------------------------
  // Executa o metodo													  
  //--------------------------------------------------------------------
  if (cTipoGui=='5') {
	   Ajax.open("W_PPLSHON.APW?cNumeAut=" + cNumeHoId.replace(/\D/g, "") + "&cTp=" + cTipo + "&cTpAut=" + cTpAut + "&cRda=" + cRda, { 
		   callback: CarregaHonInd2,
		   error: ExibeErro 
	   });
	}else if(cTipoGui=='11'){
	   //valida a quantidade de caracteres digitados 
		if(!fValQtdCarac(cNumeHoId.replace(/\.|-/gi,""),18)){
			  return;                                                                                                   
		}
	   Ajax.open("W_PPLSHON.APW?cNumeAut=" + cNumeHoId.replace(/\D/g, "") + "&cTp=" + cTipo + "&cTpAut=" + cTpAut+ "&cRda=" + cRda, {
		   callback: CarregaProrInt,
		   error: ExibeErro
	   });

   }else{
	   Ajax.open("W_PPLSCHALIB.APW?cNumeAut=" + cNumeHoId.replace(/\D/g, "") + "&cTp=" + cTipo + "&cTpAut=" + cTpAut + (isDitacaoOffline() ? "&cTipoOrigem=digitacao" : "") + "&cTipoGuia="+document.getElementById("cTp").value + "&cCodRda=" + document.getElementById("cRda").value + "&cCodLoc="+ document.getElementById("cCodLoc").value, { 
		   callback: CarregaHonInd,
		   error: ExibeErro 
	   });
   }
}

//--------------------------------------------------------------------
// Carrega os valores da internação na guia de prorrogação.
//--------------------------------------------------------------------
function CarregaProrInt(v) {
   var aMatCabIte = v.split("<");
   var aMatCab = aMatCabIte[0].split("|");
   var cPSol = "";
   var cNSol = "";
   var cRda = "";
   var cCodLoc = "";
   var cSol ;
   var nIndiceSol;
   var lDupGui	= true;
   cIndCombo 		= "";
	   
   //Se o tamanho for 4, recebeu mais uma posicao no cResult referente a mensagem de guia duplicada
   if (aMatCabIte.length > 3){
	   DupGuiMod(aMatCabIte[3]);
   }
   //--------------------------------------------------------------------
   // Verifico se a estrutura dos itens foram enviadas
   //--------------------------------------------------------------------
   if (typeof aMatCabIte[1] == "undefined") {
	   alert("Estrutura indefinida");
	   return;
   }
   var aMatIte = aMatCabIte[1].split("~");

   if (typeof aMatCabIte[2] == "undefined") {
	   alert("Estrutura indefinida");
	   return;
   }
   var aMatExe = aMatCabIte[2].split("~");
   var aMatIteG = new Array()

   //--------------------------------------------------------------------
   // Cabecalho
   //--------------------------------------------------------------------
   for (var i = 0; i < (aMatCab.length - 1); i++) {
	   var aCamVal = aMatCab[i].split("!");
	   //--------------------------------------------------------------------
	   // Somente se foi passado o nome do campo
	   //--------------------------------------------------------------------
	   if (aCamVal[0] != "") {

		   if (aCamVal[0] == "cComboSol") {

			   cSol = aCamVal[1].split(";");

			   for(var j = 0; j < (cSol.length-1); j++){

				   cPSol = cSol[j].split("$")[0];
				   cNSol = cSol[j].split("$")[1];

				   if(cSol[j].split("$")[2] == "T")
					   nIndiceSol = j;

				   if (cNSol != "" && cPSol != "") {

					   $('#cProSol').append($('<option>', {
						   value: cPSol,
						   text: cNSol
					   }));

				   $("#cProSol").attr("disabled", false); //Desabilita o campo

				   }
			   }
			   var cCampoPro = document.getElementById("cProSol");
			   cCampoPro.selectedIndex = nIndiceSol + 1;
		   }else{
			   var cCampo = document.getElementById(aCamVal[0]);

			   if (cCampo != null) {

				   if (aCamVal[0] != "cCbosSol" && aCamVal[0] != "cNomeSol" && aCamVal[0] != "cProSol" && aCamVal[0] != "cQtdDSol") {
					   cCampo.value = aCamVal[1];
				   } else if (aCamVal[0] == "cNomeSol") {
					   cNSol = aCamVal[1];
				   } else if (aCamVal[0] == "cProSol") {
					   cPSol = aCamVal[1];
					   cCampo.value = aCamVal[1];
				   } else if (aCamVal[0] == "cCbosSol") {
					   var cCbo = aCamVal[1].split("$");
					   cCbo[0] = cCbo[0].substring(0,3);						
					   cIndCombo += "cCbosSol;" + cCbo[0].trim() + "|"; //Concateno o indice pra atribuir no fim de tudo pra a combo não perder a referência por causa do ajax
					   $('#cCbosSol option[value^="' + cCbo[0].trim() + '"]').prop('selected', true);			
				   }else if(aCamVal[0] == "cRda"){
					   cRda = aCamVal[1];
				   }else if(aCamVal[0] == "cCodLoc"){
					   cCodLoc = aCamVal[1];
				   }

				   if (document.getElementById("toolTip" + aCamVal[0]) != null) {
					   document.getElementById("toolTip" + aCamVal[0]).setAttribute("data-title", cCampo.value);
				   }

			   }
		   }
	   }
   }
   
   gatilhoHiddenJS("cProSol");
   
}

//--------------------------------------------------------------------
// Pega o retorno														  
//--------------------------------------------------------------------
function CarregaHonInd(v) {   
 var aMatCabIte  = v.split("<");
 var aMatCab 	= aMatCabIte[0].split("|");
 //--------------------------------------------------------------------
 // Verifico se a estrutura dos itens foram enviadas					  
 //--------------------------------------------------------------------
 if (typeof aMatCabIte[1] == "undefined") {
	 alert("Estrutura indefinada");
	 return;
 }
 
 //Se o tamanho for 3, recebeu mais uma posicao no cResult referente a mensagem de guia duplicada
 if (aMatCabIte.length > 2){
	 DupGuiMod(aMatCabIte[2]);
 }
 
 var aMatIte = aMatCabIte[1].split("~");     
 var aMatExe = [];                                                     
 document.getElementById('cNumeHoId').value = '';
 var d = new Date();
 document.getElementById('dDtEmissao').value = d.toLocaleDateString();
 //--------------------------------------------------------------------
 // Cabecalho															  
 //--------------------------------------------------------------------
 for (var i = 0; i < (aMatCab.length - 1); i++) {
	 var aCamVal = aMatCab[i].split("!");
	 //--------------------------------------------------------------------
	 // Somente se foi passado o nome do campo								  
	 //--------------------------------------------------------------------
	 if (aCamVal[0] != "") {
		 var cCampo = document.getElementById(aCamVal[0]);

		 if (aCamVal[0] == 'cCnesSol') {//15-Código CNES CnesAut
			   document.getElementById('cCnesExe').value = aCamVal[1];
		   }

		 if (aCamVal[0] == 'cCnpjCpfSol'){ 
		   document.getElementById('cCnpjCpfExe').value = aCamVal[1];
		 }		

		 if ((cCampo != null) && (aCamVal[0] != 'cFormNumber') && (aCamVal[0] != 'dDtEmissao')){
			   //se é combobox usa função para trocar valor do campo
			   if( cCampo.options == undefined) { cCampo.value = aCamVal[1]; }
			   else { changeComboVal(aCamVal[0], aCamVal[1], "value"); }
		 }
			
		 if (aCamVal[0] == 'cSenha') {
			   if (aCamVal[1].replace(/ /g, "") == "") {
				   alert("Não é possível realizar o Honorário Medico!\nInternação ainda não foi realizada.");
				   return;
			   }        
		 }
	 }
 }
 
	 fExecut(document.getElementById('cNomeRdaExe').value);                                                    
   fGetDadGen(0, "TabExeSer" ,6);
   fGetDadGen(0, "TabExe" ,6);
 
 //--------------------------------------------------------------------
 // Botoes																  
 //--------------------------------------------------------------------
 if (document.getElementById("cNumeHoId").value == '') {
	   setDisable("bconfirma",false);
	   setDisable("bimprimir",true);
	   setDisable("bAnexoDoc",true);
	   
	   setDisable('bIncTabExeSer',false);
	   setDisable("bSaveTabExeSer",false);
	   
	   setDisable('bIncTabExe',false);
	   setDisable("bSaveTabExe",false);
	   
   } else {
	   FDisElemen('TPdh|TProce|Tdb|Tcr|TcrS|TcrE|BProc|TabExeSer', true);
	   setDisable("bconfirma",true);
	   setDisable("bimprimir",false);
	   setDisable("bAnexoDoc",false);

	   setDisable('bIncTabExeSer',true);
	   setDisable("bSaveTabExeSer",true);
	   
	   setDisable('bIncTabExe',true);
	   setDisable("bSaveTabExe",true);
	   
   }
   
}
//--------------------------------------------------------------------
// Pega o retorno														  
//--------------------------------------------------------------------
function CarregaHonInd2(v) {   
 var aMatCabIte  = v.split("<");
 var aMatCab 	= aMatCabIte[0].split("|");
 //--------------------------------------------------------------------
 // Verifico se a estrutura dos itens foram enviadas					  
 //--------------------------------------------------------------------
 if (typeof aMatCabIte[1] == "undefined") {
	 alert("Estrutura indefinida");
	 return;
 }
 var aMatIte = aMatCabIte[1].split("~");
 
 if (typeof aMatCabIte[2] == "undefined") {
	 alert("Estrutura indefinida");
	 return;
 }
 var aMatExe = aMatCabIte[2].split("~");
 var aMatIteG = new Array()
 //--------------------------------------------------------------------
 // Cabecalho															  
 //--------------------------------------------------------------------
 for (var i = 0; i < (aMatCab.length - 1); i++) {
	 var aCamVal = aMatCab[i].split("!");
	 //--------------------------------------------------------------------
	 // Somente se foi passado o nome do campo								  
	 //--------------------------------------------------------------------
	 if (aCamVal[0] != "") {
		 var cCampo = document.getElementById(aCamVal[0]);
		 //tive que fazer esse de-para pois o .aph foi criado em momento distinto do pplsmfun...
		 //a rotina generica nao estava atendendo
		   if (aCamVal[0] == 'cRegAns'){                    
			   document.getElementById('cRegAns').value = aCamVal[1];}
		   if (aCamVal[0] == 'cNomeRdaSol') {
				  document.getElementById('cNomeRdaAut').value = aCamVal[1];}
		   if (aCamVal[0] == 'cRda') {
			   document.getElementById('cCnpjCpfAut').value = aCamVal[1];}			
		   if (aCamVal[0] == 'cCnesSol') 	   {
			   document.getElementById('cCnesAut').value = aCamVal[1];}			

		   if (aCamVal[0] == 'cCnpjCpfSol'){ 
			   document.getElementById('cCnpjCpfExe').value = aCamVal[1];}
		   //campo14
		   if (aCamVal[0] == 'cNomeSol'){ 
			   document.getElementById('cNomeRdaExe').value = aCamVal[1]}
		   
		   //campo18
		   if (aCamVal[0] == 'cNomeSolT') { 
			   fExe(aCamVal[1]);}
		   
		   if (aCamVal[0] == 'cDtEmiss'){                    
			   document.getElementById('dDtEmissao').value = aCamVal[1];}
		   
		   if (aCamVal[0] == 'cSeqMov'){                    
			   document.getElementById('nSeqRef').value = aCamVal[1];}

		   if (aCamVal[0] == 'cMatric')   {  
				  document.getElementById('cNumeCart').value = aCamVal[1];}
		   if (aCamVal[0] == 'cNomeUsr') {
				  document.getElementById('cNomeUsu').value = aCamVal[1];}

		   if (aCamVal[0] == 'cGrPar')  {
			   document.getElementById('cGrPar').value = aCamVal[1];}
		   //campo15
		   if (aCamVal[0] == 'cCnesSolT')  {
			   document.getElementById('cCnesExe').value = aCamVal[1];}
		   
		   if (aCamVal[0] == 'cSenha')  {
			   document.getElementById('cGuiaInter').value = aCamVal[1];}				
					   
		   if (aCamVal[0] == 'cObs')  {
			   document.getElementById('cObs').value = aCamVal[1];}
			   
		   if (aCamVal[0] == 'cAtendRN')  {
			   document.getElementById('cAtendRN').value = aCamVal[1];}
		   
		   if (aCamVal[0] == 'dDataIniFat')  {
			   document.getElementById('dDataIniFat').value = aCamVal[1];}
			   
		   if (aCamVal[0] == 'dDataFimFat')  {
			   document.getElementById('dDataFimFat').value = aCamVal[1];}
	 }
 }                                                  
 //--------------------------------------------------------------------
 // Quando esta buscando dado de um honorario							  
 //--------------------------------------------------------------------
 if ( cTipoGui == '5' )  {
	   //--------------------------------------------------------------------
	   // Alimenta os tabelas de servicos	matriz com linhas de dados				 
	   //--------------------------------------------------------------------

	   for (var i = 0; i < aMatIte.length; i++) {
		   //--------------------------------------------------------------------
		   // Matriz com os campos e valores SERVICO								  
		   //--------------------------------------------------------------------
		   if (aMatIte[i] != "") {
			   //--------------------------------------------------------------------
			   // Aprimeira posicao da matriz aMatval e o tipo de servico a segunda      		
			   // e se vai ser exibido ou nao da terceira em diante contem valores dos campos	
			   //--------------------------------------------------------------------
			   var aMatVal = aMatIte[i].split("@");
			   //--------------------------------------------------------------------
			   // A segunda posicao [1] retorna se e possivel exibir para uma rda o procedimento  
			   //--------------------------------------------------------------------
			   var cMostraSer = aMatVal[1].split("!")[1];
			   //--------------------------------------------------------------------
			   // Solicitacao/Execucao de servico		  								  	   
			   // Relacionamento entre solicitacao e execucao Nome da tabela e tipo 0 nao    
			   // permite click na linha da tabela e matriz de base para espelho da execucao 
			   //--------------------------------------------------------------------
			   aMatIteG.push(aMatVal)
		   }
	   }
	   fCarregaTabelaHon('TabExeSer$0', aMatIteG, cMostraSer,false);
	   //--------------------------------------------------------------------
	   // Alimenta os tabelas de servicos	matriz com linhas de dados				 
	   //--------------------------------------------------------------------
	   aMatIteG = new Array()	
	   for (var i = 0; i < aMatExe.length; i++) {
		   //--------------------------------------------------------------------
		   // Matriz com os campos e valores SERVICO								  
		   //--------------------------------------------------------------------
		   if (aMatExe[i] != "") {
			   //--------------------------------------------------------------------
			   // Aprimeira posicao da matriz aMatval e o tipo de servico a segunda      		
			   // e se vai ser exibido ou nao da terceira em diante contem valores dos campos	
			   //--------------------------------------------------------------------
			   var aMatVal = aMatExe[i].split("@");
			   //--------------------------------------------------------------------
			   // A segunda posicao [1] retorna se e possivel exibir para uma rda o procedimento  
			   //--------------------------------------------------------------------
			   var cMostraSer = aMatVal[1].split("!")[1];
			   //--------------------------------------------------------------------
			   // Solicitacao/Execucao de servico		  								  	   
			   // Relacionamento entre solicitacao e execucao Nome da tabela e tipo 0 nao    
			   // permite click na linha da tabela e matriz de base para espelho da execucao 
			   //--------------------------------------------------------------------
			   aMatIteG.push(aMatVal)
		   }
	   }
	   fCarregaTabelaHon('TabExe$0', aMatIteG, "1",false);
	   //--------------------------------------------------------------------
	   // Habilita tela														  
	   //--------------------------------------------------------------------
	   FDisElemen('Tdb|Tcr|TcrS|TcrE|TabExeSer', false);
	   
	   document.getElementById("nVlrTotHor").value = "0.00";
   } else {   
	   //--------------------------------------------------------------------
	   // Marca todas as linhas para delecao									  
	   //--------------------------------------------------------------------
	   aTabDel = new Array("TabExeSer","TabExe")
	   for (var y = 0; y < aTabDel.length; y++) {
		   fGetDadGen(0, "TabExeSer" ,6);
	   }
	   FDisElemen('TPdh|TProce|Tdb|Tcr|TcrS|TcrE|BProc|TabExeSer', false);
   }    
 //--------------------------------------------------------------------
 // Botoes																  
 //--------------------------------------------------------------------
 if (document.getElementById("cNumeHoId").value == '') {
	   setDisable("bconfirma",false);
	   setDisable("bimprimir",true);
	   setDisable("bAnexoDoc",true);
	   
	   setDisable('bIncTabExeSer',false);
	   setDisable("bSaveTabExeSer",false);
	   
	   setDisable('bIncTabExe',false);
	   //setDisable("bSaveTabExe",false);
	   
   } else {
	   FDisElemen('TPdh|TProce|Tdb|Tcr|TcrS|TcrE|BProc|TabExeSer', true);
	   setDisable("bconfirma",true);
	   setDisable("bimprimir",false);
	   setDisable("bAnexoDoc",false);
	   
	   setDisable('bIncTabExeSer',true);
	   setDisable("bSaveTabExeSer",true);
	   
	   setDisable('bIncTabExe',true);
	   //setDisable("bSaveTabExe",true);
   }
}
//--------------------------------------------------------------------
// Monta tabela de procedimento e quantidades linha a linha			   
//--------------------------------------------------------------------
function fMontItensHon(cTp, cTable, nRecno) {
var rowCount = $('#tabTabExeSer tr').length;
   cTpR 		 = cTp;
   cTableR 	 = cTable;
   cQueryString = "&cRda=" + document.getElementById('cRda').value + "&cCodLoc=" + document.getElementById('cCodLoc').value;
	   
   //Desabilita botoes
   setDisable('bIncTabExeSer',true);
   setDisable("bSaveTabExeSer",true);
   
   //--------------------------------------------------------------------
   // Numero da liberacao													  
   //--------------------------------------------------------------------
   //var cChavSol = document.getElementById("cNumAut").value;
   
   //--------------------------------------------------------------------
   // Monta conteudo das tabelas solicitacao e execucao					  
   //--------------------------------------------------------------------
   if (cTable == "TabSolSer")
		aMatAux = "TabSolSer$oTabSolSer";
   else if (cTable == "TabExeSer") 
	   aMatAux = "TabExeSer$oTabExeSer";
   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   cStringEnvTab = "";
   aMat = aMatAux.split("|");
   var x = document.getElementById('cMsnBloInt').value;
   
   for (var i = 0; i < aMat.length; i++) {
	   aMatAux = aMat[i].split("$")
	   //Se o grid foi preenchido
	   if(typeof eval(aMatAux[1]) != "string" && eval(aMatAux[1]).aCols.length > 0){
		   //Recupera os dados do grid
		   oTable = eval(aMatAux[1]).getObjCols();
		   
		   fMontMatGer('A', aMatAux[0]);
		   
		   aMatCampAux = aMatCap.split("|");
		   for (var y = 1; y < oTable.rows.length; y++) {
			   nf = 0;                  
			   cStringEnvTab += "cSeq@"+getTC(oTable.rows[y].cells[0])+"$";
			   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {
			   
				   cCampo = aMatCampAux[x - 2].split("$")[1];
				   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
					   celula = oTable.rows[y].cells[x + 1 - nf];
					   
					   if (typeof celula.value == 'undefined' || celula.value == '')
							conteudo = getTC(celula);
					   else conteudo = celula.value;	
					   
					   cStringEnvTab += cCampo + "@" + conteudo + "$";
				   }
				   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;
			   }      
			   cStringEnvTab += "|";
		   }
	   }
   }
 //--------------------------------------------------------------------
 // Define parametros para uso na funcao de resultado					  
 //--------------------------------------------------------------------
 fMontMatGerHon(cTp, cTable);
 //--------------------------------------------------------------------
 // Matriz de campos													  
 //--------------------------------------------------------------------
 var aMatCol = aMatCap.split("|");
 var oTable = null
 var objSubJson = "";
 if(typeof eval("o"+cTable) != "string" && eval("o"+cTable).aCols.length > 0){
	   //oTable = document.getElementById(cTable);
	   oTable = eval("o"+cTable).getObjCols()
 }
 //var oTable  = document.getElementById(cTable);
 //--------------------------------------------------------------------
 // Tratamento inclusao ou alteracao									  
 //--------------------------------------------------------------------
 if (cTp == 'I' || cTp == 'A') {
	 switch (cTable) {
		 case "TabExeSer":
			   if (document.getElementById('cQtdSExe').value == "" || document.getElementById('cQtdSExe').value == "0") {
				   alert('Informe a quantidade de Serviço');
				   document.getElementById('cQtdSExe').focus();
				   //Habilita botoes
				   setDisable('bIncTabExeSer',false);
				   return;                                  
			   }
			   
			   if (document.getElementById('nVlrUniSExe').value == "" || (parseFloat(document.getElementById('nVlrUniSExe').value.replace(",","")) <= 0) ) {
				   alert('Informe o valor do Serviço.');   
				   document.getElementById('nVlrUniSExe').focus();
				   setDisable('bIncTabExeSer',false);
				   return;
			   }
			   
			   if (document.getElementById('cCodPadSExe').value == "" ) { 
				   alert('Informe o código da Tabela.');   
				   document.getElementById('cCodPadSExe').focus();
				   setDisable('bIncTabExeSer',false);				    
				   return;
			   }	
			   
			   if (document.getElementById('cCodProSExe').value == "" ) {
				   alert('Informe o código do Procedimento.');   
				   document.getElementById('cCodProSExe').focus();
				   setDisable('bIncTabExeSer',false);				    
				   return;
			   }	
			   break;
	 }        
	   //--------------------------------------------------------------------
	   // Verifica duplicidade												   
	   //--------------------------------------------------------------------
	   var nCol 		= 0;
	   if ( typeof oTable != "string" && oTable != null ) {
		   var nQtdLinTab  = oTable.rows.length;
	   }else{
		   var nQtdLinTab = 0
	   }
	   var cString 	= '1'+"|";
	   var cContChave  = document.getElementById(cChave).value;
	   if (cContChave == "") {
		  alert("Serviço não informado");
		  document.getElementById(cChave).focus();
		  //Habilita botoes
		  setDisable('bIncTabExeSer',false);
		  return;
	   }          
	   
	   if (document.getElementById("cGuiaInter").value == "") {
		  alert("Solicitação não informada");
		  document.getElementById("cGuiaInter").focus();
		  //Habilita botoes
		  setDisable('bIncTabExeSer',false);
		  return;
	   }
	   
	   if (document.getElementById("dDtExe").value == "") {
		  alert("Data do procedimento não informada");
		  document.getElementById("dDtExe").focus();
		  //Habilita botoes
		  setDisable('bIncTabExeSer',false);
		  return;
	   }
	   
	  var cGrauPar = ""
	  if (cTable == "TabExe"){
			  cGrPar = document.getElementById('cGrauPar').value;
	  }
   

	 //--------------------------------------------------------------------
	 // Monta envio das variaveis de sessao GET								  
	 //--------------------------------------------------------------------
	   cQueryString =	"&cRda="+document.getElementById('cRda').value+	
					   "&cNomeRdaExe="+document.getElementById('cNomeRdaExe').value+	
					   "&cGuiaInter="+document.getElementById('cGuiaInter').value+	
					   "&cGrPar="+cGrauPar+	
					   "&cNomExe=" + document.getElementById('cProExeDesc').value +
					   "&cCodSigExe="+document.getElementById('cCodSigExe').value+	
					   "&cNumCrExe="+document.getElementById('cNumCrExe').value+	
					   "&cChvBD6="+document.getElementById('cChvBD6').value+	
					   "&cEstSigExe="+document.getElementById('cEstSigExe').value+
					   "&cTissVer="+document.getElementById('cTissVer').value+
					   "&dDtExe="+document.getElementById('dDtExe').value;
					   
	 cCamGer = "";
   for (var i = 0; i < aMatCol.length; i++) {
	   var aMatColAux = aMatCol[i].split("$");
	   cCampo = document.getElementById(aMatColAux[0]);
	   if (typeof cCampo != 'undefined' && cCampo != null && aMatNGet.indexOf(aMatColAux[1])==-1) {
		   cQueryString += "&" + aMatColAux[1] + "=" + cCampo.value;
			 
		   if(typeof oGuiaOff != 'undefined'){
			   if(cTp == 'I'){
				   objSubJson += '"' + aMatColAux[1] + '"' + ':{ "defaultValue" : ' + '"' + cCampo.value.trim() + '"' + ', "actualValue": ' + '"' + cCampo.value.trim() + '"}';
				   objSubJson += ","
			   }else{
				   objSubJson = getObjects(oGuiaOff, "sequen",nRecno);
				   if(objSubJson.length > 0){
					   objSubJson = objSubJson[0];
					   if(objSubJson[aMatColAux[1]] != undefined){ 
						   objSubJson[aMatColAux[1]].actualValue = cCampo.value.trim();
					   }
				   }
			   }
		   }
	   }
   }

   if(cTp == 'I' && typeof oGuiaOff != 'undefined'){
	   objSubJson = "{" + objSubJson
	   objSubJson +=  '"sequen":' + '"' + (typeof eval(aMatAux[1]) != "string" ? (eval(aMatAux[1]).aCols.length+1).toString() : "1") + '",';
	   objSubJson +=  '"lNewIte":true,';
	   objSubJson +=  '"lDelIte":false}';
   }	            
	 //--------------------------------------------------------------------
	 // Sequencia do procedimento											  
	 //--------------------------------------------------------------------
	 if (nQtdLinTab!=0)
			cSeqMov = nQtdLinTab.toString();
	   else cSeqMov = '1'; 	
	 //--------------------------------------------------------------------
	 // Validacao															  
	 //--------------------------------------------------------------------
	 for (var i = 1; i < nQtdLinTab; i++) {
		 //--------------------------------------------------------------------
		 // Verfica se existe um registro igual na tabela						  
		 //--------------------------------------------------------------------
		 var lResult = false;   
		   //--------------------------------------------------------------------
		   // verifica se algum campo foi alterado			   					   
		   //--------------------------------------------------------------------
		   if (oTable.rows[i].style.backgroundColor != "") {
			   cSt 	= "0";
			   cSeqMov = getTC(oTable.rows[i].cells[0]);//getTC(document.getElementById("Cont" + i));
			   //--------------------------------------------------------------------
			   // Verifica se alguma campo que necessita de checar a regra novamente foi alterado
			   //--------------------------------------------------------------------
			   lResult = true;
			   var nRes = (cTp == 'I') ? 2 : 3;
			   for (var y = nRes; y < oTable.rows[i].cells.length; y++) {
				   var aMatColAux = aMatCol[y - nRes].split("$");
				   cCampo = document.getElementById(aMatColAux[0]);
				   if (cCampo != null &&  (getTC(oTable.rows[i].cells[y]) != cCampo.value)) {
					   cSt = "1";
					   if (aValAlt.indexOf(aMatColAux[0]) != -1) lResult = false;
				   }
			   }
			   //--------------------------------------------------------------------
			   // Altera a tabela sem checar a regra novamente								  
			   //--------------------------------------------------------------------
			   if (lResult) {
				   //fGetDadGen(nRecno, cTable ,4,true,cCampo.value,"",cCampoDefault.replace(/\|/g,","));
				   //--------------------------------------------------------------------
				   // Recalcula totais													  
				   //--------------------------------------------------------------------
				   fCalcValHonTot("nVlrTotHor","nVlrApr",cTableR,"");
				   //return;
			   }
		   }
	   }
	 //--------------------------------------------------------------------
	 // Executa o metodo													  
	 //--------------------------------------------------------------------
	 if(cTp == 'I'){
		 nOpc = 3;
	 }else{
		 nOpc = 4;
	 }
	 
	 if ((cTp == "I") && (typeof oGuiaOff != 'undefined'))
			 oGuiaOff.procedimentos.push(JSON.parse(objSubJson));

	 setDisable("bSave" + cTableR,true);
	 
	 nRecno = document.getElementById(cTableR+"_RECNO").value;
	 Ajax.open("W_PPLSHORITE.APW?" + cQueryString + "&cSeqMov=" + cSeqMov + "&nOpc=" + nOpc + "&nRecno=" + nRecno , { 
					 callback: CarregaMontItensHon,
					   error: ExibeErroJson 
				  });
 } else {
	 //--------------------------------------------------------------------
	 // Deletar linhas														  
	 //--------------------------------------------------------------------
	 DelLinhaTab(cTable);
		//--------------------------------------------------------------------
	 // Recalcula totais													  
	 //--------------------------------------------------------------------
	   fCalcValHonTot("nVlrTotHor","nVlrApr",cTableR,"");
	   //Habilita botoes
	   setDisable('bIncTabExeSer',false);
 }

 setDisable("bSave" + cTableR,true);
 setDisable("bInc" + cTableR,false);
}
var aCalcValTotal = Array()
function fChangeValHonTotal(recno)
{
   var aCalTotalOri;

   if ((typeof aCalTotalOri != "undefined") && (document.getElementById("cTp").value == "5" || document.getElementById("cTp").value == "2")){ //Honorário Individual - SADT
	   
		aCalTotalOri = aCalcValTotal;

	   if(document.getElementById("cTp").value == "2")
	   {
		   aCalcValTotal = aCalcProcTotal;
	   }

	   var total = 0;
	   var lmudarec = false;
	   var totalMedDel = 0;

	   if (aCalcValTotal.length > 0){
		   for(var i = 0; i < aCalcValTotal.length; i++)
		   {
			   if(aCalcValTotal[i].indexOf(recno.toString()) > -1)
			   {
				   if(recno.toString() != aCalcValTotal[i][0])
					   lmudarec = true;

				   aCalcValTotal[i].splice(0,3);

				   if(lmudarec){
					   for(var y = 0; y < aCalcValTotal.length; y++)
					   {
						   if(aCalcValTotal[y][0] != undefined)
						   {
							   aCalcValTotal[y][0] = (parseInt(aCalcValTotal[y][0]) - 1);
							   aCalcValTotal[y][0] = aCalcValTotal[y][0].toString();
						   }
					   }
				   }
				   
				   lachou = true;
				   break;
			   }
		   }
	   }

	   if (aCalcValTotal.length > 0){
		   for(var n = 0; n < aCalcValTotal.length; n++){
			   if(aCalcValTotal[n][1] != undefined){
				 if(aCalcValTotal[n][2] == "18" || aCalcValTotal[n][2] == "20")
				 {
					 totalMedDel += aCalcValTotal[n][1];
				 }
				 total += aCalcValTotal[n][1];
			   }
		   }
	   }
	   else if(aCalcValTotal[0] != undefined)
	   {
		   if(aCalcValTotal[0][2] == "18" || aCalcValTotal[0][2] == "20")
		   {
				 totalMedDel += aCalcValTotal[0][1];
		   }
		   total += aCalcValTotal[0][1];
	   }
	   else
	   {
		   total = 0;
		   totalMedDel = 0;
	   }	


	   if(document.getElementById("cTp").value == "2")
	   {
		  document.getElementById("nTotPro").value = MaskMoeda(total);
		  document.getElementById("nTotGas").value = MaskMoeda(totalMedDel);
		  document.getElementById("nTotGerGui").value = MaskMoeda(total);
	   }
	   else{
		   document.getElementById("nVlrTotHor").value = MaskMoeda(total);
	   }

	   //Retornar o array original
	   aCalcValTotal = aCalTotalOri;
   }
   fMontMatGerHon('A', 'TabExeSer'); //Para carregar o cCampoDefault do grid de procedimentos, pois fica vazio, devido ao último grid ser executantes
}

//--------------------------------------------------------------------
// Pega o retorno do processamento										  
//--------------------------------------------------------------------
function CarregaMontExecHon(v) {                       
 var aResult = v.split("|");
 var cStatus = aResult[0];
 var cTexto 	= aResult[1];
 var cSeq		= ""
 var nOpc		= ""
 var nRecno	= ""
 
 if(aResult.length >= 3){
	 cSeq = aResult[2];
 }
 if(aResult.length >= 4){
	 nOpc = aResult[3];
 }
 if(aResult.length >= 5){
	 nRecno = aResult[4];
 }
 
 //--------------------------------------------------------------------
 // Mostra o resultado modal so mostra se for negado					  
 //--------------------------------------------------------------------
 if ( cStatus == "0" ){
   ShowModal("Critica(s)", cTexto);
 }
 //--------------------------------------------------------------------
 // Se vai incluir ou alterar a linha campo alimentado pela aMatRet 	  
 //--------------------------------------------------------------------
 fGetDadGen(nRecno, cTableR ,nOpc,true,cStatus,"",cCampoDefault.replace(/\|/g,","));
   
}

//--------------------------------------------------------------------
// Pega o retorno do processamento										  
//--------------------------------------------------------------------
function CarregaMontItensHon(v) {                       
 var aResult = v.split("|");
 var cStatus = aResult[0];
 var cTexto 	= aResult[1];
 var cSeq		= ""
 var nOpc		= ""
 var nRecno	= ""
 
   //Habilita botoes
   setDisable('bIncTabExeSer',false);
   
 if(aResult.length >= 3){
	 cSeq = aResult[2];
 }
 if(aResult.length >= 4){
	 nOpc = aResult[3];
 }
 if(aResult.length >= 5){
	 nRecno = aResult[4];
 }
 
 //--------------------------------------------------------------------
 // Mostra o resultado modal so mostra se for negado					  
 //--------------------------------------------------------------------
 if ( cStatus == "0" ){
   ShowModal("Critica(s)", cTexto);
 }else{
	 fCalcValHonTot("nVlrTotHor","nVlrApr",cTableR, "");
 }
 
 //--------------------------------------------------------------------
 // Se vai incluir ou alterar a linha campo alimentado pela aMatRet 	  
 //--------------------------------------------------------------------
 fGetDadGen(nRecno, cTableR ,nOpc,true,cStatus,"",cCampoDefault.replace(/\|/g,","));
   
}
//--------------------------------------------------------------------
// Processa 															  
//--------------------------------------------------------------------
function fProcFormHon(formulario) {
   var lDigOff = false;

   //--------------------------------------------------------------------
   // Valida formulario													  
   //--------------------------------------------------------------------
	  if (!valida()) return;
   
		//--------------------------------------------------------------------
		// Monta conteudo das tabelas	solicitacao e execucao					  
		//--------------------------------------------------------------------
		aMatAux = "TabExeSer";
		//--------------------------------------------------------------------
		// Carrega as linhas das tabelas para processamento					  
		//--------------------------------------------------------------------
		aMat = aMatAux.split("|");
		 
		cStringEnvTab = "";
	   for (var i = 0; i < aMat.length; i++) {
	 
		   var oTable = null
		   var nLen = 0 
		   var lReturn = true
		   if(typeof eval("o"+aMat[i]) != "string" && eval("o"+aMat[i]).aCols.length > 0){
			   oTable = eval("o"+aMat[i]).getObjCols()
			   nLen = oTable.rows.length;
		   }else{
			   alert("Informe pelo menos um serviço");
			   return;
		   }
		   fMontMatGerHon('A', aMat[i]);
		   aMatCampAux = aMatCap.split("|");
		   //--------------------------------------------------------------------
		   // Valida se foi digitada alguma participação 							 
		   //--------------------------------------------------------------------
		   if ( typeof oTabExe != "string" && oTabExe != null && oTabExe.aCols.length > 0 ) {
			   var oTableExe = oTabExe.getObjCols();
			   var nQtdLinTab  = oTableExe.rows.length;
		   }else{
			   alert("Informe a participação dos procedimentos");
			   return;
		   }

		   for (var y = 0; y < nLen; y++) {
			   nf = 0;
			   lReturn = true
			   nSeq = getTC(oTable.rows[y].cells[0]);
			   
			   //--------------------------------------------------------------------
			   // Valida se foi digitada participação para o procedimento				 
			   //--------------------------------------------------------------------
			   
			   for (var z = 0; z < nQtdLinTab; z++) {
				   
				   if (nSeq == parseInt(getTC(oTableExe.rows[z].cells[3])) ){
					   lReturn = false
				   }
			   
			   }
			   
			   if (lReturn){
				   alert("Informe a participação do procedimento: " + nSeq);
				   return;
			   }
			   
			   cStringEnvTab += "cSeq@"+getTC(oTable.rows[y].cells[0])+"$";
			   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {
					cCampo = aMatCampAux[x - 2].split("$")[1];
				   if (cCampo != "NIL") {
					   celula = oTable.rows[y].cells[x + 1 - nf];

					   if (typeof celula.value == 'undefined' || celula.value == '')
								conteudo = getTC(celula);
					   else conteudo = celula.value;

					   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
				   }
					   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;

			   }
			   cStringEnvTab += "|";
		   }
	   cStringEnvTab += "|";
   }
	   document.getElementById("cMatTabES").value = cStringEnvTab + "|";
		   
		   
	   aMatAux2 = "TabExe$oTabExe";

   //Monta variável do grid de executantes

   if ($("#cTipoOrigem").val() != undefined && ($("#cTipoOrigem").val() != "" ) || cTipoGui == "6" )  //r7
   {
		//--------------------------------------------------------------------
	   // Valida formulario
	   //--------------------------------------------------------------------
	   lDigOff = true;
	   document.forms[0].bconfirma.disabled = true;
	   modalBS('<i class="fa fa-exclamation-triangle" style="font-weight: bold; color: #000; text-shadow: 0 1px 0 #fff; filter: alpha(opacity=20); opacity: .2;"></i>&nbsp;&nbsp;&nbsp;Alerta', '<p>Tem certeza que deseja finalizar a guia?</p>', "@Sim, conclui a digitação!~confirmaHon('1')@Não, desejo continuar posteriormente!~confirmaHon('2');", "white~ #f8c80a", "large");
	   
   } else {	
	   document.forms[0].action = "W_PPLPROCGUI.APW";
   }

   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   if(aMatAux2 != ""){
	   aMat   		  = aMatAux2.split("|");
	   cStringEnvTab = "";
	   
	   for (var i = 0; i < aMat.length; i++) {

		   aInfoAux = aMat[i].split("$")
		   if ( typeof eval(aInfoAux[1]) != "string" && eval(aInfoAux[1]).aCols.length > 0 ){
			   //Pega o nome do grid
			   oTable = eval(aInfoAux[1]).getObjCols();
			   //Associa a coluna com a variável do post
			   fMontMatGerHon('A', aInfoAux[0]);
			   aMatCampAux = aMatCap.split("|");    
			   
			   for (var y = 0; y < oTable.rows.length; y++) {
				   nf 	 = 0;
	   
				   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {
					   
					   cCampo = aMatCampAux[x - 2].split("$")[1];
					   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
						   celula = oTable.rows[y].cells[x + 1 - nf];
						   
						   if (typeof celula.value == 'undefined' || celula.value == '')
							   conteudo = getTC(celula);
						   else  conteudo = celula.value;	
						   
						   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
					   }
					   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;

				   }
				   cStringEnvTab += "|";
			   }
		   }			
	   }
   }
	   document.getElementById("cMatTabExe").value = cStringEnvTab + "|";
	   
	   //--------------------------------------------------------------------
	   // trata campos														  
	   //--------------------------------------------------------------------
	   setDisable("cNomExe",false);
	   setDisable("BChaInt",true);
	   setDisable("bconfirma",true);

	   if( isDitacaoOffline() ){
		   setDisable("bimprimir",true);
	   }else{
		   setDisable("bimprimir",false);
	   }

	   setDisable("bAnexoDoc",false);
	   //--------------------------------------------------------------------
	   // Metodo de envio de formulario pelo ajax								  
	   //--------------------------------------------------------------------
	   if(!lDigOff){
		   Ajax.send(formulario, { 
			   callback: CarregaProcFormHon,
			   error: ExibeErro 
		   });
	   }
	   document.forms[0].action = "";

	   if( isDitacaoOffline() && isAlteraGuiaAut() ){
		   document.getElementById("bconfirma").disabled = true;
	   }

		//--------------------------------------------------------------------
		// Desabilita os campos												  
		//--------------------------------------------------------------------
		FDisElemen('TPdh|TProce|Tdb|Tcr|TcrS|TcrE|BProc|TabExeSer', true);
		//--------------------------------------------------------------------
		// Marca todas as linhas para delecao e retira da matriz de sessao		  
		//--------------------------------------------------------------------
		aTabDel = new Array("TabExeSer")
		for (var y = 0; y < aTabDel.length; y++) {
		   document.getElementById(aTabDel[y]).ondblclick = function(){};
		}
  
	   if( isDitacaoOffline() && isAlteraGuiaAut() ){
		   document.getElementById("bconfirma").disabled = true;
	   }
	   cPasgridCe = '99';
}
//--------------------------------------------------------------------
// Pega o retorno do processamento										  
//--------------------------------------------------------------------
function CarregaProcFormHon(v) {
 var aResult = v.split("|");
 var cTexto  = aResult[10]; //Procedimento autorizados ou negados resultado
 var cTitulo = aResult[11]; //Titulo do resultado autorizado,negado ou autorizado parcial
 //--------------------------------------------------------------------
 // Informacoes	da autorizacao											  
 //--------------------------------------------------------------------
 if (aResult[0] != ""){
	if(document.getElementById("cNumeHoId") != undefined)
	   document.getElementById("cNumeHoId").value = aResult[0].substr(0,4)+"."+aResult[0].substr(4,4)+"."+aResult[0].substr(8,2)+"-"+aResult[0].substr(10,8);//Numero da autorizacao
	else
	   window.frames[0].document.getElementById("cNumeHoId").value = aResult[0].substr(0,4)+"."+aResult[0].substr(4,4)+"."+aResult[0].substr(8,2)+"-"+aResult[0].substr(10,8);//Numero da autorizacao
   }
 //--------------------------------------------------------------------
 // Para mostrar o numero da autorizacao								  
 //--------------------------------------------------------------------
	   
if(document.getElementById("cNumeHoId") != undefined){
 if (cTexto == "") {
	 cTexto = "<center>" + document.getElementById("cNumeHoId").value + "</center>";
 } else {
	 cTexto = "<center>" + document.getElementById("cNumeHoId").value + "</center><br>" + cTexto;
 }
  
}else{
	 if (cTexto == "") {
		 cTexto = "<center>" + window.frames[0].document.getElementById("cNumeHoId").value + "</center>";
	 } else {
		 cTexto = "<center>" + window.frames[0].document.getElementById("cNumeHoId").value + "</center><br>" + cTexto;
	 }
		   
 }
 //--------------------------------------------------------------------
 // Mostra o resultado modal											  
 //--------------------------------------------------------------------
 ShowModal(cTitulo, cTexto, false, false, false);
}

//--------------------------------------------------------------------
// Checa se o procedimento e valido									  
//--------------------------------------------------------------------
function fChkCodProHon(cCmpPad, cCmpPro, cCmpDesc, cTpProc) {
 cCampoRef 	 = cCmpPro;
 cCampoRefDes = cCmpDesc;
   //--------------------------------------------------------------------
   // Limpa descricao do procedimento										  
   //--------------------------------------------------------------------
 document.getElementById(cCmpDesc).value = "";
   //--------------------------------------------------------------------
   // CodPad e CodPro														  
   //--------------------------------------------------------------------
 cCodPad = document.getElementById(cCmpPad).value;
 cCodPro = document.getElementById(cCmpPro).value;

 if (cCodPad == "") {
	 alert("Informe o código da tabela");
	 document.getElementById(cCmpPad).focus();
	 return false;
 }

 if (cCodPro == "") return true;

 Ajax.open("W_PPLSCHKSER.APW?cCodPadPro=" + ( cCodPad + cCodPro ) + "&cTpProc=" + cTpProc, { 
	 callback: CarregaDeskProHon, 
	 error: ExibeErro 
 });
}
//--------------------------------------------------------------------
// Limpa variavel BackSpace ou Delete - chamado no keydown
//--------------------------------------------------------------------
function fProfSauClearHon(cTpProf) {
 //--------------------------------------------------------------------
 // BackSpace e Delete etc nao sao capturadas pelo keypress
 // por isso o tratamento desta forma. quando for backspace tem que retornar
 // false para nao retornar a pagina anterior.
 //--------------------------------------------------------------------
 if (lVld2)  {
	   fProfSauFilHon(cTpProf);
	   return (LastkeyID == 8) ? false : true;
   }
}

//--------------------------------------------------------------------
// Carrega campos conforme processamento Profissional de saude			  
//--------------------------------------------------------------------
function CarregaProSaudeFilHon(v) {
 var aResult = v.split("|"); 
 var i = 0;
 var j = 0;
 var lEntrou = false;                  
   //--------------------------------------------------------------------
 // Verfiica se e solicitacao ou execucao
 //--------------------------------------------------------------------
   var e = document.getElementById("cNomExe");
	 if (LastkeyID == 46){
	   e.options[0] = new Option('-- Selecione um Executante --', '');
	   j = 1;
   } 
   for (i; i < aResult.length; i++) {
	   var aProf = aResult[i].split("$");
	   if (aProf.length>1 && aProf[1] != '')
		   e.options[i+j] = new Option(aProf[1], aProf[0]);
		   if (aProf[0]!=''){
			   lEntrou = true;
		   }
   } 	
   if (!lEntrou){
	   e.options[0] = new Option('-- ['+cString+'] nao localizado --', '');
   }		              
   fProfSauHon(e.value);
}                                        
//--------------------------------------------------------------------
// Carrega campos conforme processamento dos executantes				   
//--------------------------------------------------------------------
function CarregaProSaudeHon(v) {
 var aResult = v.split("|");                            
   //--------------------------------------------------------------------
   // alimenta variaveis													   
   //--------------------------------------------------------------------
 document.getElementById("cCodSigExe").value 	= aResult[0];
 document.getElementById("cNumCrExe").value 	= aResult[1];
 document.getElementById("cEstSigExe").value 	= aResult[2];
 document.getElementById("cCpfExe").value 	= aResult[4];

}                       

//--------------------------------------------------------------------
// Busca lookup (filtrado) - chamado no keypress
//--------------------------------------------------------------------
function fProfSauFilHon(e) {
 var cRda 	= document.getElementById("cRda").value;
   var cCodLoc = document.getElementById("cCodLoc").value;
   //--------------------------------------------------------------------
 // Executa o metodo													  
 //--------------------------------------------------------------------
 Ajax.open("W_PPLSMONALL.APW?cBusca=" + cString , { 
	 callback: CarregaProSaudeFilHon, 
	 error: ExibeErro
 });
 //--------------------------------------------------------------------
 // Se nao for digitado nada no tempo abaixo limpa a string 30 segundos
 //--------------------------------------------------------------------
 clearTimeout(cTimeOut);
 cTimeOut = setTimeout("fProfSauRestart()", 30000);
}
//--------------------------------------------------------------------
// Mostra a descricao do procedimento									  
//--------------------------------------------------------------------
function CarregaDeskProHon(v) {
 var aResult = v.split("|");
   aResDen 	= aResult[2].split("~"); 

 if (typeof cCampoRefDes != 'undefined') 
	 document.getElementById(cCampoRefDes).value = aResult[0];

 document.getElementById(cCampoRefDes).value = document.getElementById(cCampoRefDes).value.replace(/\|/g,",");                         

}


function HOINLoad(){
   cVazio = "";
   cVirgula = ",";
   
   //--------------------------------------------------------------------
   // Carrega eventos dos campos
   //--------------------------------------------------------------------
   var oForm = new xform( document.forms[0] );
   oForm.add( document.forms[0].cCodPadSExe	,"numero", false, true );
   oForm.add( document.forms[0].cCodProSExe		,"numero", false, true );
   oForm.add( document.forms[0].cQtdSExe			,"numero", false, true );
   setDisable('BcNumeHoId', true);

   cPasgridCe = document.getElementById("cTp").value;
   //--------------------------------------------------------------------
   // Carrega dados da rda												   
   //--------------------------------------------------------------------
   if( isDitacaoOffline() && isAlteraGuiaAut() ){
	   var cRecno = $("#cRecnoBD5").val();
	   setDisable('bSaveTabExeSer',true);     
	   setDisable('BcGuiaInter',true);		
	   setDisable('BcNumeHoId', true);
	   //Desabilita o campo Num. Guia Prestador (002) e o botão de busca da guia
	   setDisable('cNumAut',true);
	   setDisable(cBtnExec,true);
	   //Desabilita os campos cProSolDesc e cProExeDesc, deixando habilitado apenas o botão de busca F3
	   setDisable('cProSolDesc',true);
	   setDisable('cProExeDesc',true);
	   setDisable("bIncTabExe",false);
	   setDisable("bSaveTabExe",true);
	   Ajax.open("W_PPLCHAALT.APW?cRecno="+ cRecno + "&cTipGui=6" , { callback : fRespostaHon, error : exibeErro });
	   
   }else{

	   fExe();
	   setDisable("bimprimir",true);
	   alterarCamposGuias();
	   var aAliasB = ['6', '7'];
	   setDisable("bSaveTabExeSer",true);
	   //Ocultar os campo CSEQBD7 e CSEQBD6
	   for (var nK = 0 ; nK < aAliasB.length; nK++) {
		   if (typeof document.getElementById('cSeqBD' + aAliasB[nK]) != 'undefined' && document.getElementById('cSeqBD' + aAliasB[nK]) != null) {
			   document.getElementById('cSeqBD' + aAliasB[nK]).style.display = 'none';
			   var nQtdLabel  = document.getElementsByTagName("label").length;
			   for (var nI = 0; nI < nQtdLabel; nI++) {
				   if ( (document.getElementsByTagName("label")[nI].innerHTML.trim().toUpperCase().match(new RegExp('CSEQBD' + aAliasB[nK]))) != null ) { 
					   document.getElementsByTagName("label")[nI].style.display = 'none';
				   }
			   }
		   }
	   }			
  }
}

function fVldExecHon(nRecno, cTable, nOpc){
   var objSubJson = "";
   //--------------------------------------------------------------------
   // Define parametros para uso na funcao de resultado					  
   //--------------------------------------------------------------------
   fMontMatGerHon('I', cTable);
   
   var aMatCol 	= aHeadProc.split("|");
   var cTipGui = document.getElementById("cTp").value;
   var nLocgrid = -1;
   
   cTableR	= cTable;
   
   if(Trim(document.getElementById("nSeqRef").value)  == ""){
	   alert("Informe a sequência do procedimento.");
	   return;
   }
   
   var cGrPar = "";
   if(typeof document.getElementById("cGrPar") != "undefined" && document.getElementById("cGrPar") != null){
	   cGrPar = document.getElementById("cGrPar").value;
	   if(Trim(document.getElementById("cGrPar").value) == ""){
		   alert("Informe o Grau de Participação do procedimento.");
		   return;
	   }
   }else{
	   cGrPar = document.getElementById("cGraPartExe").value;	
	   if(Trim(document.getElementById("cGraPartExe").value) == ""){
		   alert("Informe o Grau de Participação do procedimento.");
		   return;
	   }		
   }
   
   if(Trim(document.getElementById("cCbosExe").value)  == ""){
	   alert("Informe o Código CBO.");
	   return;	
   }

   if (Trim(document.getElementById("cProExeDesc").value) == "") {
	   alert("Informe o Executante.");
	   return;
   }
   
   //função para validar quantidade de auxiliares
   var lRet = fValidaAuxLanc("TabExe", document.getElementById("nSeqRef").value, cGrPar, nRecno)
   
   if (!lRet) {
   
	   var lReturn = true;
	   var nSeq = parseInt(document.getElementById("nSeqRef").value);
	   //--------------------------------------------------------------------
	   // Verifica se a sequencia existe 										  
	   //--------------------------------------------------------------------
	   if ( typeof oTabExeSer != "string" && oTabExeSer.aCols.length > 0 ){
		   //Recupera os dados do grid
		   var oTable = oTabExeSer.getObjCols();
		   var nQtdLinTab = oTable.rows.length;
		   
		   if (cTipGui != '6') {
			   if ( isNaN(nSeq) || nSeq > nQtdLinTab || nSeq == 0){
				   lReturn = true;
			   }else lReturn = false;
		   } else {
			   for (var i = 0; i < oTable.rows.length; i++) {
				   lReturn = oTable.rows[i].cells[0].innerHTML.trim() == nSeq.toString().trim() ? false : true //getValueByKey("nSeqRef", strZero1(nRecno, 3), oTabExeSer.aCols) l= -1;
				   nLocgrid = (!lReturn) ? i+1 : -1;	
				   if 	(!lReturn)
					   break;
			   }
		   }
	   }else{
		   var nQtdLinTab = 0
	   }
	   if (lReturn){
		   alert('Sequência inválida');
		   return;
	   }
	   
	   if ( typeof oTabExe != "string" && oTabExe != null && oTabExe.aCols.length > 0) {
		   var oTableExe = oTabExe.getObjCols();
		   var nQtdLinTab  = oTableExe.rows.length;
	   }else{
		   var nQtdLinTab = 0
	   }
	   
	   //--------------------------------------------------------------------
	   // Verifica duplicidade												  
	   //--------------------------------------------------------------------
	   for (var i = 0; i < nQtdLinTab; i++) {
		   
		   //--------------------------------------------------------------------
		   // Verfica se existe um registro igual na tabela						  
		   //--------------------------------------------------------------------
		   var lResult = false;   
		   if (i+1 != parseInt(nRecno) 
			   && getTC(oTableExe.rows[i].cells[3]) == document.getElementById("nSeqRef").value
			   && getTC(oTableExe.rows[i].cells[4]) == document.getElementById("cGraPartExe").value) {
				   
			   alert('O procedimento já possui esse grau de participação.');
			   return;
		   }
		   
	   }
	   
	   //--------------------------------------------------------------------
	   // Monta envio das variaveis de sessao GET								  
	   //--------------------------------------------------------------------
	   cQueryString =	"&cRda="+document.getElementById('cRda').value+	
						   "&cNomeRdaExe="+document.getElementById('cNomeRdaExe').value+	
						   "&cGuiaInter="+document.getElementById('cGuiaInter').value+	
						   "&cGrPar="+cGrPar+	
						   "&cNomExe=" + document.getElementById('cProExeDesc').value +
						   "&cCodSigExe="+document.getElementById('cCodSigExe').value+	
						   "&cNumCrExe="+document.getElementById('cNumCrExe').value+	
						   "&cChvBD6="+document.getElementById('cChvBD6').value+	
						   "&cEstSigExe="+document.getElementById('cEstSigExe').value+
						   "&cTissVer="+document.getElementById('cTissVer').value;
						   
		   if(typeof oGuiaOff != 'undefined'){
				   var aCmps = aMatCap.split("|");
				   for(var i=0;i<aCmps.length;i++){
					   cIdCampo = aCmps[i].split("$")[0];
					   cCampo = document.getElementById(cIdCampo);
					   if(nOpc == '3'){
						   if(cIdCampo == "nSeqRef"){
							   objSubJson += '"' + cIdCampo + '"' + ':{ "defaultValue" : ' + '"' + strZero1(cCampo.value.trim(),3) + '"' + ', "actualValue": ' + '"' + strZero1(cCampo.value.trim(),3)  + '"},';
							   
						   }else{
   
							   if(cIdCampo == "cProExe" && document.forms[0].cTp.value != "5" && document.forms[0].cTp.value != "6"){ //usamos esse metodo pras guias de honorario e de resumos de internação e na de honorario tem o combo ultrapassado dos profissionais 
								   cIdCampo = "cNomExe";
								   cCampo = document.getElementById(cIdCampo);
							   }
							   
							   if(cIdCampo == "cGraPartExe" && document.forms[0].cTp.value == "6"){ //usamos esse metodo pras guias de honorario e de resumos de internação e na de honorario tem o combo ultrapassado dos profissionais 
								   cIdCampo = "cGrPar";
								   cCampo = document.getElementById(cIdCampo);
   
								   if(cCampo == null){
									   cIdCampo = "cGraPartExe";
									   cCampo = document.getElementById(cIdCampo);									
								   }
   
							   }
							   
							   if(cIdCampo == "cProExe" && document.forms[0].cTp.value == "6"){ //usamos esse metodo pras guias de honorario e de resumos de internação e na de honorario tem o combo ultrapassado dos profissionais 
								   cIdCampo = "cProExeDesc";
								   cCampo = document.getElementById(cIdCampo);
							   }
							   
							   if(cIdCampo.toUpperCase() == "CSEQBD7G" && document.forms[0].cTp.value == "6"){ //usamos esse metodo pras guias de honorario e de resumos de internação e na de honorario tem o combo ultrapassado dos profissionais 
								   cIdCampo = "cSeqBD7";
								   cCampo = document.getElementById(cIdCampo);
							   }	
							   
							   if(cCampo != null){
							   objSubJson += '"' + cIdCampo + '"' + ':{ "defaultValue" : ' + '"' + cCampo.value.trim() + '"' + ', "actualValue": ' + '"' + cCampo.value.trim() + '"}';
							   objSubJson += ",";
							   }
						   }					   
					   }else{
						   objSubJson = getObjects(oGuiaOff, "seqExe",nRecno);
						   if(objSubJson.length > 0){
							   objSubJson = objSubJson[0];
							   if (cIdCampo == "cProExe" && document.forms[0].cTp.value != "5"){ //usamos esse metodo pras guias de honorario e de resumos de internação e na de honorario tem o combo ultrapassado dos profissionais )
								   cIdCampo = "cNomExe";
								   cCampo = document.getElementById(cIdCampo);
								   if(objSubJson[cIdCampo] != undefined){ 								
										   objSubJson[cIdCampo].actualValue = cCampo.value.trim() + "*" + cCampo.options[cCampo.selectedIndex].innerHTML.trim();
								   }
							   } 
							   
							   else{
								   if(objSubJson[cIdCampo] != undefined){ 
									   if(cIdCampo == "nSeqRef"){
										   objSubJson[cIdCampo].actualValue = strZero1(cCampo.value.trim(),3) ;
									   }else{
										   objSubJson[cIdCampo].actualValue = cCampo.value.trim();
									   }
								   }
							   }
						   }
					   }
				   }
			   }
						   
	   cCamGer = "";
	   nSeq = (cTipGui == '6' && nLocgrid >= 0) ? nLocgrid : nSeq;
	   for (var i = 2; i < aMatCol.length; i++) {
			 var aMatColAux = aMatCol[i].split("$");
			 cCampo = getTC(oTable.rows[nSeq-1].cells[i]); //document.getElementById(aMatColAux[0]);
		   if (typeof cCampo != 'undefined' && cCampo != null && aMatNGet.indexOf(aMatColAux[1])==-1) {
				 cQueryString += "&" + aMatColAux[1] + "=" + cCampo;
		   } 
	   }
	   
	   //Se for guia de Resumo ou Honorário, informo a quantidade de auxiliares, caso exista.
	   if (cTipGui == '6' || cTipGui == '5') {
		   var NumAux = (document.getElementById("cNumMaxAux") != null) ? document.getElementById("cNumMaxAux").value : '0';
		   cQueryString += "&cNumMaxAux=" + NumAux;
	   }
	   
	   if(nOpc == '3' && (typeof oGuiaOff != 'undefined')){
		   objSubJson +=  '"seqExe":' + '"' + (typeof oTabExe != "string" ? (oTabExe.aCols.length+1).toString() : "1") + '",';
		   objSubJson +=  '"lNewIte":true,';
		   objSubJson +=  '"lDelIte":false}';
		   objSubJson = "{" + objSubJson;
		   oGuiaOff.executantes.push(JSON.parse(objSubJson));
	   }	  
		   
	   setDisable("bSave" + cTableR,true);
	   setDisable("bInc" + cTableR,false);
	   lAddExec = true;
	   //--------------------------------------------------------------------
	   // Executa o metodo													  
	   //--------------------------------------------------------------------
	   var cSeqMov = strZero1(document.getElementById('nSeqRef').value,3);
	   Ajax.open("W_PPLSHORITE.APW?" + cQueryString + "&cSeqMov=" + cSeqMov + "&cSeqPro=" + nSeq + "&nOpc=" + nOpc + "&nRecno=" + nRecno , { 
					   callback: CarregaMontExecHon,
					   error: ExibeErroJson
					  });	
   } else {
	   alert("Participação informada é inválida para o auxiliar ou quantidade máxima de auxiliares lançados para o mesmo procedimento já efetuada.");
   }
}

function fVldExecPar(nRecno, cTable, nOpc){
   
   fMontMatGerHon('I', cTable);

   var aMatCol 	= aHeadProc.split("|");
   var cStringEnvTab;
   var cTipGui = document.getElementById("cTp").value;
   var nLocgrid = -1;

   cTableR	= cTable;
   
   if(Trim(document.getElementById("nSeqRef").value)  == ""){
	   alert("Informe a sequência do procedimento.");
	   return;
   }
   
   var cGrPar = "";
   if(typeof document.getElementById("cGrPar") != "undefined" && document.getElementById("cGrPar") != null){
	   cGrPar = document.getElementById("cGrPar").value;
	   if(Trim(document.getElementById("cGrPar").value) == ""){
		   alert("Informe o Grau de Participação do procedimento.");
		   return;
	   }
   }else{
	   cGrPar = document.getElementById("cGraPartExe").value;
	   if(Trim(document.getElementById("cGraPartExe").value) == ""){
		   alert("Informe o Grau de Participação do procedimento.");
		   return;
	   }		
   }
   
   if(Trim(document.getElementById("cCbosExe").value)  == ""){
	   alert("Informe o Código CBO.");
	   return;
   }

   var lReturn = true
   var nSeq = parseInt(document.getElementById("nSeqRef").value)
   //--------------------------------------------------------------------
   // Verifica se a sequencia existe 										  
   //--------------------------------------------------------------------
   if ( typeof oTabExeSer != "string" && oTabExeSer.aCols.length > 0 ){
	   //Recupera os dados do grid
	   var oTable = oTabExeSer.getObjCols();
	   var nQtdLinTab = oTable.rows.length;
	   
	   if (cTipGui != '6') {
		   if ( isNaN(nSeq) || nSeq > nQtdLinTab || nSeq == 0){
			   lReturn = true
		   }else lReturn = false;
	   } else {
		   for (var i = 0; i < oTable.rows.length; i++) {
			   lReturn = oTable.rows[i].cells[0].innerHTML.trim() == nSeq.toString().trim() ? false : true //getValueByKey("nSeqRef", strZero1(nRecno, 3), oTabExeSer.aCols) l= -1;
			   nLocgrid = (!lReturn) ? i+1 : -1;	
			   if 	(!lReturn)
				   break;			
		   }
	   }
   }else{
	   var nQtdLinTab = 0
   }
   if (lReturn){
	   alert('Sequência inválida');
	   return;
   }
   
   
   if ( typeof oTabExe != "string" && oTabExe != null && oTabExe.aCols.length > 0) {
	   var oTableExe = oTabExe.getObjCols();
	   var nQtdLinTab  = oTableExe.rows.length;
   }else{
	   var nQtdLinTab = 0
   }
   
   cStringEnvTab = "";
   //--------------------------------------------------------------------
   // Verifica duplicidade												  
   //--------------------------------------------------------------------
   for (var i = 0; i < nQtdLinTab; i++) {
	   
	   //--------------------------------------------------------------------
	   // Verfica se existe um registro igual na tabela						  
	   //--------------------------------------------------------------------
	   var lResult = false;   
	   if (i+1 != parseInt(nRecno) ){

		   if (parseInt(getTC(oTableExe.rows[i].cells[3])) == parseInt(document.getElementById("nSeqRef").value)
			   && getTC(oTableExe.rows[i].cells[5]).trim() == document.getElementById("cCpfExe").value.trim()) {
			   alert('O procedimento já possui esse executante em outro grau de participação.');
			   return;
		   }else if (parseInt(getTC(oTableExe.rows[i].cells[3])) == parseInt(document.getElementById("nSeqRef").value)
			   && getTC(oTableExe.rows[i].cells[4]) == document.getElementById("cGraPartExe").value) {
			   
			   alert('O procedimento já possui esse grau de participação.');
			   return;
		   }else{
			   if(parseInt(getTC(oTableExe.rows[i].cells[3])) == parseInt(document.getElementById("nSeqRef").value) ){
				   cStringEnvTab += "cGrPar@"+	getTC(oTableExe.rows[i].cells[4]) + "$cSeqPro@" + document.getElementById("nSeqRef").value+"$";
				   cStringEnvTab += "|";
			   }
		   }
	   }
	   
   }
   
   document.getElementById("cMatTabExe").value = cStringEnvTab + "|";

   //--------------------------------------------------------------------
   // Monta envio das variaveis de sessao GET								  
   //--------------------------------------------------------------------
   cQueryString =	"&cRda="+document.getElementById('cRda').value+	
				   "&cNomeRdaExe="+document.getElementById('cNomeRdaExe').value+	
				   "&cGuiaInter="+document.getElementById('cGuiaInter').value+	
				   "&cGrPar="+cGrPar+	
				   "&cNomExe=" + document.getElementById('cProExeDesc').value +
				   "&cCodSigExe="+document.getElementById('cCodSigExe').value+	
				   "&cNumCrExe="+document.getElementById('cNumCrExe').value+	
				   "&cChvBD6="+document.getElementById('cChvBD6').value+	
				   "&cEstSigExe="+document.getElementById('cEstSigExe').value+
				   "&cTissVer="+document.getElementById('cTissVer').value+
				   "&cMatTabExe="+document.getElementById("cMatTabExe").value;
					   
   cCamGer = "";
   for (var i = 2; i < aMatCol.length; i++) {
		 var aMatColAux = aMatCol[i].split("$");
		 nSeq = (cTipGui == '6' && nLocgrid >= 0) ? nLocgrid : nSeq;
	   cCampo = getTC(oTable.rows[nSeq-1].cells[i]); //document.getElementById(aMatColAux[0]);
	   if (typeof cCampo != 'undefined' && cCampo != null && aMatNGet.indexOf(aMatColAux[1])==-1) {
			 cQueryString += "&" + aMatColAux[1] + "=" + cCampo;
	   } 
   }	  
	   
   //setDisable("bSave" + cTableR,true);
   //setDisable("bInc" + cTableR,false);
   //lAddExec = true;
   //--------------------------------------------------------------------
   // Executa o metodo													  
   //--------------------------------------------------------------------
   var cSeqMov = strZero1(document.getElementById('nSeqRef').value,3);
   Ajax.open("W_PPLSHORPAR.APW?" + cQueryString + "&cSeqMov=" + cSeqMov + "&cSeqPro=" + nSeq + "&nOpc=" + nOpc + "&nRecno=" + nRecno + "&cTable=" + cTable , { 
				   callback: fDirHon,
				   error: ExibeErroJson
			 });	
}

function fDirHon(v){
   var aResult = v.split("|");

   var nOpc    = parseInt(aResult[1]);
   var nRecno  = parseInt(aResult[2]);;
   var cTable  = aResult[3];

   if(aResult[0] == 'N')
	   alert(aResult[1]);
   else
	   fVldExecHon(nRecno, cTable, nOpc);
}
//--------------------------------------------------------------------
// Monta os executantes												   
//--------------------------------------------------------------------
function fProfSauHon(cProSaud) {                
   var cMatric = document.getElementById("cNumeCart").value;
   var cRda = document.getElementById("cRda").value;
   Ajax.open("W_PPSDADPSAU.APW?cProSaud="+cProSaud+ "&cMatric="+cMatric + "&cRda="+cRda+"&lCarSession='false'", {callback: CarregaProSaudeHon, error: ExibeErro} );
}  



var cLastProcVld = "";
var cTpProfG = '';
var cTpPrestador = '';  
		
function xfProfSauClear(cTpProf) {
   if (lVld2)  {
	   xfProfSauFil(cTpProf);                         
	   return (LastkeyID == 8) ? false : true;
   }
}

function xfProfSauFil(cTpProf) {
   cTpProfG    = cTpProf;
   var cRda 	= document.getElementById("cRda").value;
   var cCodLoc = document.getElementById("cCodLoc").value;
   Ajax.open("W_PPLATUPRO.APW?cBusca=" + cString + "&cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
	   callback: xCarregaProSaudeFil, 
	   error: ExibeErro,
	   showProc: false  
   });
   clearTimeout(cTimeOut);
   cTimeOut = setTimeout("xfProfSauRestart()", 30000);
}

function xCarregaProSaudeFil(v) {
   var i = 0;
   var j = 0;
   var lEntrou = false;                    
   var e = "";
   var aResult = v.split("|"); 
   var cTexto = ""; 
   if (cTpProfG == "S") {
   
	   setTC(document.getElementById("cProSol"),"");
	   e = document.getElementById("cProSol");
	   cTexto = "Solicitante";
   } else {
   
	   if (document.getElementById("cProExe") != null){
		   setTC(document.getElementById("cProExe"),"");
		   e = document.getElementById("cProExe");      
		   cTexto = "Executante";
	   }else{
		   if (document.getElementById("cProSol") != null){
			   setTC(document.getElementById("cProSol"),"");
			   e = document.getElementById("cProSol");      
			   cTexto = "Executante";
		   }	
	   }
   }
   
   if (LastkeyID == 46){
	   e.options[0] = new Option('-- Selecione um '+cTexto+' --', '');
	   j = 1;
   } 
   for (i; i < aResult.length; i++) {
	   var aProf = aResult[i].split("%");
	   if (aProf.length>1 && aProf[1] != '')
		   e.options[i+j] = new Option(aProf[1], aProf[0]);
		   if (aProf[0]!=''){
			   lEntrou = true;
		   }
   } 	
   if (!lEntrou){
	   e.options[0] = new Option('-- ['+cString+'] nao localizado --', '');
   }		                 
   if (cProfAntG != e.value) {
	   cProfAntG = e.value;
	   fProfSau(e.value,cTpProfG);
   }
}
					   
function xfProfSauRestart() {
   clearTimeout(cTimeOut);
   cString = "";
   cProfAntG = '';
}
	
//----------------------------------------------------------------------------------------------------------------------------------------
// load da guia de Recurso de Glosa									   
//----------------------------------------------------------------------------------------------------------------------------------------
function RECGLOLoad() {

   Ajax.open("W_PPLB4DRGLO.APW?cRecnoB4D="+document.getElementById('cRecnoB4D').value + "&cOpc="+document.getElementById('cOpc').value , {
	   callback: fCarregaRecursoDeGlosa, 
	   error: ExibeErro
   } );
}
//----------------------------------------------------------------------------------------------------------------------------------------
// load dos campos da guia de Recurso de Glosa									   
//----------------------------------------------------------------------------------------------------------------------------------------
function fCarregaRecursoDeGlosa(v)
{
   var aResult = v.split("|");
   
   document.getElementById('cRegAns').value = aResult[0];
   document.getElementById('cNumAut').value = aResult[1];
   document.getElementById('cNomOpe').value = aResult[2];
   document.getElementById('cObjRec').value = aResult[3];
   document.getElementById('cGloOpe').value = aResult[4];
   document.getElementById('cCodOpe').value = aResult[5];
   document.getElementById('cNomCon').value = aResult[6];
   document.getElementById('cNumLot').value = aResult[7];
   document.getElementById('cNumPro').value = aResult[8];
   document.getElementById('cGloPrt').value = aResult[9];
   document.getElementById('cJusPro').value = aResult[10];
   document.getElementById('cAcaPro').value = aResult[11];
   document.getElementById('cGuiPre').value = aResult[12];
   document.getElementById('cAtrOpe').value = aResult[13];
   document.getElementById('cSenha').value = aResult[14];
   document.getElementById('cGloGui').value = aResult[15];
   document.getElementById('cJusGui').value = aResult[16];
   document.getElementById('cAcaGui').value = aResult[17];
   document.getElementById('cTotRec').value = aResult[19];
   document.getElementById('cTotAca').value = aResult[20];
   document.getElementById('cDatRec').value = aResult[21];
   document.getElementById('cTpRecGlo').value = aResult[22];
   
   fCarregaProcedimentosRecGlo(aResult[18].split("$"));
}

//----------------------------------------------------------------------------------------------------------------------------------------
// load dos procedimentos da guia de Recurso de Glosa  				   
//----------------------------------------------------------------------------------------------------------------------------------------
function fCarregaProcedimentosRecGlo(aProcs)
{
   var nI = 0;
   var nC = 0;
   var aProc;
   var aCampos = Array();
   var aLinhas = Array();
   var cTable = "TabItens" 
   var aHeader = new Array();
   var aCols = new Array();
   var aMatCampAux = "";
   cTableR 	 = cTable;
   
   fGetDadGen(0, "TabItens" ,6,true,"1","","",true,false);
   
   if (!wasDef( typeof(cGrids) ) ){
	   if(wasDef( typeof(document.getElementById("cGrids")))){
		   cGrids = document.getElementById("cGrids")
	   }	
   }
   
   var aGrids = cGrids.value.split("@");
   aCampos = aGrids[nI].split("~")[1].split('|')[0].split(',') ;
   
   aMatCampAux = "";
   for (nC = 0; nC < aProcs.length; nC++)
   {
	   aProc = aProcs[nC].split(";");
	   var aValores = new Array(aProc.length)
	   for(nI=0; nI < aProc.length; nI++)
	   {
		   aMatCampAux += aCampos[nI] +"$"+ aProc[nI] + ";"
	   }
	   aMatCampAux += "@"
   }
   
   fGetDadGen(aProc[aProc.length], cTableR ,3,true,"1",aMatCampAux,"",true,false);
		   
   // Desabilito os agrupamentos desnecessários de acordo com o tipo de recurso
   if (document.getElementById('cTpRecGlo').value == '1'){		
	   setDisable("cJusGui",true);		
	   setFieldOB('cJusPro');
   }
   else if (document.getElementById('cTpRecGlo').value == '2'){
	   setDisable('cJusPro',true);		
	   setFieldOB('cJusGui');
   } else {
	   setDisable('cJusPro',true);		
   }	
   setDisable('cObjRec',true);		
   setDisable('cAcaPro',true);	
   setDisable('cAcaGui',true);	
   setDisable('cTotRec',true);	
   setDisable('cTotAca',true);		
	   
   if (document.getElementById('cOpc').value == 'V'){
	   setDisable("bconfirma",true);	
	   setDisable("bimprimir",true);
	   setDisable("bAnexoDoc",true);
	   setDisable('cJusPro',true);	
	   setDisable("cJusGui",true);	
   }
   
   return;
}

//----------------------------------------------------------------------------------------------------------------------------------------
// altera um procedimento da guia de Recurso de Glosa  				   
//----------------------------------------------------------------------------------------------------------------------------------------
aCalcValue = Array();
function fMontItensRecGlo()
{
   var nI = 0;
   var aCampos = Array();
   var aMatCampAux = "";
   var cTable = "TabItens";
   var lachou = false;
   var total = 0;
   cTableR 	 = cTable;
   
   if (!wasDef( typeof(cGrids) ) ){
	   if(wasDef( typeof(document.getElementById("cGrids")))){
		   cGrids = document.getElementById("cGrids");
	   }	
   }
   
   var aGrids = cGrids.value.split("@");
   aCampos = aGrids[nI].split("~")[1].split('|')[0].split(',');
   
   for (nC = 0; nC < aCampos.length; nC++)
   {
	   if (aCampos[nC] != "")
		   aMatCampAux += aCampos[nC] +"$"+ document.getElementById(aCampos[nC]).value + ";"
   }
   
   fGetDadGen(TabItens_RECNO.value, cTableR ,4,true,"1",aMatCampAux,"",true,false);	
   setDisable('cVlrAca',true);	

   if (aCalcValue.length > 0){
	   for(var i = 0; i < aCalcValue.length; i++)
	   {
		   if(aCalcValue[i].indexOf(TabItens_RECNO.value) > -1)
		   {
			   aCalcValue[i][1] = parseFloat(cVlrRec.value.replace(/\D/g, "")); //Atualiza o Valor do Procedimento.
			   lachou = true;
			   break;
		   }
	   }

	   if(!lachou)
	   {
		   aCalcValue.push([TabItens_RECNO.value,  parseFloat(cVlrRec.value.replace(/\D/g, ""))]); //Popula o Array 
	   }
   }
   else
   {
	   aCalcValue.push([TabItens_RECNO.value,  parseFloat(cVlrRec.value.replace(/\D/g, ""))]); //Popula o Array 
   }

   if (aCalcValue.length > 0){
	   for(var n = 0; n < aCalcValue.length; n++){
		   total += aCalcValue[n][1];
	   }
   }
   else
   {
	   total += aCalcValue[0][1];
   }

   cTotRec.value = MaskMoeda(total);
}

//----------------------------------------------------------------------------------------------------------------------------------------
// Post dos dados da Guia de Recurso de Glosa										   
//----------------------------------------------------------------------------------------------------------------------------------------
function fProcFormRecGlo(formulario)	{
   var lVld 	= false;
   var cVlrLin = "";
   var cJusLin	= "";
   var cJusCtr = "";

   document.forms[0].action = "W_PPLPROCRGL.APW";
   
   //cTpRecGlo
   //1 = Protocolo
   //2 = Guia
   //3 = Alguns Procedimentos da Guia
   var cTpRecGlo = document.getElementById("cTpRecGlo").value;
   var cJustif = "";
   
   if (cTpRecGlo == "1")
   {
	   cJustif = document.getElementById("cJusPro").value;
	   if ( isEmpty(cJustif) ) {
		   alert('Informe o motivo do recurso!');		
		   return
	   }
   }
   else if (cTpRecGlo == "2")
   {
	   cJustif = document.getElementById("cJusGui").value;
	   if ( isEmpty(cJustif) ) {
		   alert('Informe o motivo do recurso!');		
		   return
	   }
   }
   else if (cTpRecGlo == "3")
   {
	   //--------------------------------------------------------------------
	   // Carrega os campos da grid                       					   
	   //--------------------------------------------------------------------
	   if (!wasDef( typeof(cGrids) ) ){
		   if(wasDef( typeof(document.getElementById("cGrids")))){
			   cGrids = document.getElementById("cGrids");
		   }
	   }
	   var aGrids = cGrids.value.split("@");
	   var aCampos = aGrids[0].split("~")[1].split('|')[0].split(',');
	   
	   //Pega o nome do grid
	   var oTable = oTabItens.getObjCols();
	   
	   for (var y = 0; y < oTable.rows.length; y++) {			
		   
		   for (var x = 2; x < (oTable.rows[y].cells.length); x++) {
			   //nome do campo da coluna				
			   cCampo = aCampos[x - 2];
			   if (cCampo != "NIL" && cCampo == "cJusPre") {
				   celula = oTable.rows[y].cells[x];
				   
				   if (typeof celula.value == 'undefined' || celula.value == '')
					   conteudo = getTC(celula);
				   else  conteudo = celula.value;
				   
				   cJusLin = conteudo;
				   cJusCtr += conteudo;
			   }

			   if (cCampo != "NIL" && cCampo == "cVlrRec") {
				   celula = oTable.rows[y].cells[x];
				   
				   if (typeof celula.value == 'undefined' || celula.value == '')
					   conteudo = getTC(celula);
				   else  conteudo = celula.value;
				   
				   cVlrLin = conteudo;
			   }
			   
		   }
		   // a cada linha eu monto a matriz de recurso
		   cJustif += Trim((y+1).toString()) + ";" + cJusLin + ";" + cVlrLin + "|";			
	   }
	   if ( isEmpty(cJusCtr) ) {
		   alert('Informe os dados necessários para inclusão do recurso!');		
		   return
	   }
   }

   //salva as justificativas no hidden
   document.getElementById('cMatJustif').value = cJustif

   //--------------------------------------------------------------------
   // Metodo de envio de formulario pelo ajax								  
   //--------------------------------------------------------------------
   Ajax.send(formulario, {
		   callback: function(v) {recGloAlertfim(v)},
		   error: ExibeErro
   });
}

function recGloAlertfim(v){
   setDisable("bconfirma",true);	
   document.forms[0].action = "";
   alert(v);
}

//Verifica se o numero da guia informado e valido
function VldNumGPri(cChvGui,cTipGui, cNumCart) { 
   if (cChvGui.value == "") return true;
   Ajax.open("W_PVLDNGUI.APW?NumAut=" + cChvGui.value  + "&TipGui=02" +"&cNumCart=" + cNumCart, { callback: VldCmpGPr,error: exibeErro });
}

function VldCmpGPr(v) {

   if ( isEmpty(v) ) {
	   return true;
   } else {
	   
	   ShowModal("Atenção",v,true,false,true); 
	   document.getElementById('cNumInt').value = "";
	   return false;
   }
} 
//--------------------------------------------------------------------
// Acho as configuracoes do Grid										  
//--------------------------------------------------------------------
function fGetCmpGrid(cGrid){
   var aGrCp 	=  document.getElementById('cGrids').value.split('@'); // pego a variavel que guardo os grids e suas caracteristicas	
   var aCfgGrd = ""
   for (var x = 0; x < aGrCp.length; x++) {
	   if (aGrCp[x].indexOf(cGrid) != -1){
		   var aCfgGrd = aGrCp[x].split('~'); // acho o grid q estou trabalhando	
	   }
   }
   return aCfgGrd;
}
//--------------------------------------------------------------------
// Acho os relacionamentos												  
//--------------------------------------------------------------------
function fGetRelGrid(cGrid){
   var cCfgRel = ""
   if (isObject( getObjectID('cDadRelac') )){
	   var aGrCp = document.getElementById('cDadRelac').value.split(';'); 
	   
	   for (var x = 0; x < aGrCp.length; x++) {
		   if (aGrCp[x].indexOf(cGrid) != -1){
			   var cCfgRel = aGrCp[x]; // acho o grid q estou trabalhando	
		   }
	   }
   }
   
   return cCfgRel;
}
//--------------------------------------------------------------------
// Monto Grid generico													  
//--------------------------------------------------------------------
function fMntIteGen(cTp, cTable,nRecno, lBtnAtu, lBtnDel, lLayGen) {    
   var cObjGrid 	= 	"o" + cTable; // objeto do Grid
   var aCfgGrd  	= fGetCmpGrid(cTable);
   var cCfgRel  	= fGetRelGrid(cTable);
   var aCampos		= aCfgGrd[2].split("|")[0].split(',');
   var aCamposOb   = aCfgGrd[3].split("|")[0].split(','); 
   var cCpoSeq     = aCfgGrd[4].split("|")[0];
   var nlenSeq     = cCpoSeq != '' ? trim(aCfgGrd[4].split("|")[1].split(",")[0]): 0;
   var cValores = '';
   var cStringEnvTab = '';
   var lCmpVazio = false;
   var lAchou    = false;
   var cTextoLin = ''
   var cTextoTb  = ''
   var nAchou = 0;
   var nOpc;
   var nRecnoAlt = nRecno;
   var cCmpValue = ''
   var cBtnAtu = 'true';
   var cBtnDel = 'true';
   cCampoDefault	 = '';

   if(cTp == 'A')
	   nOpc = '4';
   else
	   nOpc = '3';
   
   if (nRecno == -1)
	   nRecno = undefined; //n? deve ser passado o nRecno
	   
   if (!(lBtnAtu === undefined))
	   cBtnAtu = lBtnAtu ? "true" : "false";
   
   if (!(lBtnDel === undefined))
	   cBtnDel = lBtnDel ? "true" : "false";
	   
   if (!(lLayGen === undefined))
	   lSalvAcionado = lLayGen ? "true" : "false";	
   
   var nJ=0
   while (nJ < aCamposOb.length && !lCmpVazio){
	   if (aCamposOb[nJ] != ""){
		   //Verifica se e um combo ou um campo normal
		   if(document.getElementById(aCamposOb[nJ]).options == undefined){
				   if(document.getElementById(aCamposOb[nJ]).value.trim() == ""){
					   alert("Campo(s) obrigatórios não preenchidos!");
					   document.getElementById(aCamposOb[nJ]).focus();
					   lCmpVazio = true;
				   }
		   }else{
			   if(document.getElementById(aCamposOb[nJ]).value == "SELECTED" || document.getElementById(aCamposOb[nJ]).value == ""){
				   alert("Campos obrigatórios não preenchidos!");
				   document.getElementById(aCamposOb[nJ]).focus();
				   lCmpVazio = true;
			   }		
		   }
	   }
	   nJ++;
   }
   
   if (!lCmpVazio){
	   //Se o grid foi preenchido guardo e mando o que ja tem nele
	   if(typeof eval(cObjGrid) != "string" && eval(cObjGrid).aCols.length > 0){
		   //Recupera os dados do grid
		   var oTable = eval(cObjGrid).getObjCols();
				   
		   for (var y = 1; y < oTable.rows.length; y++) {
			   for (var x = 1; x < (oTable.rows[y].cells.length - 1); x++) {
			   
				   cCampo = aCampos[x - 1];
				   
				   celula = oTable.rows[y].cells[x + 1];
				   
				   if (typeof celula.value == 'undefined' || celula.value == '')
						conteudo = getTC(celula);
				   else conteudo = celula.value;	
					   
				   cStringEnvTab += cCampo + "@" + conteudo + "$";
			   }      
			   cStringEnvTab += "|";
		   }
		   
	   }
   
   if (cTp == 'I' || cTp == 'A') {
		   //Carrega os valores que estao nos campos para incluir na linha
		   if(cValores == "")
		   {
			   for (var nI=0; nI < aCampos.length;nI++)
			   {
				   if (aCampos[nI] != ""){
					   //Verifica se e um combo ou um campo normal
					   //Alterado tipo de verificação para atender o Internet Explorer
					   var e = document.getElementById(aCampos[nI]);
					   if(e.options == undefined){
						   cCmpValue = e.value;
						   if (aCampos[nI] == cCpoSeq && cTp == 'I'){ 
							   if(typeof eval(cObjGrid) != "string" && eval(cObjGrid).aCols.length > 0){ //verifico se ja existe item na table
								   //Recupera a grid
								   var oTable = eval(cObjGrid).getObjCols();
								   cValores += aCampos[nI]+"$" + strZero1(oTable.rows.length+1, nlenSeq) + "*CMPSEQ;";
							   }else{
								   cValores += aCampos[nI]+"$" + strZero1(1, nlenSeq) + "*CMPSEQ;"; //nao existe itens e esse ser?o primeiro
							   }		
						   }else{						
							   cValores += aCampos[nI]+"$"+cCmpValue.replace("@", "*@*") + ";";
							   cTextoLin += e.value;
						   }
					   }else{
						   //sendo um combo insere "Código - Descricao"
						   //Alterado tipo de verificação para atender o Internet Explorer
						   var cCod = e.options[e.selectedIndex].value;
						   var cTexto = e.options[e.selectedIndex].text;
						   if (cCod.match("CMPSEQ") !== null) //pode acontecer de o campo de relacionamento entre grids ser o sequencial, logo, devo desconsiderar a string CMPSEQ
								   cCod = cCod.split("*")[0];	
						   cValores += aCampos[nI]+ "$" + '<mark class="markInv">' + cCod + '*</mark>' + cTexto + ";";
						   cTextoLin += cCod + "*" + cTexto;
					   }
				   }
			   }
		   }
		   
		   if(typeof eval(cObjGrid) != "string" && eval(cObjGrid).aCols.length > 0){
			   //Recupera os dados do grid
			   var oTable = eval(cObjGrid).getObjCols();
			   cTextoLin = cTextoLin.replace(/\s+/g, '');
			   //verifica se a linha já existe na grid
			   var z = 0;
			   var w = 1;
			   while ((z < oTable.rows.length) && (!lAchou)) {
		   
				   for (var w = 1; w <= (oTable.rows[z].cells.length - 1); w++) {			
					   var oCell = oTable.rows[z].cells[w];
					   
					   if ($( oCell ).find( "img" ).length == 0){ //retirar as td com os icones de alterar e excluir 
						   if ( $( oCell ).text().match("CMPSEQ") === null) //se não é o campo sequencial 
							   cTextoTb += $( oCell ).text();
					   }
					   else{
						   if($( oCell ).find( "img" )[0].attributes.alt.nodeValue == "Excluir"){
							   //pegar o recno do botao de excluir que está na função onclick para comparar com o recno informado
							   var onclickFunc = $( oCell ).find( "img" )[0].attributes.onclick.nodeValue; 
							   nRecnoAlt = onclickFunc.substr(11,1);
						   }
					   }
				   }
				   cTextoTb = cTextoTb.replace(/\s+/g, '');
				   if((cTextoTb == cTextoLin && cTp == 'I') || ((cTextoTb == cTextoLin && cTp == 'A' && nRecno != nRecnoAlt))){
					   alert('Esse registro já existe!');
					   lAchou = true;
				   }
				   
				   cTextoTb = '';
				   z++;
			   }
		   }
		   
		   //se não achou nenhum registro igual
		   if (!lAchou){
			   //Chama a Funcao que monta a estrutura com os valores do grid
			   Ajax.open("W_PPLGETGRID.APW?cGrid=" + cTable + "&nOpc=" + nOpc + "&cCmp=" 
											   + ""  + "&cValores=" + cValores + "&nRecno=" + nRecno 
											   + "&cRelac=" + cCfgRel
											   + "&lBotao=true&cSt=1" 
											   + "&lBtnAtuVisible=" + cBtnAtu
											   + "&lBtnDelVisible=" + cBtnDel, {
												   callback: carregaGridDatGen, 
												   error: exibeErro} );
		   }
	   }
   }
}
//--------------------------------------------------------------------
// ChamaPop generico para F3 do layout generico 
//--------------------------------------------------------------------
function chamaPopGen(nPop){
   switch(nPop) {
   case 1:
	   return ChamaPoP("W_PPLSXF3.APW?cFunName=PLF3CADGEN&F3Nome=cB9Y_CRMEST&F3CmpDes=cB9Y_CRMEST&cAliasGen=SX5&cCamposGen=X5_CHAVE,X5_DESCRI&cCondGen=X5_TABELA='12'&cCodDesGen=X5_CHAVE,X5_DESCRI","jF3","yes");
	   break;
   case 2:
	   return ChamaPoP("W_PPLSXF3.APW?cFunName=PLF3CADGEN&F3Nome=cB9V_CODCID&F3CmpDes=cB9V_CODCID,cB9V_CIDADE&cAliasGen=BID&cCamposGen=BID_CODMUN,BID_DESCRI&cCodDesGen=BID_CODMUN,BID_DESCRI","jF3","yes");
	   break;
   case 3:
	   return ChamaPoP("W_PPLSXF3.APW?cFunName=PLF3CADGEN&F3Nome=cB9V_CODLOG&F3CmpDes=cB9V_CODLOG,cB9V_DESLOG&cAliasGen=B18&cCamposGen=B18_CODIGO,B18_DESCRI&cCodDesGen=B18_CODIGO,B18_DESCRI","jF3","yes");
	   break;
   case 4:
	   return ChamaPoP("W_PPLSXF3.APW?cFunName=PLF3CADGEN&F3Nome=cB9V_TIPEST&F3CmpDes=cB9V_TIPEST,cB9V_DESEST&cAliasGen=B1Z&cCamposGen=B1Z_CODEST,B1Z_DESEST&cCodDesGen=B1Z_CODEST,B1Z_DESEST","jF3","yes");
	   break;
   case 5:
	   return ChamaPoP("W_PPLSXF3.APW?cFunName=PLF3CADGEN&F3Nome=cB9Q_CODESP&F3CmpDes=cB9Q_CODESP,cB9Q_DESESP&cAliasGen=BAQ&cCamposGen=BAQ_CODESP,BAQ_DESCRI&cCodDesGen=BAQ_CODESP,BAQ_DESCRI","jF3","yes");
	   break;
   default:
	   alert('Consulta F3 invalida para o campo')
   }
}

function finalizaAltSenha(){
   cSenhaOk = true;
   closeModalBS();
   alert('Senha alterada com sucesso.');
   carregaNoticiaPos(); //Funcao Script no arquivo PPLSW00
}

function TrataCaracteres() { 
	var aNewSenAux = new Array(3);


	aNewSenAux[0] = getField('Field_SENHA')!= ''? getField('Field_SENHA' ) : document.getElementById("txtSenhaAtual").value.trim();
	aNewSenAux[1] = getField('Field_NEWSEN') != ''? getField('Field_NEWSEN') : document.getElementById("txtNovaSenha").value.trim();
	aNewSenAux[2] = getField('Field_RNESEN') != ''? getField('Field_RNESEN') : document.getElementById("txtNovaSenhaConf").value.trim();

	const substituicoes = {
    '$': '%24',
    '#': '%23',
    '?': '%3F',
    '=': '%3D',
    '&': '%26',
	'%': '%25'
  	};
	for (var nX=0;nX<aNewSenAux.length;nX++){

		const contemCaracteres = aNewSenAux[nX].match(/[#$%?=&]/g);

		if (contemCaracteres) {
   
   			const substituir = (match) => substituicoes[match];

	
    		const regex = new RegExp(`[${contemCaracteres.join('')}]`, 'g');

	
   			aNewSenAux[nX] = aNewSenAux[nX].replace(regex, substituir);
		}
	}
	return aNewSenAux;
}

function gravaNovaSenha(cSenhaAntiga){
   var hash;
   var aNewSen = new Array(3);

   hash = CryptoJS.MD5(document.getElementById("txtNovaSenhaConf").value);

   if(document.getElementById("txtSenhaAtual").value.trim() == ''){
	   alert('Informe a senha atual.');
   }else if(document.getElementById("txtNovaSenha").value.trim() == ''){
	   alert('Informe a nova senha.');
   }else if(cSenhaAntiga.trim() == document.getElementById("txtSenhaAtual").value.trim()){
	   alert('Senha atual incorreta.');
   }else if(cSenhaAntiga.trim() == hash){
	   alert('A nova senha nao pode ser igual a atual.');
   }else{
		aNewSen = TrataCaracteres()

	   Ajax.open("W_PPLSCHEPAS.APW?Field_SENHA=" + aNewSen[0] + "&Field_NEWSEN=" + aNewSen[1] + "&Field_SENCONF=" + aNewSen[2], {
				 callback: finalizaAltSenha,
				 error: ExibeErro} );
   }
}

function verificaPrimeiroAcesso(v){
   var cTitle     = '<b>Altere sua senha</b>'
   var cContainer = ""
   var aPosicoes  = v.split("|");
   var aBotoes    = "@Confirmar~ gravaNovaSenha('"+aPosicoes[3]+"');"

   if(aPosicoes[4] == "true"){
	   cContainer  = '<table border = "0" align="center">'
	   cContainer += '<tr align="center"> '
	   cContainer += 	'<td colspan = "4">'
	   cContainer += 		'<b>' + aPosicoes[5] + '</b>'
	   cContainer += 	'</td>'
	   cContainer += '</tr>'

	   cContainer += '<tr align="center"> '
	   cContainer += 	'<td colspan = "4">'
	   cContainer += 		'<br>'
	   cContainer += 	'</td>'
	   cContainer += '</tr>'

	   cContainer += '<tr>'
	   cContainer += 	'<td align="right">'
	   cContainer +=		'<label>Senha Atual: </label>'
	   cContainer +=	'</td>'
	   cContainer +=	'<td align="left">'
	   cContainer +=		'<input id="txtSenhaAtual" type="password" selected size="20">'
	   cContainer +=	'</td>'
	   cContainer += '</tr>'
	   cContainer += '<tr>'
	   cContainer += 	'<td align="right">'
	   cContainer +=		'<label>Nova Senha: </label>'
	   cContainer +=	'</td>'
	   cContainer +=	'<td align="left">'
	   cContainer +=		'<input id="txtNovaSenha" type="password" size="20">'
	   cContainer +=	'</td>'
	   cContainer += '</tr>'
	   cContainer += '<tr>'
	   cContainer +=  	'<td align="right">'
	   cContainer +=		'<label>Confirmar Nova Senha: </label>'
	   cContainer +=	'</td>'
	   cContainer +=	'<td align="left">'
	   cContainer +=		'<input id="txtNovaSenhaConf" type="password" size="20">'
	   cContainer +=	'</td>'
	   cContainer += '</tr>'
	   cContainer += '</table>'

	   cContainer += '<script>'
	   cContainer +=	'txtSenhaAtual.focus();'
	   cContainer += '</script>'

	   modalBS(cTitle, cContainer, aBotoes);

	   var oModalBS = document.getElementById("modalBS") != null ? document.getElementById("modalBS") : parent.document.getElementById("modalBS");

	   $(oModalBS).on('hidden.bs.modal', function () {
		   if(!cSenhaOk){
			   alert("E obrigatorio alterar a senha no primeiro acesso.");
			   modalBS(cTitle, cContainer, aBotoes);
			   $("#txtSenhaAtual").focus();
		   }
	   })

	   $(document).keydown(function(e) {

		   if (e.keyCode == 9) {
			   //Caso de TAB o sistema nao interfere na pagina traseira.
			   if(e.target.nodeName != "INPUT" && e.target.nodeName != "BUTTON"){
				   $("#txtSenhaAtual").focus();
				   e.preventDefault();
			   }
		   }
	   });
   }else{
	   carregaNoticiaPos();
   }
}
//Define o value de dropdown dependente que foi populado atraves de webfunction
function SetIndexCombo(){
   if ($("#cTipoOrigem").val() != undefined)
   {
	   var cOrigem = $("#cTipoOrigem").val().split('|');
	   var cTipoGuia = cOrigem[0];
	   var cOpGuia = cOrigem[1];
	   switch(cTipoGuia){
		   case "consulta":				
			   if (cOpGuia == "2") {	
				   //Combo CBOS									
				   var cValcCbosExe = $("#defCb\\|cCbosExe").val().split('|');;
				   $('#cCbosExe').append($('<option>', {
					   value: cValcCbosExe[0],
					   text: cValcCbosExe[1]
				   }));
				   $("#cCbosExe").val(cValcCbosExe[0]).trigger('change');;		
				   $("#cCbosExe").attr("disabled", true); //Desabilita o campo	
			   }
		   break;
	   }
   }
}
function alternaExecucao(){
  fCmpObrigat("");
  for(var i=0; i<oForm.campos.length; i++) {
	   switch (oForm.campos[i].campo.id) {
	   case "cCarSolicit":
			   oForm.campos[i].branco = true;
			   break
	   case "cProSol":
			   oForm.campos[i].branco = true;
			   break
	   case "cCbosExe":
			   oForm.campos[i].branco = true;
			   break
	   }
   }
	   
   setDisable("cProExe",false);
   setDisable('bIncTabExe',false);
   setDisable("bSaveTabExe",false);
   
   if (document.forms[0].cTp.value != "4") {
	   oForm.add( document.forms[0].cTpAteExe,"tudo", false, false ); //transformo os campos em obrigatorio
	   document.forms[0].cTpAteExe.className ="form-control TextoInputOB";//transformo os campos em obrigatorio
   }	

   setDisable("bconfirma",false);
   setDisable("bcomplemento",true);
   setDisable("bimprimir",true);
   setDisable("bAnexoDoc",true);

   //--------------------------------------------------------------------
   // Dados da rda na execucao											   
   //--------------------------------------------------------------------
   if (document.getElementById("cRda").value != "" && document.getElementById("cCodLoc").value != "")
	   fRda(document.getElementById("cRda").value,document.getElementById("cCodLoc").value); 	
}

function isDitacaoOffline(){
	  if (isObject(getObjectID("cTipoOrigem")) && ($("#cTipoOrigem").val() != "" ) ){ 
		  
	   if ( $("#cTipoOrigem").val() == undefined )
	   {
		   var aPosc = window.frames[0].document.getElementById('cTipoOrigem').value.split('|');
	   }
	   else
	   {
		   var aPosc = $("#cTipoOrigem").val().split('|');
	   }
	   
	   if (aPosc.length >= 3) {
		   return false;
	   } else {
			 return true;
	   }
	  }else{
	   if(window.frames[0] != undefined){
		   if (window.frames[0].document.getElementById("cTipoOrigem") != undefined  &&  window.frames[0].document.getElementById("cTipoOrigem").value != ""){
			   return true;
		   }else{
			   return false;
		   }
	   } else {
			return false;
	   }
   }
}

//Altera estado dos campos na digitacao de guias de acordo com a forma de acesso
function alterarCamposGuias(){
   //Altera o estado dos campos para:
   //		- InclusÃ£o: permite alterar as datas dos procedimentos
   //		- AlteraÃ§Ã£o: permite alterar procedimentos, mantendo o cabeÃ§alho (prestador e beneficiÃ¡rios) desabilitado para alteraÃ§Ã£o.
   if ($("#cTipoOrigem").val() != undefined)
   {
	   var cOrigem = $("#cTipoOrigem").val().split('|');
	   var cTipoGuia = cOrigem[0];
	   var cOpGuia = cOrigem[1];
	   switch(cTipoGuia){
		   case "consulta":				
			   if (cOpGuia != "1") {
				   $("#cAtendRN").val($("#defCb\\|cAtendRN").val());
				   $("#cAtendRN").attr("disabled", true); //Desabilita o campo

			   }
		   break;
		   case "sadt":
			   if (cOpGuia == "1") {				
				   alternaExecucao();
			   }
		   break;
		   case "internacao":
			   if (cOpGuia == "1") {	
				   //Inclusao					
				   $("#dDtExePro").attr("readonly", false); //Habilita o campo
			   }
		   break;
		   case "odonto":
			   if (cOpGuia == "1") {	
				   //Inclusao					
				   $("#dDtExe").attr("readonly", false); //Habilita o campo
				   $("#dDtEmissao").attr("readonly", false); //Habilita o campo
				   $("#dDtTT").attr("readonly", false); //Habilita o campo
				   
					$( "#dDtEmissao,#dDtExe,#dDtTT" ).blur(function() {
					   validaCmp(this,"data","Data invalida") && verificaDtRetro(this);
				   });			
				   
				   alternaExecucao();
			   }
		   break;
		   case "honorario":
			   if (cOpGuia == "1") {	
				   //Inclusao					
				   $("#dDtEmissao").attr("readonly", false); //Habilita o campo
				   $("#dDtExe").attr("readonly", false); //Habilita o campo
				   $("#dDataIniFat").attr("readonly", false); //Habilita o campo
			   }
		   break;			
	   }	
   }
   
}
function verificaDtRetro(cData){
   var lRet = true;
   if(isObject("dDtLimRetro")){
	   //a data vem no formato dd/mm/aaaa e para fazer um new Date preciso fazer aaaa/mm/dd
	   var valEncDt = $("#dDtLimRetro").val();
	   $.base64.utf8encode = true;
	   var parsedStr = ($.base64.decode(valEncDt));
	   var dtLimRetro = new Date(parsedStr.split("/").reverse().join("/"));
	   var dtInf = new Date(cData.value.split("/").reverse().join("/"));
	   if(dtLimRetro > dtInf){
		   alert("A data inserida nao pertence ao intervalo do periodo maximo permitido para inclusao de guias retroativas.");
		   lRet = false;
	   }
   }
   if(!lRet) {
	   //Foi necessÃ¡rio usar desta forma pois o FIREFOX tem um BUG que nÃ£o suporta .focus()
	   globalvar = cData;
	   setTimeout("globalvar.focus()",250);
   }
   return lRet;
}

//Gravacao simples para os campos que podem ser alterados na guia apos autorizacao
//Na montagem do retorno, utilize o alias padrao da tabela BEA e BD5, para montagem dinamica dos campos na gravacao: vide PLSFNCDOFF
function fRecCmp(formulario) {
   var cElemts 	= "";
   var cElemtsIts 	= "";
   var aResult 	= {};
   if ( isAlteraGuiaAut() ) {
	   aResult = $("#cAltCmpG").val().split("|");
	   if (aResult[2] == '02') {  //Significa guia SADT
		   cElemts  = aResult[1] + '|';
		   cElemts += "TIPATE: " + document.getElementById("cTpAteExe").value + '|' ;
		   cElemts += "INDACI: " + document.getElementById("cIndAcid").value + '|' ;
		   cElemts += "TIPCON: " + document.getElementById("cTpCon").value + '|' ;
		   cElemts += "TIPSAI: " + document.getElementById("cTpSai").value + '|' ;
		   cElemts += "OBSERV: " + document.getElementById("cObs").value + '|' ;
	   }
	   else{ //Guia Consulta
		   cElemts  = aResult[1] + '|' ;
		   cElemts += "INDACI: " + document.getElementById("cIndAcid").value + '|' ;
		   cElemts += "CDPFRE: " + document.getElementById("cProSol").value  + '|' ; 	
		   cElemts += "CODESP: " + document.getElementById("cCbosExe").value.substr(0, 3) + '|' ;	
		   cElemts += "OBSERV: " + document.getElementById("cObs").value + '|' ;
		   cElemts += "TIPCON: " + document.getElementById("cTpCon").value + '|' ;
		   cElemtsIts = "VLRAPR: " + document.getElementById("cVlrPro").value + '|' ;	
	   }
   
   Ajax.open("W_PPLGRCAAUT.APW?cElmts="+cElemts+"&cElmtsIts="+cElemtsIts, {callback: fSucAlt, error: ExibeErro} );
   }
setDisable("bconfirma",true);
}
   
//mensagem de sucesso após gravação
//Vide PLSFNCDOFF	
function fSucAlt(){
   var cTexto = "";
	   cTexto = "<p> Alterações gravadas com sucesso! </p>";
	   modalBS("Atenção", cTexto, "@Fechar~closeModalBS();", "white~#00FF7F");	
}


//Chama "autorizacao" da Consulta e SADT
function fChamConsulta(cNumeLib) {
   var cAltG	= "";
   cAltG = "Altcmp"; 
   
   //Verifica se foi informado a chave
   if (cNumeLib == "") {
	   alert("Informe o número da Solicitação");
	   return;
   }
   
   //?Retira a mascara													  
   cNumeLib = cNumeLib.replace(/\D/g, "");
   var cRda = document.getElementById("cRda").value;
   var cMatric = document.getElementById("cNumeCart").value;
   var cCodLoc = document.getElementById("cCodLoc").value;
   
   if ( isAlteraGuiaAut() ) {
	   aResult = $("#cAltCmpG").val().split("|");
	   if (aResult[2] == '01') {  
		   Ajax.open("W_PPLSCHALIB.APW?cNumeAut=" + cNumeLib + "&cRda=" + cRda + "&cCodLoc=" + cCodLoc + "&cMatric=" + cMatric + "&cTp=01&cAltGuia=" + cAltG, {
			   callback: fMostraCons,
			   error: ExibeErro
		   });	
	   }
	   else {
		   Ajax.open("W_PPLSCHALIB.APW?cNumeAut=" + cNumeLib + "&cRda=" + cRda + "&cCodLoc=" + cCodLoc + "&cMatric=" + cMatric + "&cTp=02&cAltGuia=" + cAltG, {
			   callback: fRespostaSADT,
			   error: ExibeErro
		   });	
	   }
   }	
}


//Pega o retorno da Consulta			
function fMostraCons(v) {   
   var aMatCabIte 	= v.split("<");
   var aMatCab 	= aMatCabIte[0].split("|");
   var aMatItens	= aMatCabIte[1].split("@");
   var aResult 	= {};
   var cTexto		= "";

   //?Verifico se a estrutura dos itens foram enviadas					  
   if (typeof aMatCabIte[1] == "undefined") {
	   alert("Estrutura indefinida");
	   return;
   }

   //Cabecalho e dados do executante 				  
   for (var i = 0; i < (aMatCab.length - 1); i++) {
	   var aCamVal = aMatCab[i].split("!");
	   
	   //Somente se foi passado o nome do campo								  
	   if (aCamVal[0] != "" && "cCbosExe".indexOf(aCamVal[0]) < 0 ) {
		   var cCampo = document.getElementById(aCamVal[0]);
		   if (cCampo != null) {
			   cCampo.value = aCamVal[1]; 
		   }
	   

	   }else if (aCamVal[0] == "cCbosExe"){
		   cIndCombo += "cCbosExe;" + aCamVal[1].trim() + "|"; //Concateno o indice pra atribuir no fim de tudo pra a combo não perder a referência por causa do ajax
		   $('#cCbosExe option[value^="' + aCamVal[1].trim() + '"]').prop('selected', true);
	   }
   }

   
   //Passo os dados do atendimento para os campos.				  
   for (var i = 0; i < (aMatItens.length - 1); i++) {
	   var aCamVal = aMatItens[i].split("!");
	   
	   //Somente se foi passado o nome do campo								  
	   if (aCamVal[0] != "") {
		   var cCampo = document.getElementById(aCamVal[0]);
		   if (cCampo != null) {												  
			   cCampo.value = aCamVal[1];
		   } 
	   }
   }
   setDisable("dDtAtend",true); // Na consulta a data é definida na janela anterior e não pode ser alterada por existirem validações
   setDisable("bconfirma",false);
   setDisable("bcomplemento",true);
   setDisable("bimprimir",true);
   setDisable("bAnexoDoc",true);
   setDisable("cProSolDesc",true); //Desabilita o texto do campo nome profissional executante

   //Carrega profissionais do campo executante, apenas do id ser cProSol.
   fProfSau(document.getElementById('cProSol').value,'E');

if( !isDitacaoOffline() && isAlteraGuiaAut() ){	
   cTexto = "<p> Somente os campos disponíveis para edição podem ser alterados após Autorização da guia. Os demais campos são apenas para visualização! </p>";
   modalBS("Atenção", cTexto, "@Fechar~closeModalBS();", "white~#ffff00");
   }else if ( isDitacaoOffline() && isAlteraGuiaAut() ){
	   _$Forminputs = $('form :input:not([type=submit][type=button])');

	   for (var i = 0; i < _$Forminputs.length; i++) {
		   $(_$Forminputs[i]).data('default', $(_$Forminputs[i]).val());
	   }

	   document.getElementById("cLstCmpAlt").value =  ""
	   
	   _$Forminputs.on('blur', function(e) {

		   for (var i = 0; i < _$Forminputs.length; i++) {
			   if ($(_$Forminputs[i]).prop('id') != "cLstCmpAlt"){
				   if ($(_$Forminputs[i]).val() != $(_$Forminputs[i]).data('default')) {
						  $(_$Forminputs[i]).data('default', $(_$Forminputs[i]).val());
						  document.getElementById("cLstCmpAlt").value += $(_$Forminputs[i]).prop('id') + "$" + $(_$Forminputs[i]).val() + ";";
				   }
			   }
		   }
	   });

   }		
}


function fRespostaSADT(v) {   
   var cPSol 		= "";
   var cNSol 		= "";
   var cPSol1 		= "";
   var cNSol1 		= "";
   var cCbos 		= "";

	document.getElementById("cLstCmpAltServ").value =  "";
   //aMatCabIte -> Tem os dados do Cabe?lho e detalhe. 
   
   var objJson = '{ ';	
   var objSubJsonCabec = "";
   var objSubJsonProc = "";
   var aJsonCamposCabec = new Array();
   
   if ( v.indexOf('$') != -1) {
	   var aMatPro     = v.split("|-|");
	   var aMatCabIte 	= aMatPro[0].split("<");
	   var aMatCab 	= aMatCabIte[0].split("|");
	   var aProf		= aMatPro[1].split("$");
   }
   else{
	   var aMatCabIte 	= v.split("<");
	   var aMatCab 	= aMatCabIte[0].split("|");
   }
   cCampoRefL 		= "";
   //--------------------------------------------------------------------
   // Verifico se a estrutura dos itens foram enviadas					  
   //--------------------------------------------------------------------
   if (typeof aMatCabIte[1] == "undefined") {
	   alert("Estrutura indefinada");
	   return;
   }
   var aMatIte = aMatCabIte[1].split("~");
   //--------------------------------------------------------------------
   // Exibi criticas de procedimentos que nao podem ser executados		  
   //--------------------------------------------------------------------
   if (typeof aMatCab[aMatCab.length-1] != "undefined") {
	   if (aMatCab[aMatCab.length-1] != "") alert(aMatCab[aMatCab.length-1]);
   }
   //--------------------------------------------------------------------
   // Cabecalho e dados do executante caso for somente um					  
   //--------------------------------------------------------------------
   for (var i = 0; i < (aMatCab.length - 1); i++) {
	   var aCamVal = aMatCab[i].split("!");
	   //--------------------------------------------------------------------
	   // Somente se foi passado o nome do campo								  
	   //--------------------------------------------------------------------
	   if (aCamVal[0] != "") {
		   var cCampo = document.getElementById(aCamVal[0]);
		   if (aCamVal[0] != "" && "cOriMov".indexOf(aCamVal[0]) == 0 ){
			   cOriMov = aCamVal[1];
		   }
		   if (cCampo != null) {
			   //--------------------------------------------------------------------
			   // Se nao for o cCbos													  
			   //--------------------------------------------------------------------
			   if (aCamVal[0] != "" && "cCbosSol/cNomeSol/cCnpjSolT/cNomeSolT/cCbosExe".indexOf(aCamVal[0]) < 0 ) {  
				   cCampo.value = aCamVal[1];
				   aJsonCamposCabec.push('"' + cCampo.id + '"' + ':{ "defaultValue" : ' + '"' + aCamVal[1].trim() + '"' + ', "actualValue":' + '"' + aCamVal[1].trim() + '"}');
			   } else if (aCamVal[0] == "cNomeSol") {
				   cNSol = aCamVal[1];
				   document.getElementById("cNomeSol").value = cNSol;
				   aJsonCamposCabec.push('"' + "cNomeSol" + '"' + ':{ "defaultValue" : ' + '"' + cNSol.trim() + '"' + ', "actualValue":' + '"' + cNSol.trim() + '"}');
			   } else if (aCamVal[0] == "cCnpjSolT") {
				   cPSol1 = aCamVal[1];
				   aJsonCamposCabec.push('"' + "cCnpjSolT" + '"' + ':{ "defaultValue" : ' + '"' + cPSol1.trim() + '"' + ', "actualValue":' + '"' + cPSol1.trim() + '"}');
			   } else if (aCamVal[0] == "cNomeSolT") {
				   cNSol1 = aCamVal[1];
				   document.getElementById("cNomeSolT").value = cNSol1;
				   aJsonCamposCabec.push('"' + "cNomeSolT" + '"' + ':{ "defaultValue" : ' + '"' + cNSol1.trim() + '"' + ', "actualValue":' + '"' + cNSol1.trim() + '"}');
			   } else if (aCamVal[0] == "cCbosExe") {
				   cCbos = aCamVal[1].trim();
				   aJsonCamposCabec.push('"' + "cCbosExe" + '"' + ':{ "defaultValue" : ' + '"' + cCbos.trim() + '"' + ', "actualValue":' + '"' + cCbos.trim() + '"}');
			   } else if (aCamVal[0] == "cCbosSol" ) {
				   if (aCamVal[1].trim() != ""){
					   cIndCombo += "cCbosSol;" + aCamVal[1].trim() + "|"; //Concateno o indice pra atribuir no fim de tudo pra a combo não perder a referência por causa do ajax
					   $('#cCbosSol option[value^="' + aCamVal[1].trim() + '"]').prop('selected', true);
					   aJsonCamposCabec.push('"' + "cCbosSol" + '"' + ':{ "defaultValue" : ' + '"' + aCamVal[1].trim() + '"' + ', "actualValue":' + '"' + aCamVal[1].trim() + '"}');						
				   } else {
					   cIndCombo += "cCbosSol;" + cCbos + "|";
					   $('#cCbosSol option[value^="' + cCbos + '"]').prop('selected', true); 
					   aJsonCamposCabec.push('"' + "cCbosSol" + '"' + ':{ "defaultValue" : ' + '"' + cCbos + '"' + ', "actualValue":' + '"' + cCbos + '"}');	
				   }
			   }

			   //--------------------------------------------------------------------
			   // Codigo e Nome do HOSPITAL SOLICITANTE								  
			   //--------------------------------------------------------------------
			   if (cNSol1 != "" && cPSol1 != "") {
				   setTC(document.getElementById("cNomeSolT"),"");
				   var e = document.getElementById("cNomeSolT");
				   e.options[0] = new Option(cNSol1, cPSol1);
				   alert(cPSol1)
				   cPSol1 = "";
				   cNSol1 = "";
			   }

		   }
	   }
   }

   //Carrega profissionais do campo solicitante
   fProfSau(document.getElementById('cProSol').value,'S');

   //--------------------------------------------------------------------
   //Abre os grupos para evitar erro no carregamento dos grids.
   //--------------------------------------------------------------------	
   var aMatIteG  = new Array()
   var aMatProfG = new Array()
   
   //--------------------------------------------------------------------
   // Monta o array com os itens do detalhe da solicitação de procedimento 
   //--------------------------------------------------------------------
   var cont = 1;
   
   for (var i = 0; i < aMatIte.length; i++) {
	   //--------------------------------------------------------------------
	   // Matriz com os campos e valores SERVICO								  
	   //--------------------------------------------------------------------
	   if (aMatIte[i] != "" && aMatIte[i] != "|-|") {
		   //--------------------------------------------------------------------
		   //?Aprimeira posicao da matriz aMatval e o tipo de servico a segunda      		
		   //?e se vai ser exibido ou nao da terceira em diante contem valores dos campos	
		   //--------------------------------------------------------------------
		   var aMatVal = aMatIte[i].split("@");
		   
		   for(var p = 0; p < aMatVal.length; p++) {
			   aNew = aMatVal[p].split("!");
			   
			   if(aNew[0] == "cDesPro")
				   aMatVal[p] = aNew[0] + "!"  + htmlDecode(aNew[1]);
		   }
		   
		   var aAux 
		   objSubJsonProc += "{";
		   for(var j = 0; j < aMatVal.length; j++){
			   aAux = aMatVal[j].split("!");
			   
			   if (aAux[1] == undefined){
				   aAux = Array(2);
				   aAux[0] = "cTpServ";
				   aAux[1] = "S";
			   }
			   
			   objSubJsonProc += '"' + aAux[0] + '"' + ':{ "defaultValue" : ' + '"' + aAux[1].trim() + '"' + ', "actualValue":' + '"' + aAux[1].trim() + '"}';
			   objSubJsonProc += ","
		   }
		   
		   objSubJsonProc +=  '"sequen":' + '"' + cont.toString() + '",';
		   objSubJsonProc +=  '"lNewIte":false,';
		   objSubJsonProc +=  '"lDelIte":false}';
		   objSubJsonProc +=  i < (aMatIte.length - 2) ? "," : ""
		   cont++;
		   
		   //--------------------------------------------------------------------
		   //?A segunda posicao [1] retorna se e possivel exibir para uma rda o procedimento  
		   //--------------------------------------------------------------------
		   var cMostraSer = aMatVal[1].split("!")[1];
		   
		   /*if(aMatVal[26].split("!")[1] == 'S') //Se for pacote, exibe a mensagem.
			   alert('O pacote de codigo ' + aMatVal[3].split("!")[1] + ' possui procedimentos relacionados, os procedimentos serao carregados e devem compor a guia.');
			   */
			 //--------------------------------------------------------------------
			 //aMatIteG
		   //Estrutura: Tipo - Array, Conte?o - Linha do detalhe
		   //	Estrutura: Tipo - String, Conte?o - Coluna do detalhe: Variavel_Protheus!Valor 
		   //	***N? necess?iamente a coluna existe no grid. Isso ?validado posteriormente
			 //--------------------------------------------------------------------
		   aMatIteG.push(aMatVal)
		  aCodProc = aMatVal[4].split("!")[1]
	   }
   }
   //Profissionais
   if(aProf != undefined){
	   for (var i = 0; i < aProf.length; i++) {
		   //--------------------------------------------------------------------
		   // Matriz com os campos e valores SERVICO								  
		   //--------------------------------------------------------------------
		   if (aProf[i] != "") {
			   //--------------------------------------------------------------------
			   //?Aprimeira posicao da matriz aMatval e o tipo de servico a segunda      		
			   //?e se vai ser exibido ou nao da terceira em diante contem valores dos campos	
			   //--------------------------------------------------------------------
			   var aMatValP = aProf[i].split("@");
			   //aMatValP = aMatValP.split("&");
		   aMatProfG.push(aMatValP)
		   }
	   }
   }
  
	   //--------------------------------------------------------------------
	   //Chama a função que carrega os grids.
	   //Pede para a função preencher o grid de proc. Sol. "TabSolSer" e copiar os itens pro grid proc. Exec. "TabExeSer"
	   //--------------------------------------------------------------------
	   fCarregaTabela('TabSolSer$0|TabExeSer$1|TabExe$1',aMatIteG,cMostraSer, aMatProfG);

   if(aProf != undefined){
	   fCarregaTabela('TabExe$1', aMatProfG); 
   }

	   //Desabilita grid de executantes
	   toggleDiv('GrpIndExe');
	   setDisable("bIncTabExe",false);
	   setDisable("bSaveTabExe",true);
   //--------------------------------------------------------------------
   // Execucao															   
   //--------------------------------------------------------------------
   if( !isDitacaoOffline() && isAlteraGuiaAut() ){	
	   setDisable("cProExeDesc",true);
	   setDisable("cProSolDesc",true);
	   setDisable("BcProSol",true);
	   setDisable('bIncTabExe',true);
	   setDisable("bSaveTabExe",true); 	
	   setDisable("bconfirma",false);
	   setDisable("bcomplemento",true);
	   setDisable("bimprimir",true);
	   setDisable("bAnexoDoc",true);
	   setDisable("bIncTabExeSer",true);
	   setDisable("bSaveTabExeSer",true);
	   setDisable("btnTabExeSer0",true);
	   setDisable("bIncTabSolSer",true);
	   setDisable("bSaveTabSolSer",true);
	   setDisable("bIncTabExeSer",true);
	   setDisable(cBtnExec,true);
   
   } else if ( isDitacaoOffline() && isAlteraGuiaAut() ){
	   setDisable("bIncTabSolSer",true);
	   setDisable("bSaveTabSolSer",true);
	   setDisable(cBtnExec,true);
		   //Inicia Grupo de Solicitação desabilitado
		   toggleDiv('GrpSolSer');
	   
	   _$Forminputs = $('form :input:not([type=submit][type=button])');

	   for (var i = 0; i < _$Forminputs.length; i++) {
		   $(_$Forminputs[i]).data('default', $(_$Forminputs[i]).val());
	   }
	   
	   //-----------------------------------------------------------------------
	   //Concatena objetos JSON
	   //-----------------------------------------------------------------------
	   for (var n = 0; n < aJsonCamposCabec.length; n++) {
		   objSubJsonCabec += aJsonCamposCabec[n];

		   //Se não for o último índice do array, adiciona vírgula no json 
		   if (n != aJsonCamposCabec.length - 1)
			   objSubJsonCabec += ",";
	   }

	   objJson += ' "cabecalho":{' + objSubJsonCabec + '}, ';

	   //Concatena informações dos procedimentos no objeto JSON
	   objJson += ' "procedimentos":[' + objSubJsonProc + ']}';
	   //-----------------------------------------------------------------------
	   // Crio um objeto com escopo global que contém os dados da SADT
	   //-----------------------------------------------------------------------
	   oGuiaOff = JSON.parse(objJson);

		   
	   //Altera mascara dos campos de valores
	   document.getElementById('nVlrUniSExe').value = document.getElementById('nVlrUniSExe').value.replace('.','').replace(',','.');			
	   document.getElementById('nVlrTotSExe').value = document.getElementById('nVlrTotSExe').value.replace('.','').replace(',','.');
	   
	   //----------------------------------------------------------
	   //Alterar onchange dos campos editaveis da guia odontologica
	   //----------------------------------------------------------
	   _$Forminputs.on('blur', function(e) {
		   for (var i = 0; i < _$Forminputs.length; i++) {
			   if(oGuiaOff.cabecalho[$(_$Forminputs[i]).prop('id')] != undefined){
				   if (oGuiaOff.cabecalho[$(_$Forminputs[i]).prop('id')].defaultValue != $(_$Forminputs[i]).val()){
					   //Se o valor atual for diferente do default, atribui o valor do campo ao atual.
					   if($(_$Forminputs[i]).prop('id') == "cCbosSol" || $(_$Forminputs[i]).prop('id') == "cCbosExe"){
						   oGuiaOff.cabecalho[$(_$Forminputs[i]).prop('id')].actualValue = $(_$Forminputs[i]).val().substring(0,3);
					   }else{
						   oGuiaOff.cabecalho[$(_$Forminputs[i]).prop('id')].actualValue = $(_$Forminputs[i]).val();
				   }
			   }
		   }
	   }
   });
	   


  }

  CalculaTotaisGuia();
}

function camposServico(cID){
   if(cID == "dDtExe" || cID == "cHorIniSExe" || cID == "cHorFimSExe" || cID == "cCodPadSExe" || cID == "cCodProSExe" ||
	  cID == "cDesProSExe" || cID == "cQtdSExe" || cID == "cViaSExe" || cID == "cTecSExe" || cID == "nRedAcreSExe" ||
	  cID == "nVlrUniSExe" || cID == "nVlrTotSExe"){
	  return true;
   }else
	  return false;
}

function confirmaConsulta(cTipo){
   var cRecno= "";
   closeModalBS();
   
   if( isDitacaoOffline() && isAlteraGuiaAut() ){
	  //Jquery não considera esse campo como alterado, sempre irá alterar.
	  window.frames[0].document.getElementById("cLstCmpAlt").value +=  "cVlrPro$"  +  window.frames[0].document.getElementById('cVlrPro').value.replace(',','') + ";";
	 
	  if($("#cRecnoBD5").val() != undefined)
		 cRecno = $("#cRecnoBD5").val();
		 else
			cRecno = window.frames[0].document.getElementById("cRecnoBD5").value;
			
	   window.frames[0].document.forms[0].action = "W_PPLPROCALT.APW?cRecno="+cRecno+"&cTipoOrigem=digitacao&cTipoConfirm="+cTipo;
	  
	  Ajax.send(window.frames[0].document.forms[0], {
		  callback: carregaResp,
		   error: ExibeErro
	   });	 
	  
   }else{
	  window.frames[0].document.forms[0].action = "W_PPLPROCGUI.APW?cRecno="+cRecno+"&cTipoOrigem=digitacao&cTipoConfirm="+cTipo;
	  
	  Ajax.send( window.frames[0].document.forms[0], {callback:CarregaProcFormCon, error: ExibeErro} );
   }
	   
   document.forms[0].action = "";
   //--------------------------------------------------------------------
   // Desabilita os campos												   
   //--------------------------------------------------------------------
   FDisElemen('Tdb|Tdc|Thd|Tdp|Toth',true);
}

function confirmaSADT(cTipo){
   var cRecno= "";
   closeModalBS();
   
   if( isDitacaoOffline() && isAlteraGuiaAut() ){
	  //Jquery não considera esse campo como alterado, sempre irá alterar.
	  if($("#cRecnoBD5").val() != undefined)
		 cRecno = $("#cRecnoBD5").val();
		 else
			cRecno = window.frames[0].document.getElementById("cRecnoBD5").value;
							   
	   //Jquery não considera esse campo como alterado, sempre irá alterar.
	   if($("#cRecnoBD5").val() != undefined){
		   cRecno = $("#cRecnoBD5").val();
	   }else{
		   cRecno = window.frames[0].document.getElementById("cRecnoBD5").value;
	   }
	   
	   var cCabecalhoEdited = "";
	   var objLocalSADT = window.frames[0].oGuiaOff;
	   
	   //---------------------------------------------------------------------------------
	   //									CABECALHO
	   //---------------------------------------------------------------------------------
	   //Alteracao off-line, recuperar os campos do cabecalho contidos no objeto oGuiaOff.
	   //Campos a serem alterados sao os campos cujo conteudo default nao e' igual ao actualvalue, isto e', houve mudanca.
	   for (var c in objLocalSADT.cabecalho){
		   if(objLocalSADT.cabecalho[c].defaultValue != objLocalSADT.cabecalho[c].actualValue){
			   cCabecalhoEdited += c + "$" + objLocalSADT.cabecalho[c].actualValue + ";";
		   }
	   }

	   //---------------------------------------------------------------------------------
	   //							PROCEDIMENTOS ADICIONADOS
	   //---------------------------------------------------------------------------------
	   //Alterações existentes na grid de procedimento da guia sadt.
	   //Itens adicionados são aqueles que tem a propriedade LNEWITE verdadeira e LDELITE falsa pois se o usuário incluiu e depois deletou o procedimento
	   //ainda não foi pra base então desconsidero
	   var addedItems = getObjects(objLocalSADT.procedimentos, "lNewIte", true);
	   addedItems = getObjects(addedItems, "lDelIte", false);
	   
	   var strAdded = "";
	   var i = 0;

	   //Para os itens adicionados preciso enviar todos os atributos para o servidor.
	   for(i=0; i< addedItems.length; i++){		
		   for(var key in addedItems[i]){
				   switch(key) {
					   case "lNewIte":
					   case "lDelIte":
					   case "sequen":
						   strAdded += key+"="+addedItems[i][key]+"$";
						   break;
					   default:
						   strAdded += key+"="+addedItems[i][key].actualValue+"$";
				   }
		   }
		   strAdded = strAdded.slice(0, -1);
		   strAdded += i == (addedItems.length - 1) ? "" : "&";
	   }
	   
	   //---------------------------------------------------------------------------------
	   //							PROCEDIMENTOS EXCLUIDOS
	   //---------------------------------------------------------------------------------
	   //Itens excluídos são os que vieram da base, ou seja LNEWITE falso e LDELITE verdadeira
	   var deletedItems = getObjects(objLocalSADT.procedimentos, "lNewIte", false);
	   deletedItems = getObjects(deletedItems, "lDelIte", true);
	   
	   var strDeleted = "";
	   
	   //Para os itens excluidos preciso enviar apenas os atributos chave para localizar na BD6.
	   for(i=0; i<deletedItems.length;i++){
			   strDeleted += "cCodPadKey="	+deletedItems[i].cCodPad.defaultValue;
			   strDeleted += "$cCodProKey="	+deletedItems[i].cCodPro.defaultValue;
			   strDeleted += "$cSeqMov="		+deletedItems[i].cSeqMov.defaultValue;
			   strDeleted += i == (deletedItems.length - 1) ? "" : "&";
	   }
	   
	   //---------------------------------------------------------------------------------
	   //							PROCEDIMENTOS ALTERADOS
	   //---------------------------------------------------------------------------------
	   //Itens editados são todos os itens que vieram da base, ou seja LNEWITE falso e LDELITE falso e que possuem algum atributo modificado
	   //defaultValue diferente de actualValue
	   var editedItems = getObjects(objLocalSADT.procedimentos, "lNewIte", false);
	   editedItems = getObjects(editedItems, "lDelIte", false);
	   
	   var strEdited = "";
	   var edited = false;
	   var cCodPadEdited = false;
	   var cCodProEdited = false;
	   var cIteProp = "";
	   var lNvlrApAl		= false;
	   var lRedAcrAl		= false;
	   var lQtdSol			= false;

	   //Para os itens alterados, preciso enviar os atributos chave para localizar na BD6 e mais os atributos modificados (defaultValue diferente de actualValue)
	   for(i=0; i<editedItems.length;i++){
		   edited = false;
		   cIteProp = "";
		   cCodPadEdited = false;
		   cCodProEdited = false;

		   //verifico se o codigo da tabela ou do procedimento foi alterado, pois vou ter que enviar todos os campos para o servidor para inserir uma nova BD6
		   if(editedItems[i].cCodPro.defaultValue != editedItems[i].cCodPro.actualValue ||
			  editedItems[i].cCodPad.defaultValue != editedItems[i].cCodPad.actualValue){
			  edited = true;
		   for(var key in editedItems[i]){
				   switch(key) {
					   case "lNewIte":
					   case "lDelIte":
					   case "sequen":
						   cIteProp += key+"="+editedItems[i][key]+"$";
						   break;
					   case "cSeqMov":
						   break;
					   default:
						   strEdited += key+"="+editedItems[i][key].actualValue+"$";
				   }
			   }
			   
		   }else{		
			   for(var key in editedItems[i]){
				   if(key == "lNewIte" || key ==  "lDelIte" || key ==  "sequen"){
					   cIteProp += key+"="+editedItems[i][key]+"$";
				   }else if(editedItems[i][key].actualValue.toUpperCase() != editedItems[i][key].defaultValue.toUpperCase()){
						   edited = true;
							   
							   //garanto sempre a tabela e o procedimento na string quando o procedimento for alterado
							   //pois preciso fazer o de/para no webservice
							   if(key == "cCodPro" && !cCodPadEdited){
								   strEdited += "cCodPad="+editedItems[i]["cCodPad"].actualValue+"$";
								   cCodPadEdited = true;
							   }

							   if (key == "nVlrApr" ) {
								   lNvlrApAl = true;
							   }
							   
							   if (key == "nRedAcre" ) {
								   lRedAcrAl = true;
							   }
							   
							   if (key == "nQtdSol" ) {
								   lQtdSol = true;
							   }
							   
							   //garanto que o cCodPadSExe não será adicionado duas vezes
							   if( !(key == "cCodPad" && cCodPadEdited) ){
								   strEdited += key+"="+editedItems[i][key].actualValue+"$";
							   }
				   }
			   }
		   }
		   
		   //A chave nem sempre pode ter sido alterada, e não vai entrar no if acima
		   //para garantir que ela sempre estará presente na string, verifico se foi editada alguma propriedade e adiciono a chave a string
		   if(edited){
			   strEdited +=  "cCodPadKey="  	+editedItems[i].cCodPad.defaultValue+"$";
			   strEdited +=  "cCodProKey="		+editedItems[i].cCodPro.defaultValue+"$";
			   strEdited +=  "cSeqMov="		    +editedItems[i].cSeqMov.defaultValue+"$";
			   //Se alterado valor unitário ou red/acr ou qtd, devo obrigatoriamente passar esses parâmetros, para cálculo do valor apresentado e valori.
			   if (lNvlrApAl || lRedAcrAl || lQtdSol) {
				   if (strEdited.indexOf('nVlrApr') == -1) {
					   strEdited += "nVlrApr=" + editedItems[i].nVlrApr.actualValue + "$";
			   }
				   if (strEdited.indexOf('nRedAcre') == -1) {
					   strEdited += "nRedAcre=" + editedItems[i].nRedAcre.actualValue + "$";
			   }
				   if (strEdited.indexOf('nQtdSol') == -1) {
					   strEdited += "nQtdSol=" + editedItems[i].nQtdSol.actualValue + "$";
				   }
			   }
			   
			   strEdited += cIteProp;
			   strEdited = strEdited.slice(0, -1);
		   }
		   
		   strEdited += i == (editedItems.length - 1) ? "" : "&";
		   
	   }

	   //---------------------------------------------------------------------------------
	   //							CRIACAO DE HIDDENS
	   // Crio os hidden no formulario para enviar via POST para o servidor 
	   //---------------------------------------------------------------------------------		
	   var dDtCorrigida = fValidaMenDtAtd("TabExeSer");
	   //Passo a menor data do procedimento realizado, para atualizar o campo BD5_DATPRO
	   cCabecalhoEdited = cCabecalhoEdited + 'dDataCorDig$' + dDtCorrigida + ";"
	   
	   var cHiddenCabecalhoAlterado	= document.createElement('input');
	   cHiddenCabecalhoAlterado.id	 	= 'cCabecalhoEdited';
	   cHiddenCabecalhoAlterado.type 	= 'hidden';
	   cHiddenCabecalhoAlterado.value 	= cCabecalhoEdited;
	   window.frames[0].document.forms[0].appendChild(cHiddenCabecalhoAlterado);		
	   
	   addedItems	= document.createElement('input');
	   addedItems.id	 	= 'cAddedItems';
	   addedItems.type 	= 'hidden';
	   addedItems.value 	= strAdded;
	   window.frames[0].document.forms[0].appendChild(addedItems);
	   
	   deletedItems	= document.createElement('input');
	   deletedItems.id	 	= 'cDeletedItems';
	   deletedItems.type 	= 'hidden';
	   deletedItems.value 	= strDeleted;
	   window.frames[0].document.forms[0].appendChild(deletedItems);
	   
	   editedItems	= document.createElement('input');
	   editedItems.id	 	= 'cEditedItems';
	   editedItems.type 	= 'hidden';
	   editedItems.value 	= strEdited;
	   window.frames[0].document.forms[0].appendChild(editedItems);

	   //Atribuo a action ao form - alteração é tratada por outra web function
	   window.frames[0].document.forms[0].action = "W_PPLGRSADT.APW?cRecno="+cRecno+"&cTipoOrigem=digitacao&cTipoConfirm="+cTipo;	   

	   Ajax.send(window.frames[0].document.forms[0], {
		   callback: carregaResp,
		   error: ExibeErro
	   });	   
	   
   }else{
	   var dDtCorrigida = fValidaMenDtAtd("TabExeSer", "1");
	   
	   window.frames[0].document.forms[0].action = "W_PPLPROCGUI.APW?cTipoOrigem=digitacao&cTipoConfirm="+cTipo;		               

	   Ajax.send(window.frames[0].document.forms[0], {
			   callback: CarregaProcForm,
			   error: ExibeErro
	   });
   }
	   
	  document.forms[0].action = "";
}

function confirmaInt(cTipo){
   closeModalBS()
   window.frames[0].document.forms[0].action = "W_PPLPROCGUI.APW?cTipoOrigem=digitacao&cTipoConfirm=cTipo";
   
   //--------------------------------------------------------------------
   // Verfica se foi digitado algum procedimento							   
   //--------------------------------------------------------------------
   var lVld = false;
   if (window.frames[0].document.getElementById("cNumAut").value=="") {
	   
	   if(typeof oTabSolSer == "string"){
		   lVld = true;
		   cMsg = 'Solicitação';
	   }	
   } else {
	   cMsg = 'Prorrogação';
	   lProrroga = true;
	   if(typeof oTabProSer == "string"){
		   lVld = true;
	   } else {           
		   lVld = true;
		   var oTable  = oTabProSer.getObjCols();
		   if(oTable == null){
		   alert("Informe pelo menos uma prorrogação");
		   return;
		   }
		   for (var y = 0; y < oTable.rows.length; y++) {
			   lVld = false;
			   break                                                
		   }        	
	   }	
   }	 	                                   
   //--------------------------------------------------------------------
   // aviso																   
   //--------------------------------------------------------------------
   if (lVld) {
	   alert("Informe pelo menos um serviço para a " + cMsg);
	   return;
   }
   //--------------------------------------------------------------------
   // Monta conteudo das tabelas solicitacao e execucao					  
   //--------------------------------------------------------------------
   if (window.frames[0].document.getElementById("cNumAut").value=="")
		aMatAux = "TabSolSer";
   else aMatAux = "TabProSer";
   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   cStringEnvTab = "";                                     
   var nSeq 	  = 0;
   //--------------------------------------------------------------------
   // Pega a sequencia de maior numero
   //--------------------------------------------------------------------
   if (window.frames[0].document.getElementById("cNumAut").value!="") {
	   var aMatAnt = "TabSolSer|TabProSer";
	   aMat 		= aMatAnt.split("|");
   
	   for (var i = 0; i < aMat.length; i++) {
		   e = eval("o" + aMat[i])
		   oTable = e.getObjCols();
		   
		   for (var y = 1; y < oTable.rows.length; y++) {
			   
				   if ( oTable.rows[y].innerHTML.indexOf('chkbox') == -1) {     
				   if ( parseInt( getTC(oTable.rows[y].cells[0]) , 10 ) > nSeq ) {
					   nSeq = parseInt( getTC(oTable.rows[y].cells[0]) , 10 );
				   }	
			   }            	
		   }
	   }        
   } 
 
   aMat = aMatAux.split("|");
   //--------------------------------------------------------------------
   // Monta envio para processamento
   //--------------------------------------------------------------------
   for (var i = 0; i < aMat.length; i++) {
	   e = eval("o" + aMat[i]);
	   oTable = e.getObjCols();
	   
	   fMontMatGerInt('A', aMat[i]);
	   
	   aMatCampAux = aMatCap.split("|");
	   for (var y = 0; y < oTable.rows.length; y++) {
		   nf = 0;                  
		   celula = oTable.rows[y].cells[4];
		   if ((!lProrroga) || (lProrroga && ( isEmpty(getTC(celula))  ))){
			   
			   nSeq = nSeq + 1;
							   
			   cStringEnvTab += "cSeq@" + parseInt( nSeq , 10 ) + "$";
			   
			   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {
			   
				   cCampo = aMatCampAux[x - 2].split("$")[1];
				   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
					   celula = oTable.rows[y].cells[x + 1 - nf];
					   
					   if (typeof celula.value == 'undefined' || celula.value == '')
							conteudo = getTC(celula);
					   else conteudo = celula.value;	
					   
					   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
				   }
				   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;
			   }      
			   cStringEnvTab += "|";
		   }
	   }
   }           
   if (cStringEnvTab == ''){
	   alert("Informe pelo menos um serviço para a " + cMsg);
	   return;
   }
   window.frames[0].document.getElementById("cMatTabES").value = cStringEnvTab + "|";
   //--------------------------------------------------------------------
   // Trata Campos														  
   //--------------------------------------------------------------------                   
   setDisable("cCbosSol",false);
   setDisable("cCnpjSolT",false);
   setDisable("cNomeSolT",false);
   setDisable("cCnpjCpfSol",false);
   setDisable("cNomeRdaSol",false);
   
   setDisable("bIncTabProSer",true);
   setDisable("bconfirma",true);
   setDisable("bimprimir",true);
   setDisable("bAnexoDoc",true);
   setDisable("bcomplemento",false);
   //--------------------------------------------------------------------
   // Metodo de envio de formulario pelo ajax								  
   //--------------------------------------------------------------------
   Ajax.send(formulario, { 
		   callback: CarregaProcFormInt,
		   error: ExibeErro 
   });
   document.forms[0].action = "";

}

function confirmaHon(cTipo){
   
   var cRecno= "";
   var aSequenDel = new Array();
   var cTipoGuia = "";

   closeModalBS();
   
   if($("#cTp").val() != undefined){
	   cTipoGuia = $("#cTp").val();
   }else{
	   cTipoGuia = window.frames[0].document.getElementById("cTp").value;
   }

   if (cTipoGuia == "5") {
	   lGuiResInt = true;
   }
   
   if( isDitacaoOffline() && (isAlteraGuiaAut() || (!isAlteraGuiaAut() && cTipoGuia == "5")) ){
	 
	   //Jquery não considera esse campo como alterado, sempre irá alterar.
	   if($("#cRecnoBD5").val() != undefined){
		   cRecno = $("#cRecnoBD5").val();
	   }else{
		   cRecno = window.frames[0].document.getElementById("cRecnoBD5").value;
	   }
	   
	   var cCabecalhoEdited = "";
	   var objLocalHon = window.frames[0].oGuiaOff;
	   
	   //---------------------------------------------------------------------------------
	   //									CABECALHO
	   //---------------------------------------------------------------------------------
	   //Alteracao off-line, recuperar os campos do cabecalho contidos no objeto oGuiaOff.
	   //Campos a serem alterados sao os campos cujo conteudo default nao e' igual ao actualvalue, isto e', houve mudanca.
	   for (var c in objLocalHon.cabecalho){
		   if(objLocalHon.cabecalho[c].defaultValue != objLocalHon.cabecalho[c].actualValue){
			   cCabecalhoEdited += c + "$" + objLocalHon.cabecalho[c].actualValue + ";";
		   }
	   }

	   //---------------------------------------------------------------------------------
	   //							PROCEDIMENTOS ADICIONADOS
	   //---------------------------------------------------------------------------------
	   //Alterações existentes na grid de procedimento da guia honorario.
	   //Itens adicionados são aqueles que tem a propriedade LNEWITE verdadeira e LDELITE falsa pois se o usuário incluiu e depois deletou o procedimento
	   //ainda não foi pra base então desconsidero
	   var addedItems = getObjects(objLocalHon.procedimentos, "lNewIte", true);
	   addedItems = getObjects(addedItems, "lDelIte", false);
	   
	   var strAdded = "";
	   var i = 0;

	   //Para os itens adicionados preciso enviar todos os atributos para o servidor.
	   for(i=0; i< addedItems.length; i++){		
		   for(var key in addedItems[i]){
				   switch(key) {
					   case "lNewIte":
					   case "lDelIte":
					   case "sequen":
						   strAdded += key+"="+addedItems[i][key]+"$";
						   break;
					   default:
						   strAdded += key+"="+addedItems[i][key].actualValue+"$";
				   }
		   }
		   strAdded = strAdded.slice(0, -1);
		   strAdded += i == (addedItems.length - 1) ? "" : "&";
	   }
	   
	   //---------------------------------------------------------------------------------
	   //							PROCEDIMENTOS EXCLUIDOS
	   //---------------------------------------------------------------------------------
	   //Itens excluídos são os que vieram da base, ou seja LNEWITE falso e LDELITE verdadeira
	   var deletedItems = getObjects(objLocalHon.procedimentos, "lNewIte", false);
	   deletedItems = getObjects(deletedItems, "lDelIte", true);
	   
	   var strDeleted = "";
	   
	   //Para os itens excluidos preciso enviar apenas os atributos chave para localizar na BD6.
	   for(i=0; i<deletedItems.length;i++){
			   strDeleted += "cCodPadKey="	+deletedItems[i].cCodPad.defaultValue;
			   strDeleted += "$cCodProKey="	+deletedItems[i].cCodPro.defaultValue;
			   strDeleted += "$cSeqMov="		+deletedItems[i].cSeqMov.defaultValue;
			   strDeleted += i == (deletedItems.length - 1) ? "" : "&";
	   }
	   
	   //---------------------------------------------------------------------------------
	   //							PROCEDIMENTOS ALTERADOS
	   //---------------------------------------------------------------------------------
	   //Itens editados são todos os itens que vieram da base, ou seja LNEWITE falso e LDELITE falso e que possuem algum atributo modificado
	   //defaultValue diferente de actualValue
	   var editedItems = getObjects(objLocalHon.procedimentos, "lNewIte", false);
	   editedItems = getObjects(editedItems, "lDelIte", false);
	   
	   var strEdited = "";
	   var edited = false;
	   var cCodPadEdited = false;
	   var cCodProEdited = false;
	   var cIteProp = "";
	   var lNvlrApAl		= false;
	   var lRedAcrAl		= false;
	   var lQtdSol			= false;

	   //Para os itens alterados, preciso enviar os atributos chave para localizar na BD6 e mais os atributos modificados (defaultValue diferente de actualValue)
	   for(i=0; i<editedItems.length;i++){
		   edited = false;
		   cIteProp = "";
		   cCodPadEdited = false;
		   cCodProEdited = false;
		   nSequen =  strZero1(editedItems[i].sequen, 3) ;
	   
		   var oExecs = $.grep( objLocalHon.executantes, function( n, i ) {
				   return n.nSeqRef.actualValue == nSequen && ((cTipoGuia == "6") ? !n.lDelIte : true);
		   });
					   
		   var lExec = $.grep( oExecs, function( n, i ) {
				   return n.lNewIte && !n.lDelIte;
		   }).length > 0;
		   
		   if(!lExec){
			   lExec = $.grep( oExecs, function( n, i ) {
				   return !n.lNewIte && n.lDelIte;
			   }).length > 0;
		   }
		   
		   if(!lExec){
			   lExec = $.grep( oExecs, function( n, i ) { 
				   var newObj = [];
				   for(var key in n){
					   if(n[key].defaultValue != n[key].actualValue){
						   newObj.push(n);
						   break;
					   }
				   }
				   return newObj.length > 0;
			   }).length > 0;
		   }
		   
		   //verifico se o codigo da tabela ou do procedimento foi alterado, pois vou ter que enviar todos os campos para o servidor para inserir uma nova BD6
		   if(editedItems[i].cCodPro.defaultValue != editedItems[i].cCodPro.actualValue ||
			  editedItems[i].cCodPad.defaultValue != editedItems[i].cCodPad.actualValue){
			  edited = true;
			   for(var key in editedItems[i]){
				   switch(key) {
					   case "lNewIte":
					   case "lDelIte":
					   case "sequen":
						   cIteProp += key+"="+editedItems[i][key]+"$";
						   break;
					   case "cSeqMov":
						   break;
					   default:
						   strEdited += key+"="+editedItems[i][key].actualValue+"$";
				   }
			   }
			   
		   }else{		
			   for(var key in editedItems[i]){
				   if(key == "lNewIte" || key ==  "lDelIte" || key ==  "sequen" || key ==  "sequenBD6"){
					   cIteProp += key+"="+editedItems[i][key]+"$";
				   }else if(editedItems[i][key].actualValue.toUpperCase() != editedItems[i][key].defaultValue.toUpperCase()){
						   edited = true;
							   
							   //garanto sempre a tabela e o procedimento na string quando o procedimento for alterado
							   //pois preciso fazer o de/para no webservice
							   if(key == "cCodPro" && !cCodPadEdited){
								   strEdited += "cCodPad="+editedItems[i]["cCodPad"].actualValue+"$";
								   cCodPadEdited = true;
							   }

							   if (key == "nVlrApr" ) {
								   lNvlrApAl = true;
							   }
							   
							   if (key == "nRedAcre" ) {
								   lRedAcrAl = true;
							   }
							   
							   if (key == "nQtdSol" ) {
								   lQtdSol = true;
							   }
							   
							   //garanto que o cCodPadSExe não será adicionado duas vezes
							   if( !(key == "cCodPad" && cCodPadEdited) ){
								   strEdited += key+"="+editedItems[i][key].actualValue+"$";
							   }
				   }
			   }
		   }
		   
		   //A chave nem sempre pode ter sido alterada, e não vai entrar no if acima
		   //para garantir que ela sempre estará presente na string, verifico se foi editada alguma propriedade e adiciono a chave a string
		   if(edited || lExec){
			   strEdited +=  "cCodPadKey="  	+editedItems[i].cCodPad.defaultValue+"$";
			   strEdited +=  "cCodProKey="		+editedItems[i].cCodPro.defaultValue+"$";
			   strEdited +=  "cSeqMov="		    +editedItems[i].cSeqMov.defaultValue+"$";
			   //Se alterado valor unitário ou red/acr ou qtd, devo obrigatoriamente passar esses parâmetros, para cálculo do valor apresentado e valori.
			   if (lNvlrApAl || lRedAcrAl || lQtdSol) {
				   if (strEdited.indexOf('nVlrApr') == -1) {
					   strEdited += "nVlrApr=" + editedItems[i].nVlrApr.actualValue + "$";
			   }
				   if (strEdited.indexOf('nRedAcre') == -1) {
					   strEdited += "nRedAcre=" + editedItems[i].nRedAcre.actualValue + "$";
			   }
				   if (strEdited.indexOf('nQtdSol') == -1) {
					   strEdited += "nQtdSol=" + editedItems[i].nQtdSol.actualValue + "$";
				   }
			   }
			   strEdited += cIteProp;
			   strEdited = strEdited.slice(0, -1);
		   }
		   
		   strEdited += i == (editedItems.length - 1) ? "" : "&";
		   
	   }
	   
	   //---------------------------------------------------------------------------------
	   //							EXECUTANTES ALTERADOS
	   //---------------------------------------------------------------------------------
	   //Sempre que um atributo da BD7 for alterado, o sistema irá excluir e gravar de novo para não impactar nos cálculos
	   var editedExec = getObjects(objLocalHon.executantes, "lNewIte", false);
	   editedExec = getObjects(editedExec, "lDelIte", false);	
	   var lenEditedExec = editedExec.length;

	   for(i=0; i<lenEditedExec;i++){
	   
		   //verifico se algum atributo chave foi alterado, pois vou ter que enviar todos os campos para o servidor para inserir uma nova BD7
		   if(editedExec[i].nSeqRef.defaultValue != editedExec[i].nSeqRef.actualValue ||
			  editedExec[i].cGraPartExe.defaultValue != editedExec[i].cGraPartExe.actualValue ||
			  editedExec[i].cProExe.defaultValue != editedExec[i].cProExe.actualValue ||
			  editedExec[i].cCbosExe.defaultValue != editedExec[i].cCbosExe.actualValue){ //cNomExe pq tem o codigo do profissional separado por asterisco
							
			   // Copia do objeto
			   var newObject = jQuery.extend({}, editedExec[i]);

			   // Clone do objeto
			   var newObject = jQuery.extend(true, {}, editedExec[i]);
			  
			  newObject.lNewIte = true;
			  newObject.lDelIte = false;
			  
			  editedExec[i].lDelIte = true;
			  editedExec[i].seqExe = "";
			  
			  objLocalHon.executantes.push(newObject);
			  
			  //ordenando para colocar os itens deletados por ultimo
			  objLocalHon.executantes = objLocalHon.executantes.sort(function(a,b) {
						   return ( (!a.lDelIte && b.lDelIte) ? -1 : (a.lDelIte && !b.lDelIte) ? 1 : 0 );
			   });
			   
			   //ordenando para colocar os seqExe em ordem crescente
			   objLocalHon.executantes = objLocalHon.executantes.sort(function(a,b) {
						   return ( (!a.seqExe < b.seqExe) ? -1 : (a.seqExe > !b.seqExe) ? 1 : 0 );
			   });
									   
		   }
					   
	   }
	   
	   //---------------------------------------------------------------------------------
	   //							EXECUTANTES ADICIONADOS
	   //---------------------------------------------------------------------------------
	   //Alterações existentes na grid de procedimento da guia honorario.
	   //Itens adicionados são aqueles que tem a propriedade LNEWITE verdadeira e LDELITE falsa pois se o usuário incluiu e depois deletou o procedimento
	   //ainda não foi pra base então desconsidero
	   var addedExec = getObjects(objLocalHon.executantes, "lNewIte", true);
	   addedExec = getObjects(addedExec, "lDelIte", false);
	   
	   var strAddedExec = "";
	   var i = 0;

	   //Para os itens adicionados preciso enviar todos os atributos para o servidor.
	   for(i=0; i< addedExec.length; i++){	
		   //verifico se o procedimento vinculado não está deletado
			   for(var key in addedExec[i]){
					   switch(key) {
						   case "lNewIte":
						   case "lDelIte":
						   case "seqExe":
							   strAddedExec += key+"="+addedExec[i][key]+"$";
							   break;
						   default:
							   strAddedExec += key+"="+addedExec[i][key].actualValue+"$";
					   }
			   }
			   
			   strAddedExec = strAddedExec.slice(0, -1);			
			   strAddedExec += i == (addedExec.length - 1) ? "" : "&";				
		   
		   }
		   
	   
	   //---------------------------------------------------------------------------------
	   //							EXECUTANTES EXCLUIDOS
	   //---------------------------------------------------------------------------------
	   //Itens excluídos são os que vieram da base, ou seja LNEWITE falso e LDELITE verdadeira
	   var deletedExec = getObjects(objLocalHon.executantes, "lNewIte", false);
	   deletedExec = getObjects(deletedExec, "lDelIte", true);
	   
	   var strDeletedExec = "";
	   //Para os itens excluidos preciso enviar apenas os atributos chave para localizar na BD7.
	   for(i=0; i<deletedExec.length;i++){
			   strDeletedExec += "nSeqRef="	+deletedExec[i].nSeqRef.defaultValue;
			   strDeletedExec += "$cGraPartExe="	+deletedExec[i].cGraPartExe.defaultValue;
			   strDeletedExec += "$cProExe="+deletedExec[i].cProExe.defaultValue;
			   strDeletedExec += i == (deletedExec.length - 1) ? "" : "&";
	   }
	   
	   //---------------------------------------------------------------------------------
	   //							CRIACAO DE HIDDENS
	   // Crio os hidden no formulario para enviar via POST para o servidor 
	   //---------------------------------------------------------------------------------		
	   var dDtCorrigida = fValidaMenDtAtd("TabExeSer", "0");
	   //Passo a menor data do procedimento realizado, para atualizar o campo BD5_DATPRO
	   cCabecalhoEdited = cCabecalhoEdited + 'dDataCorDig$' + dDtCorrigida + ";"
	   
	   var cHiddenCabecalhoAlterado	= document.createElement('input');
	   cHiddenCabecalhoAlterado.id	 	= 'cCabecalhoEdited';
	   cHiddenCabecalhoAlterado.type 	= 'hidden';
	   cHiddenCabecalhoAlterado.value 	= cCabecalhoEdited;
	   window.frames[0].document.forms[0].appendChild(cHiddenCabecalhoAlterado);		
	   
	   addedItems	= document.createElement('input');
	   addedItems.id	 	= 'cAddedItems';
	   addedItems.type 	= 'hidden';
	   addedItems.value 	= strAdded;
	   window.frames[0].document.forms[0].appendChild(addedItems);
	   
	   deletedItems	= document.createElement('input');
	   deletedItems.id	 	= 'cDeletedItems';
	   deletedItems.type 	= 'hidden';
	   deletedItems.value 	= strDeleted;
	   window.frames[0].document.forms[0].appendChild(deletedItems);
	   
	   editedItems	= document.createElement('input');
	   editedItems.id	 	= 'cEditedItems';
	   editedItems.type 	= 'hidden';
	   editedItems.value 	= strEdited;
	   window.frames[0].document.forms[0].appendChild(editedItems);
	   
	   addedExec			= document.createElement('input');
	   addedExec.id		= 'cAddedExec';
	   addedExec.type 	= 'hidden';
	   addedExec.value = strAddedExec;
	   window.frames[0].document.forms[0].appendChild(addedExec);
	   
	   deletedExec				= document.createElement('input');
	   deletedExec.id	 		= 'cDeletedExec';
	   deletedExec.type 	= 'hidden';
	   deletedExec.value 	= strDeletedExec;
	   window.frames[0].document.forms[0].appendChild(deletedExec);
	   
	   //Atribuo a action ao form - alteração é tratada por outra web function
	   window.frames[0].document.forms[0].action = "W_PPLGRHON.APW?cRecno="+cRecno+"&cTipoOrigem=digitacao&cTipoConfirm="+cTipo+"&cTipGui="+window.frames[0].document.forms[0].cTp.value+ "&cNumGuiRes="+window.frames[0].document.forms[0].cNumGuiRes.value + "&cNumGuiRef="+window.frames[0].document.forms[0].cNumGuiRef.value;	   
	   
	   Ajax.send(window.frames[0].document.forms[0], {
		   callback: carregaResp,
		   error: ExibeErro
	   });	   
	   
   }else{
	   
	   var dDtCorrigida = fValidaMenDtAtd("TabExeSer", "1");
	   
	   window.frames[0].document.forms[0].action = "W_PPLPROCGUI.APW?cTipoOrigem=digitacao&cTipoConfirm="+cTipo;		               


	   Ajax.send(window.frames[0].document.forms[0], {
			   callback: CarregaProcFormHon,
			   error: ExibeErro
	   });
   }
	   
	  document.forms[0].action = "";
}

//Verificação se trata das funçõess de alteração de alguns campos da guia após Autorização: funciona apenas para //Consulta e SADT
function isAlteraGuiaAut(){
var cRecno = $("#cRecnoBD5").val();
   
   if (isDitacaoOffline()){
	   if ( $("#cRecnoBD5").val() != undefined && ($("#cRecnoBD5").val() != "") && ($("#cRecnoBD5").val() != "0") ){
		   return true;
	   }else{
		   if(window.frames[0] != undefined){
			  if (window.frames[0].document.getElementById("cRecnoBD5") != undefined  && window.frames[0].document.getElementById("cRecnoBD5").value != "" &&  window.frames[0].document.getElementById("cRecnoBD5").value != "0"){
				 return true;
			  }else{
			   return false;
			   }
		   }else{
					   return false;
	   }
	   }
   }else{
	   if ( $("#cAltCmpG").val() != undefined && ($("#cAltCmpG").val().indexOf('|') != -1) ){
		   return true;
	   }else{
		   if(window.frames[0] != undefined){
			   if (window.frames[0].document.getElementById("cAltCmpG") != undefined  && (window.frames[0].document.getElementById("cAltCmpG").value).indexOf('|') != -1){
				  return true;
			   }else{
			   return false;
			   }
		   }else
			  return false;
	   }
   }
}

//Executa funções iniciais no carregamento da guia odontológica
function OdontoLoad(){
   cVazio = "";
   cVirgula = ",";

   //Disabled
   setDisable("bASolSer",true);
   setDisable("bimprimir",true);
   setDisable("bAnexoDoc",true);

   //--------------------------------------------------------------------
   //Carrega dados da rda
   //--------------------------------------------------------------------
   fRdaOdonto(document.getElementById("cRda").value,document.getElementById("cCodLoc").value);

   //--------------------------------------------------------------------
   //Alteração off-line
   //--------------------------------------------------------------------
   if(isDitacaoOffline()) {
	   document.querySelector("#bAnexoDoc").style.display = 'none';		
	   document.getElementById('dDtExe').readOnly = false;
   }
   if(isDitacaoOffline() && $("#cAltCmpG").val() != undefined && $("#cAltCmpG").val().indexOf('|') != -1){
	   
	   Ajax.open("W_PPLCHAALT.APW?cRecno=" + $("#cRecnoBD5").val() + "&cTipGui=4"  , { callback : fRespostaOdonto, error : exibeErro });
   }
   else if ($("#cAltCmpG").val() != undefined && $("#cAltCmpG").val().indexOf('|') != -1)	{
	   aResult = $("#cAltCmpG").val().split("|");
   }else{
	   //--------------------------------------------------------------------
	   // Carrega eventos dos campos
	   //--------------------------------------------------------------------
	   // var oForm = new xform( document.forms[0] );

	   // oForm.add( document.forms[0].cCodPadSE		,"numero", false, true );
	   // oForm.add( document.forms[0].cCodProSE		,"numero", false, true );
	   // oForm.add( document.forms[0].cQtdSE			,"numero", false, true );
   }

   alterarCamposGuias();

   if (document.getElementById(cBtnExec) == null){
	   cBtnExec = 'BcNumAut';
   }
}

function fRdaOdonto(cRda, cCodLoc) {
   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, {
	   callback: CarregaRdaOdonto,
	   error: ExibeErro
   });
}

//Pega o retorno da Consulta
function fRespostaOdonto(v) {	
   //aMatCabIte -> Tem os dados do Cabecalho e detalhe. 

   var objJson = '{ ';	
   var objSubJsonCabec = "";
   //CbosSol não entra mais no cabeçalho de alteração, pois no atendimento padrão, ao executar a guia, o sistema traz apenas a especialdiade lançada na liberação, mesmo que tenha outras especialdiades. Logo, o off-line vai manter isso. 
   //aCamposCabec = ["cAtendRN","cProSol","dDtEmissao","cCbosSol","cProExe","cCbosExe","cTpAto","cTpFat","cObs"];
   aCamposCabec = ["cAtendRN","cProSol","dDtEmissao","cProExe","cCbosExe","cTpAto","cTpFat","cObs"];
   var objSubJsonProc = "";
   var nQtyCampoCabec = 0;
   var aJsonCamposCabec = new Array();

   var aMatCabIte 	= v.split("<"); //Separa campos do cabeçalho
   var aMatCab 	= aMatCabIte[0].split("|"); //Separa cada um dos campos com a sintaxe 'campo!valor'
   var aMatIte 	= aMatCabIte[1].split("~"); //Separa registros do grid
   var cTexto		= "";
   cCampoRefL 		= "";

   if (isDitacaoOffline() && isAlteraGuiaAut()) {
	   setDisable(cBtnExec,true);
	   setDisable("cNumAut",true);
	   document.querySelector("#"+cBtnExec).style.opacity = 0; //Transparente
   }
   //--------------------------------------------------------------------
   // Verifico se a estrutura dos itens foram enviadas					  
   //--------------------------------------------------------------------
   if (typeof aMatCabIte[1] == "undefined") {
	   alert("Estrutura indefinida");
	   return;
   }

   //--------------------------------------------------------------------
   // Cabecalho 		  
   //--------------------------------------------------------------------
   for (var i = 0; i < (aMatCab.length - 1); i++) {
	   var aCamVal = aMatCab[i].split("!");

	   //--------------------------------------------------------------------
	   // Somente se foi passado o nome do campo								  
	   //--------------------------------------------------------------------
	   if (aCamVal[0] != "") {
		   var cCampo = document.getElementById(aCamVal[0]);
		   if (cCampo != null) {
			   if(cCampo.tagName == "SELECT"){
				   if (cCampo.id == "cCbosSol") {
					   setTC(document.getElementById("cCbosSol"),"");
					   var aIten = aCamVal[1].split("$");
					   cCampo.options[0] = new Option(aIten[1], aIten[0]);
				   } else if (cCampo.id == "cCbosExe") {
								   //Carregar o combo Cbos executante corretamente
								   fProfSauOdonto (document.getElementById("cProExe").value, "E");
					   aCodEspOdo = [cCampo, aCamVal[1]];
				   } else {
					   setSelectedValue(cCampo, aCamVal[1]);
				   }
			   }else{
				   cCampo.value = aCamVal[1];
			   }

			   //Alimenta campos do cabecalho no objeto Json, para incluir novos campos, alterar o array aCamposCabec.
			   //Exemplo campo cabecalho json: "cRegAns":{"defaultValue": "1", "actualValue": "2"},
			   if(aCamposCabec.indexOf(aCamVal[0]) > -1){
				   aJsonCamposCabec.push('"' + aCamVal[0] + '"' + ':{ "defaultValue" : ' + '"' + aCamVal[1].trim() + '"' + ', "actualValue":' + '"' + aCamVal[1].trim() + '"}');
			   }
		   }			
	   }
   }
   
   var aMatIteG = new Array();
   
   //--------------------------------------------------------------------
   // Monta o array com os itens do detalhe da solicitação de procedimento
   // Cada item do aMatItem é um registro da grid
   //--------------------------------------------------------------------
   var cont = 1;

	for (var i = 0; i < aMatIte.length; i++){
	   //--------------------------------------------------------------------
	   // Matriz com os campos e valores SERVICO								  
	   //--------------------------------------------------------------------
	   if (aMatIte[i] != ""){
		   //--------------------------------------------------------------------
		   //?Aprimeira posicao da matriz aMatval e o tipo de servico a segunda      		
		   //?e se vai ser exibido ou nao da terceira em diante contem valores dos campos	
		   //--------------------------------------------------------------------
		   var aMatVal = aMatIte[i].split("@");
		   
		   var aAux 
		   objSubJsonProc += "{";
		   for(var j = 0; j < aMatVal.length; j++){
			   aAux = aMatVal[j].split("!");
			   objSubJsonProc += '"' + aAux[0] + '"' + ':{ "defaultValue" : ' + '"' + aAux[1].trim() + '"' + ', "actualValue":' + '"' + aAux[1].trim() + '"}';
			   objSubJsonProc += ","
		   }
		   
		   objSubJsonProc +=  '"sequen":' + '"' + cont.toString() + '",';
		   objSubJsonProc +=  '"lNewIte":false,';
		   objSubJsonProc +=  '"lDelIte":false}';
		   objSubJsonProc +=  i < (aMatIte.length - 2) ? "," : ""
		   cont++;
		   //--------------------------------------------------------------------
		   //?A segunda posicao [1] retorna se e possivel exibir para uma rda o procedimento  
		   //--------------------------------------------------------------------
		   var cMostraSer = aMatVal[1].split("!")[1];
		   
			 //--------------------------------------------------------------------
			 //aMatIteG
		   //Estrutura: Tipo - Array, Conte?o - Linha do detalhe
		   //	Estrutura: Tipo - String, Conte?o - Coluna do detalhe: Variavel_Protheus!Valor 
		   //	***N? necess?iamente a coluna existe no grid. Isso ?validado posteriormente
			 //--------------------------------------------------------------------
		   aMatIteG.push(aMatVal);
		   }
	   }
   
   //-----------------------------------------------------------------------
   //Concatena objetos JSON
   //-----------------------------------------------------------------------
   for (var n = 0; n < aJsonCamposCabec.length; n++) {
	   objSubJsonCabec += aJsonCamposCabec[n];

	   //Se não for o último índice do array, adiciona vírgula no json 
	   if (n != aJsonCamposCabec.length - 1)
		   objSubJsonCabec += ",";
   }

   objJson += ' "cabecalho":{' + objSubJsonCabec + '}, ';

   //Concatena informações dos procedimentos no objeto JSON
   objJson += ' "procedimentos":[' + objSubJsonProc + ']}';
   //-----------------------------------------------------------------------
   // Crio um objeto com escopo global que contém os itens das outras despesas
   //-----------------------------------------------------------------------
   oGuiaOdonto = JSON.parse(objJson);

   //--------------------------------------------------------------------
   //Chama a função que carrega os grids.
   //Pede para a função preencher o grid de proc. Sol. "TabSolSer" e copiar os itens pro grid proc. Exec. "TabExeSer"
   //Pode ser que ainda não existam itens para as outras despesas
   //--------------------------------------------------------------------
   if(aMatIteG.length > 0){
	   fCarregaTabelaAltOdonto('TabOdonto$0',aMatIteG,cMostraSer);
   }

   setDisable("bconfirma",false);
   setDisable("bcomplemento",true);
   setDisable("bimprimir",true);
   setDisable("bAnexoDoc",true);

   //----------------------------------------------------------
   //Alterar onchange dos campos editaveis da guia odontologica
   //----------------------------------------------------------
   _$Forminputs = $('form :input:not([type=submit][type=button])');

   _$Forminputs.on('blur', function(e) {
	   for (var i = 0; i < _$Forminputs.length; i++) {
		   if(oGuiaOdonto.cabecalho[$(_$Forminputs[i]).prop('id')] != undefined){
			   if (oGuiaOdonto.cabecalho[$(_$Forminputs[i]).prop('id')].defaultValue != $(_$Forminputs[i]).val()){
				   //Se o valor atual for diferente do default, atribui o valor do campo ao atual.
				   if($(_$Forminputs[i]).prop('id') == "cCbosSol" || $(_$Forminputs[i]).prop('id') == "cCbosExe"){
					   oGuiaOdonto.cabecalho[$(_$Forminputs[i]).prop('id')].actualValue = $(_$Forminputs[i]).val().substring(0,3);
				   }else{
				   oGuiaOdonto.cabecalho[$(_$Forminputs[i]).prop('id')].actualValue = $(_$Forminputs[i]).val();
			   }
		   }
	   }
	   }
   });
}


// Monta campos conforme processamento da rdas	
function CarregaRdaOdonto(v) {
   var aResult = v.split("|");
   var aResuEsp = (aResult[24].substring(1)).split("~");

   //Local de atendimento
   document.getElementById("cCodLoc").value = aResult[22];

   //Dados do Contratado
   document.getElementById("cCnpjCpf").value	= aResult[2];
   document.getElementById("cNomeRda").value 	= aResult[3];
   document.getElementById("cNumCrRda").value 	= aResult[12];
   document.getElementById("cEstSigRda").value	= aResult[13];
   document.getElementById("cCnesExeB").value	= aResult[4];
   document.getElementById("cTpPe").value 		= aResult[14];

   //Cbos do Executante
   setTC(document.getElementById("cCbosExe"),"");
   var e = document.getElementById("cCbosExe");
   for (var i = 0; i < aResuEsp.length; i++) {
	   var aIten = aResuEsp[i].split("$");
	   e.options[i] = new Option(aIten[1], aIten[0]);
   }

   //Habilita dente e face
   setDisable("cDentRegSE",false);
   setDisable("cFaceSE",false);

   //Monta especialidades
   setTC(document.getElementById("cCbosSol"),"");
   var e = document.getElementById("cCbosSol");
   for (var i = 0; i < aResuEsp.length; i++) {
	   var aIten = aResuEsp[i].split("$");
	   e.options[i] = new Option(aIten[1], aIten[0]);
   }

   //Dados da Autorizacao de Solicitacao
   document.getElementById("dDtAut").value		= "";
   document.getElementById("cSenha").value		= "";
   document.getElementById("dDtValid").value	= "";

   //Dados do Solicitante
   document.getElementById("cRegAns").value	= aResult[1];

   //Se e fisica ou juridica
   document.getElementById("cNomeSol").value 	= aResult[19];
   document.getElementById("cNumCrSol").value 	= aResult[17];
   document.getElementById("cEstSigSol").value	= aResult[18];

   //Dados do Executante Contratado
   document.getElementById("cCnpjCpfExe").value	= document.getElementById("cCnpjCpf").value;
   document.getElementById("cNomeRdaExe").value 	= document.getElementById("cNomeRda").value;
   document.getElementById("cNumCrRdaExe").value  	= document.getElementById("cNumCrRda").value;
   document.getElementById("cEstSigRdaExe").value 	= document.getElementById("cEstSigRda").value;
   document.getElementById("cCnesExe").value		= document.getElementById("cCnesExeB").value;
}

function fRespostaHon(v) {

   var cDataEmissao = "";

   var aGuiaCampos = [];
   var aCampos = [];
   var aGrids = [];
   var aValorCampo = [];
   var aGridProcedimentos = [];
   var aGridExecutantes = [];
   var cSeqRefAtu = "";
   var cBkpSeqMov = "";
   var aChavExec	= [];
   var aChExect	= [];
   
   var objJson = '{ ';	
   var objSubJsonCabec = "";
   var objSubJsonProc = "";
   var objSubJsonExec = "";
   var aJsonCamposCabec = new Array();

   aGuiaCampos	= v.split("<");
   aCampos = aGuiaCampos[0].split("|");

   
   if(aGuiaCampos[1] != undefined && aGuiaCampos[1].indexOf('-&-') != -1) {
	   aChavExec = aGuiaCampos[1].split("-&-");
	   aGuiaCampos[1] = aChavExec[0];
	   document.getElementById("cRelExecCar").value = aChavExec[1];
   }
   
   //Indica que tem grid
   if(aGuiaCampos[1] != undefined && aGuiaCampos[1].indexOf('|-|') != -1) {
	   aGrids = aGuiaCampos[1].split("|-|");
   }

   if(aGrids[0] != undefined){
	   aGridProcedimentos = aGrids[0].split('~');
   }
   
   if(aGrids.length > 1){
	   aGridExecutantes = aGrids[1].split('$');
   }

   //Verifico se a estrutura dos campos de cabeçalho foi enviada
   if (typeof aGridProcedimentos[0] == "undefined") {
	   alert("Estrutura de grid indefinida");
	   return;
   }

   //Cabecalho e dados de beneficiario, contratado, contratado executante e datas de faturamento
   for (var i = 0; i < (aCampos.length - 1); i++) {
	   aValorCampo = aCampos[i].split("!");

		if (aValorCampo[0] != "") {
		   var cCampo = document.getElementById(aValorCampo[0]);
		   if(cCampo != null){
			   cCampo.value = aValorCampo[1]; //Se existe valor para o campo, atribui ao conteúdo do mesmo
			   aJsonCamposCabec.push('"' + cCampo.id + '"' + ':{ "defaultValue" : ' + '"' + aValorCampo[1].trim() + '"' + ', "actualValue":' + '"' + aValorCampo[1].trim() + '"}');
		   }
		   if(aValorCampo[0] == "cNumMaxAux") {
			   cCampo = document.getElementById("cNumMaxAux");
			   cCampo.value = aValorCampo[1].trim();
		   }
	   }
   }
   
   //-----------------------------------------------------------------------
   //Concatena objetos JSON
   //-----------------------------------------------------------------------
   for (var n = 0; n < aJsonCamposCabec.length; n++) {
		   objSubJsonCabec += aJsonCamposCabec[n];

		   //Se não for o último índice do array, adiciona vírgula no json 
		   if (n != aJsonCamposCabec.length - 1)
			   objSubJsonCabec += ",";
	   }

   objSubJsonCabec = ' {"cabecalho":{' + objSubJsonCabec + '}} ';
   objSubJsonCabec = JSON.parse(objSubJsonCabec);

   //Abre os grupos para evitar erro no carregamento dos grids.
   var aMatIteG = new Array();
   var aMatProfG = new Array();

   //Monta o array com os itens de cada grid
   var cont = 1;
   for (var i = 0; i < aGridProcedimentos.length; i++) {

	   //Pra cada linha da grid, faz leitura de cada campo e adiciona na matriz que irá para a grid
	   // Matriz com os campos e valores
	   if (aGridProcedimentos[i] != "") {
		   //--------------------------------------------------------------------
		   //?Aprimeira posicao da matriz aMatval e o tipo de servico a segunda
		   //?e se vai ser exibido ou nao da terceira em diante contem valores dos campos
		   //--------------------------------------------------------------------
		   var aCampoProcedimento = aGridProcedimentos[i].split("@");
		   
		   var aAux 
		   objSubJsonProc += "{";
		   for(var j = 0; j < aCampoProcedimento.length; j++){
			   aAux = aCampoProcedimento[j].split("!");
			   objSubJsonProc += '"' + aAux[0] + '"' + ':{ "defaultValue" : ' + '"' + aAux[1].trim() + '"' + ', "actualValue":' + '"' + aAux[1].trim() + '"}';
			   if (aAux[0].trim() == 'cSeqMov') {
				   cBkpSeqMov = aAux[1].trim();
			   }	
			   objSubJsonProc += ","
		   }
		   
		   objSubJsonProc +=  '"sequen":' + '"' + cont.toString() + '",';
		   objSubJsonProc +=  '"sequenBD6":' + '"' + cBkpSeqMov + '",';
		   objSubJsonProc +=  '"lNewIte":false,';
		   objSubJsonProc +=  '"lDelIte":false}';
		   objSubJsonProc +=  i < (aGridProcedimentos.length - 2) ? "," : ""
		   cont++;
		   
		   //--------------------------------------------------------------------
		   //?A segunda posicao [1] retorna se e possivel exibir para uma rda o procedimento
		   //--------------------------------------------------------------------
		   var cMostraSer = aCampoProcedimento[1].split("!")[1];

			 //--------------------------------------------------------------------
			 //aMatIteG
		   //Estrutura: Tipo - Array, Conte?o - Linha do detalhe
		   //	Estrutura: Tipo - String, Conte?o - Coluna do detalhe: Variavel_Protheus!Valor
		   //	***N? necess?iamente a coluna existe no grid. Isso ?validado posteriormente
			 //--------------------------------------------------------------------
		  aMatIteG.push(aCampoProcedimento);
	   }
   }
   
   objSubJsonProc = ' {"procedimentos":[' + objSubJsonProc + ']}';
   objSubJsonProc = JSON.parse(objSubJsonProc);

   //Profissionais executantes
   cont = 1;
   for (var i = 0; i < aGridExecutantes.length; i++) {
	   //--------------------------------------------------------------------
	   // Matriz com os campos e valores SERVICO
	   //--------------------------------------------------------------------
	   if (aGridExecutantes[i] != "") {
		   //--------------------------------------------------------------------
		   //A primeira posicao da matriz aMatval e o tipo de servico a segunda
		   //e se vai ser exibido ou nao da terceira em diante contem valores dos campos
		   //--------------------------------------------------------------------
		   var aCampoExecutante = aGridExecutantes[i].split("@");
					   
		   var aAux 
		   objSubJsonExec += "{";
		   for(var j = 0; j < aCampoExecutante.length; j++){
			   aAux = aCampoExecutante[j].split("!");
			   if(aAux[0].trim() == "nSeqRef"){
				   
				   var oProc = $.grep( objSubJsonProc.procedimentos, function( n, i ) {
					   return n.cSeqMov.actualValue.trim() == aAux[1].trim();
				   });
		   
				   if(oProc.length > 0){
					   cSeqRefAtu  += (aAux[1]+'$'+strZero1(oProc[0].cSeqMov.actualValue.trim(),3)) + '!';
					   aAux[1] = strZero1(oProc[0].cSeqMov.actualValue.trim(),3);
					   //arrumo sequencial do nref igual a posição do grid de procedimentos
					   if (strZero1(oProc[0].sequen.trim(),3) != aAux[1]) {
						   aAux[1] = strZero1(oProc[0].sequen.trim(),3);
					   }
					   aCampoExecutante[j] = 'nSeqRef!'+aAux[1];
				   }	
			   }
			   if (aAux[0].trim() == 'cSeqBD7') {
				   cBkpSeqMov = aAux[1].trim();
			   }
			   objSubJsonExec += '"' + aAux[0] + '"' + ':{ "defaultValue" : ' + '"' + aAux[1].trim() + '"' + ', "actualValue":' + '"' + aAux[1].trim() + '"}';
			   objSubJsonExec += ","
		   }
		   
		   objSubJsonExec +=  '"seqExe":' + '"' + cont.toString() + '",';
		   objSubJsonExec +=  '"sequenBD7":' 	+ '"' + cBkpSeqMov + '",';
		   objSubJsonExec +=  '"lNewIte":false,';
		   objSubJsonExec +=  '"lDelIte":false}';
		   objSubJsonExec +=  i < (aGridExecutantes.length - 2) ? "," : ""
		   cont++;

		   aMatProfG.push(aCampoExecutante)
	   }
   }
   
   objSubJsonExec = ' {"executantes":[' + objSubJsonExec + ']} ';
   objSubJsonExec = JSON.parse(objSubJsonExec);
   
   //-----------------------------------------------------------------------
   // Crio um objeto com escopo global que contém os dados da SADT
   //-----------------------------------------------------------------------
   oGuiaOff = $.extend({}, objSubJsonCabec, objSubJsonProc, objSubJsonExec);

   if(aMatIteG.length > 0){
	   fCarregaTabelaHon('TabExeSer$1', aMatIteG, "1",true);
   }

   if(aMatProfG.length > 0){
	   if(cSeqRefAtu != "")
		   cSeqRefAtu = cSeqRefAtu.slice(0, -1);
	   aBkpHonRes = aMatProfG;
	   fCarregaTabelaHon('TabExe$1', aMatProfG, "1",false, cSeqRefAtu);
   }

   //Execucao
   if(!isDitacaoOffline() && isAlteraGuiaAut())
   {
	   setDisable("cProExe",true);
	   setDisable("cProSol",true);
	   setDisable("BcProSol",true);
	   setDisable('bIncTabExe',true);
	   setDisable("bSaveTabExe",true);
	   setDisable("bconfirma",false);
	   setDisable("bcomplemento",true);
	   setDisable("bimprimir",true);
	   setDisable("bAnexoDoc",true);
	   setDisable("bIncTabExeSer",true);
	   setDisable("bSaveTabExeSer",true);
	   setDisable("btnTabExeSer0",true);
	   setDisable("bIncTabSolSer",true);
	   setDisable("bSaveTabSolSer",true);
	   setDisable("bIncTabExeSer",true);
   } else if ( isDitacaoOffline() && isAlteraGuiaAut() ){

	   setDisable("bIncTabSolSer",true);
	   setDisable("bSaveTabSolSer",true);
	   setDisable(cBtnExec,true);
	   if (lGuiResInt) {
		   $('#GrpIndExe').slideUp();
		   $('#GrpObsAss').slideUp();
		   lGuiResInt = false;
	   }
	   
	   _$Forminputs = $('form :input:not([type=submit][type=button])');

	   for (var i = 0; i < _$Forminputs.length; i++) {

		   $(_$Forminputs[i]).data('default', $(_$Forminputs[i]).val());
	   }
	   



		   
	   //Altera mascara dos campos de valores
	   document.getElementById('nVlrUniSExe').value = document.getElementById('nVlrUniSExe').value.replace('.','').replace(',','.');			
	   document.getElementById('nVlrTotSExe').value = document.getElementById('nVlrTotSExe').value.replace('.','').replace(',','.');
	   
	   //----------------------------------------------------------
	   //Alterar onchange dos campos editaveis da guia odontologica
	   //----------------------------------------------------------
	   _$Forminputs.on('change', function(e) {
		   for (var i = 0; i < _$Forminputs.length; i++) {
			   if(oGuiaOff.cabecalho[$(_$Forminputs[i]).prop('id')] != undefined && $(_$Forminputs[i]).val() != null){
				   if (oGuiaOff.cabecalho[$(_$Forminputs[i]).prop('id')].defaultValue != $(_$Forminputs[i]).val()){
					   //Se o valor atual for diferente do default, atribui o valor do campo ao atual.
					   if($(_$Forminputs[i]).prop('id') == "cCbosSol" || $(_$Forminputs[i]).prop('id') == "cCbosExe"){
						   oGuiaOff.cabecalho[$(_$Forminputs[i]).prop('id')].actualValue = $(_$Forminputs[i]).val().substring(0,3);
					   }else{
						   oGuiaOff.cabecalho[$(_$Forminputs[i]).prop('id')].actualValue = $(_$Forminputs[i]).val();
					   }
				   }
			   }
		   }
	   });
   }

 if (document.getElementById("cTp").value == "5") {
	 CalculaTotaisGuia();
 }
}

// Processa Odonto													
function fProcFormOdonto(formulario, lIntercambio) {

   var lDigOff = false;
   var tudo = formulario; 
   var cCampo = null;

   if (document.getElementById("cProSol").value == '' && document.getElementById("cProExe").value == '') {
	   alert('Deve ser informado ou Solicitante ou Executante para confirmação da guia');
	   document.getElementById("cProSol").focus();
	   return;
   }
   
	// Campo obrigatorio tipo de atendimento
   if (document.getElementById("cTpAto").value == '') {
	   alert('Deve ser informado o Tipo de Atendimento');
	   document.getElementById("cTpAto").focus();
	   return;
   }

   //Aviso Grid Vazia
   if (document.getElementById("TabOdonto").rows.length == 0) {
	   alert("Informe pelo menos um serviço para a guia");
	   return;
   }
   
   cCampo =  document.getElementById("cProtoc");

   if 	(( cCampo != 'undefined' && cCampo != null ) && (!lIntercambio &&  cCampo.value == '')) {
	   alert('Informe o número do protocolo');
	   document.getElementById("cProtoc").focus();		
	   return;
   }
   
   //Monta conteudo das tabelas solicitacao e execucao
   aMatAux = "TabOdonto";

   //Carrega as linhas das tabelas para processamento
   aMat = aMatAux.split("|");
   cStringEnvTab = "";
   for (var i = 0; i < aMat.length; i++) {
	   oTable = document.getElementById(aMat[i]);
	   fMontMatGer('A', aMat[i]);
	   aMatCampAux = aMatCap.split("|");
	   for (var y = 1; y < oTable.rows.length; y++) {
		   nf = 0;

		   cStringEnvTab += "cSeq@" + getTC(oTable.rows[y].cells[0]) + "$";

		   for (var x = 3; x < (oTable.rows[y].cells.length + nf); x++) {
			   cCampo = aMatCampAux[x - 3].split("$")[1];
			   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo) == -1) {
				   celula = oTable.rows[y].cells[x - nf];

				   if (typeof celula.value == 'undefined' || celula.value == '')
					   conteudo = getTC(celula);
				   else conteudo = celula.value;

				   cStringEnvTab += cCampo + "@" + conteudo + "$";
			   }
			   if (aMatCampAux[x - 3].split("$")[0] == 'cfixo') nf += 1;
		   }
		   cStringEnvTab += "|";
	   }
   }

   document.getElementById("cMatTabES").value = cStringEnvTab + "|";
   
   if (isDitacaoOffline()) {
	   lDigOff = true;
	   modalBS('<i class="fa fa-exclamation-triangle" style="font-weight: bold; color: #000; text-shadow: 0 1px 0 #fff; filter: alpha(opacity=20); opacity: .2;"></i>&nbsp;&nbsp;&nbsp;Alerta', '<p>Tem certeza que deseja finalizar a guia?</p>', "@Sim, conclui a digitação!~confirmaOdonto('1')@Não, desejo continuar posteriormente!~confirmaOdonto('2');", "white~ #f8c80a", "large","N");
	   setDisable('bconfirma',true);
	   setDisable("bcomplemento",false);
	   setDisable("bimprimir",true);
	   setDisable("bAnexoDoc",false);
	   return;
   } else {
	   document.forms[0].action = "W_PPLPROCGUI.APW";
	   setDisable("bimprimir", false);
   }

   //Trata campos
   setDisable("cCbosSol", false);
   setDisable("cCbosExe", false);
   setDisable("cProExe", false);
   setDisable("bconfirma", true);
   setDisable("bcomplemento", false);
   
   setDisable("bAnexoDoc",false);
   
   //Metodo de envio de formulario pelo ajax
   if (!isDitacaoOffline()) {
	   Ajax.send(formulario, {
	   callback: CarregaProcForm,
	   error: ExibeErro
	   });
   }	

   document.forms[0].action = "";

   //Desabilita os campos
   FDisElemen('TPSE|Tdb|Tcr|TcrS|TcrE|Trod|BTrat|TabOdonto|Toth', true);
   if (!lPrint) {
	   setDisable("bimprimir", true); // Pagto no ato ou autorizada parcialmente, desabilita o botao 
   } else {
	   setDisable("bimprimir", false);
   }

   //Marca todas as linhas para delecao e retira da matriz de sessao
   aTabDel = new Array("TabOdonto")
   for (var y = 0; y < aTabDel.length; y++) {
	   document.getElementById(aTabDel[y]).ondblclick = function() {};
   }

}

function fGridOutrasDespesas(cTp, cTable, nOpc) {
   cTpR = cTp;
   cTableR = cTable;
   cQueryString = "&cRda=" + document.getElementById('cRda').value + "&cCodLoc=" + document.getElementById('cCodLoc').value;

   //Desabilita botoes
   setDisable("bIncTabOutDesp",true);
   setDisable("bSaveTabOutDesp",true);
   
   //--------------------------------------------------------------------
   // Monta conteudo da tabela			  
   //--------------------------------------------------------------------
   aMatAux = "TabOutDesp$oTabOutDesp";
   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   cStringEnvTab = "";
   aMat = aMatAux.split("|");

   if ((document.getElementById('cNumGuiRef').value == "")) {
	   alert('Informe o número da guia referenciada!');
	   document.getElementById('cNumGuiRef').focus();
	   //Habilita botoes
	   setDisable("bIncTabOutDesp",false);
	   return;
   }

   for (var i = 0; i < aMat.length; i++) {
	   aMatAux = aMat[i].split("$")
		   //Se o grid foi preenchido
	   if (typeof eval(aMatAux[1]) != "string" && eval(aMatAux[1]).aCols.length > 0) {
		   //Recupera os dados do grid
		   oTable = eval(aMatAux[1]).getObjCols();

		   fMontMatGer('A', aMatAux[0]);

		   aMatCampAux = aMatCap.split("|");
		   for (var y = 1; y < oTable.rows.length; y++) {
			   nf = 0;
			   cStringEnvTab += "cSeq@" + getTC(oTable.rows[y].cells[0]) + "$";
			   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {

				   cCampo = aMatCampAux[x - 2].split("$")[1];
				   if (cCampo != "NIL" && aNoArray.indexOf(cCampo) == -1) {
					   celula = oTable.rows[y].cells[x + 1 - nf];

					   if (typeof celula.value == 'undefined' || celula.value == '')
						   conteudo = getTC(celula);
					   else conteudo = celula.value;
					   cStringEnvTab += cCampo + "@" + conteudo.trim() + "$";
				   }
				   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;
			   }
			   cStringEnvTab += "|";
		   }
	   }
   }
   //--------------------------------------------------------------------
   // Define parametros para uso na funcao de resultado					  
   //--------------------------------------------------------------------
   fMontMatGer(cTp, cTable);
   //--------------------------------------------------------------------
   // Matriz de campos													  
   //--------------------------------------------------------------------
   var aMatCol = aMatCap.split("|");
   if (eval(aMatAux[1]) != "" && eval(aMatAux[1]).aCols.length > 0) {
	   var oTable = eval(aMatAux[1]).getObjCols();
   } else {
	   var oTable = null
   }
   //--------------------------------------------------------------------
   // Tratamento inclusao ou alteracao									  
   //--------------------------------------------------------------------
   if (cTp == 'I' || cTp == 'A') {

	   if (document.getElementById('cCodDesp').value == "") {
		   alert('Informe a natureza da despesa.');
		   document.getElementById('cCodDesp').focus();
		   setDisable("bIncTabOutDesp",false);
		   return;
	   }

	   if (document.getElementById('cUnMedidaSExe').value == "" && document.getElementById('cCodPadSExe').value == "20") {
		   alert('Informe a Unidade de Medida.');
		   document.getElementById('cUnMedidaSExe').focus();
		   setDisable("bIncTabOutDesp",false);
		   return;
	   }

	   if (document.getElementById('dDtExe').value == "") {
		   alert('Informe a data da despesa.');
		   document.getElementById('dDtExe').focus();
		   setDisable("bIncTabOutDesp",false);
		   return;
	   }

	   if (document.getElementById('cCodPadSExe').value == "") {
		   alert('Informe a tabela do item.');
		   document.getElementById('cCodPadSExe').focus();
		   setDisable("bIncTabOutDesp",false);
		   return;
	   }

	   if (document.getElementById('cCodProSExe').value == "") {
		   alert('Informe o código do item.');
		   document.getElementById('cCodProSExe').focus();
		   setDisable("bIncTabOutDesp",false);
		   return;
	   }

	   if (document.getElementById('cQtdSExe').value == "" || document.getElementById('cQtdSExe').value == "0") {
		   alert('Informe a quantidade de Serviço.');
		   document.getElementById('cQtdSExe').focus();
		   setDisable("bIncTabOutDesp",false);
		   return;
	   }

	   if (document.getElementById('nRedAcreSExe').value == "") {
		   alert('Informe o fator de redução ou acréscimo.');
		   document.getElementById('nRedAcreSExe').focus();
		   setDisable("bIncTabOutDesp",false);
		   return;
	   }

	   if (document.getElementById('nVlrUniSExe').value == "") {
		   alert('Informe o valor unitário.');
		   document.getElementById('nVlrUniSExe').focus();
		   setDisable("bIncTabOutDesp",false);
		   return;
	   }

	   //--------------------------------------------------------------------
	   // Verifica duplicidade												   
	   //--------------------------------------------------------------------
	   var nCol = 0;
	   if (typeof oTable != "string" && oTable != null) {
		   var nQtdLinTab = oTable.rows.length;
	   } else {
		   var nQtdLinTab = 0;
	   }
	   var cString = '1' + "|";
	   var cContChave = document.getElementById(cChave).value;
	   if (cContChave == "") {
		   alert("Serviço não informado");
		   document.getElementById(cChave).focus();
		   //Habilita botoes
		   setDisable("bIncTabOutDesp",false);
		   return;
	   }
	   //--------------------------------------------------------------------
	   // Monta a sequencia e matriz de retorno								   
	   //--------------------------------------------------------------------
	   if (document.getElementById(aMatAux[1]) != null) {
		   if (typeof document.getElementById(aMatAux[1]).length != 'undefined') {
			   if (cTp == 'I')
				   cString = String(document.getElementById(aMatAux[1]).length + 1) + "|";
			   else cString = String(document.getElementById(aMatAux[1]).length) + "|";
		   }
	   }

	   //--------------------------------------------------------------------
	   // Monta envio das variaveis de sessao GET								  
	   //--------------------------------------------------------------------

	   nRecno = document.getElementById(cTableR + "_RECNO").value;
	   var cNumGuiRef = $("#cNumGuiRef").val();
	   var cTpGuiRef = $("#cTpGuiRef").val();
	   var cRecGuiRef = $("#cRecGuiRef").val();

	   //Executa o metodo													
	   if (cTp == 'I') {
		   nOpc = 3;
	   } else {
		   nOpc = 4;
	   }

	   cQueryString = "&cRda=" + document.getElementById('cRda').value.trim() +
		   "&cCodLoc=" + document.getElementById('cCodLoc').value.trim() +
		   "&cNomeRdaExe=" + document.getElementById('cNomeRdaExe').value.trim() +
		   "&cGuiRef=" + document.getElementById('cGuiRef').value.trim() +
		   "&cChvBD6=" + document.getElementById('cChvBD6').value.trim() +
		   "&cTissVer=" + document.getElementById('cTissVer').value.trim() +
		   "&cAteRn=" + document.getElementById('cAteRn').value.trim() +
		   "&cCid=" 	 + document.getElementById('cCid').value.trim() +			
		   "&cVlrUniSExe=" + document.getElementById('nVlrUniSExe').value.trim() +
		   "&nOpc=" + nOpc +
		   "&nRecno=" + nRecno +
		   "&cNumGuiRef=" + cNumGuiRef.trim() +
		   "&cTpGuiRef=" + cTpGuiRef.trim() +
		   "&cRecGuiRef=" + cRecGuiRef.trim();

	   cCamGer = "";
	   var objSubJson = "{";
	   for (var i = 0; i < aMatCol.length; i++) {
		   var aMatColAux = aMatCol[i].split("$");
		   cCampo = document.getElementById(aMatColAux[0]);
		   if (typeof cCampo != 'undefined' && cCampo != null && aMatNGet.indexOf(aMatColAux[1]) == -1) {
			   cQueryString += "&" + aMatColAux[1] + "=" + cCampo.value;
						   
			   if(cTp == 'I'){
				   objSubJson += '"' + aMatColAux[0] + '"' + ':{ "defaultValue" : ' + '"' + cCampo.value.trim() + '"' + ', "actualValue": ' + '"' + cCampo.value.trim() + '"}';
				   objSubJson += ","
			   }else{
				   objSubJson = getObjects(oProcOutDesp, "sequen",nRecno);
				   if(objSubJson.length > 0){
					   objSubJson = objSubJson[0];
					   if(objSubJson[aMatColAux[0]] != undefined){ 
						   objSubJson[aMatColAux[0]].actualValue = cCampo.value.trim();
					   }
				   }
			   }
				   
		   }
	   }
	   if(cTp == 'I'){
		   objSubJson +=  '"sequen":' + '"' + (typeof oTabOutDesp != "string" ? (oTabOutDesp.aCols.length+1).toString() : "1") + '",';
		   objSubJson +=  '"lNewIte":true,';
		   objSubJson +=  '"lDelIte":false}';
	   }
	   //--------------------------------------------------------------------
	   // Verifica duplicidade												  
	   //--------------------------------------------------------------------
	   for (var i = 0; i < nQtdLinTab; i++) {
		   for (var y = 0; y < aMatCol.length; y++) {
			   var aMatColAux = aMatCol[y].split("$");
			   if (aMatColAux[0] == cChave) {
				   nCol = y;
				   break;
			   }
		   }
		   if (cTp == 'A') nCol++;
		   //--------------------------------------------------------------------
		   // Verfica se existe um registro igual na tabela						  
		   //--------------------------------------------------------------------
		   var lResult = false;
		   if (i + 1 != parseInt(nRecno) && getTC(oTable.rows[i].cells[nCol + 2]) == cContChave) {
			   //--------------------------------------------------------------------
			   // verifica se algum campo foi alterado			   					   
			   //--------------------------------------------------------------------
			   if (oTable.rows[i].style.backgroundColor != "") {
				   cSt = "0";
				   //--------------------------------------------------------------------
				   // Verifica se alguma campo que necessita de checar a regra novamente foi alterado
				   //--------------------------------------------------------------------
				   lResult = true;
				   for (var y = 3; y < oTable.rows[i].cells.length; y++) {
					   var aMatColAux = aMatCol[y - 3].split("$");
					   cCampo = document.getElementById(aMatColAux[0]);
					   if (cCampo != undefined && getTC(oTable.rows[i].cells[y]) != cCampo.value) {
						   cSt = "1";
						   if (aValAlt.indexOf(aMatColAux[0]) != -1) lResult = false;
					   }
				   }
				   //--------------------------------------------------------------------
				   // Altera a tabela sem checar a regra novamente								  
				   //--------------------------------------------------------------------
				   if (lResult) {
					   fGetDadGen(nRecno, cTable, 4, true, cCampo.value, "", cCampoDefault.replace(/\|/g, ","));
					   //Habilita botoes
					   setDisable("bIncTabOutDesp",false);
					   return;
				   }
			   } else {
				   if (cTp != 'A') {
					   console.log("já existe este registro");
					   //Habilita botoes
					   setDisable("bIncTabOutDesp",false);
					   return;
				   }
			   }
		   }
	   }
	   cString += aMatRet + "|" + cStringEnvTab + "|";
	   if(cTp == "I")
		   oProcOutDesp.procedimentos.push(JSON.parse(objSubJson));
	   //--------------------------------------------------------------------
	   // Executa o metodo													  
	   //--------------------------------------------------------------------
	   if (!lResult) {
		   Ajax.open("W_PPLITODE.APW?cString=" + cString + cQueryString, {
			   callback: CarregaMontItensOutDesp,
			   error: ExibeErroOD
		   });


	   }
   }
   //--------------------------------------------------------------------
   // Calculo de valores primeiro campo recebe segundo campo o valor do	  
   // campo e pego da tabela												  
   //--------------------------------------------------------------------
   if (typeof aCalVal != 'undefined' && aCalVal != null) {
	   var aCalValAux = aCalVal.split("|");
	   for (var i = 0; i < aCalValAux.length; i++) {
		   if (aCalValAux[i] != "") {
			   var aMatCamp = aCalValAux[i].split("$");
			   //--------------------------------------------------------------------
			   // Para pegar os campos de informacao e recebimento					  
			   //--------------------------------------------------------------------
			   if (typeof aMatCamp[0] != 'undefined' && aMatCamp[0] != null && typeof aMatCamp[1] != 'undefined' && aMatCamp[1] != null) {
				   //--------------------------------------------------------------------
				   // Descobrir a coluna na tabela										  
				   //--------------------------------------------------------------------
				   for (var x = 0; x < aMatCol.length; x++) {
					   var aMatColAux = aMatCol[x].split("$");
					   if (aMatColAux[0] == aMatCamp[1]) {
						   nCol = x;
						   break;
					   }
				   }
				   if (cTp != 'I') nCol++;
				   //--------------------------------------------------------------------
				   // atualiza os campos com base no valor da tabela						  
				   //--------------------------------------------------------------------
				   var nValor = 0;
				   var cCampo = document.getElementById(aMatCamp[0]);
				   for (var x = 1; x < oTable.rows.length; x++) {
					   nValor += parseInt(getTC(oTable.rows[x].cells[nCol + 1]).replace(/\D/g, ""));
				   }
				   cCampo.value = MaskMoeda(nValor);
			   }
		   }
	   }
   }


   if(cTp == "A"){
	   //Desbloqueia o botão incluir para que possa ser atribuído um novo valor
	   setDisable("bIncTabOutDesp",false);
   }
   
}

//Exibe erro e re-habilita botao de incluir
function ExibeErroOD(v) {
   setDisable("bIncTabOutDesp",false);
   ExibeErroJson(v);
}

//--------------------------------------------------------------------
// Pega o retorno do processamento										  
//--------------------------------------------------------------------
function CarregaMontItensOutDesp(v) {          

   var lAto 	= false;
   var aResult = v.split("|");
   var cTitulo = aResult[0]; 				//Titulo do resultado autorizado,negado ou autorizado parcial
   var aMatRet = aResult[1].split("~"); 	//Retorno para grid campos e resultado do campo
   var cTexto 	= aResult[5]; 				//Procedimento autorizados ou negados resultado
   var cLembr = aResult[6] == "0" ? "" : aResult[6]; //Lembrete do Procedimento na Tabela Padrão (BR8_LEMBRE)
   //--------------------------------------------------------------------
   // Alimentar campos de retorno											  
   //--------------------------------------------------------------------

   var cAlerta  = aResult[7];				 //Alertas do procedimento 
   var cTitComp = aResult[8];				//complemento do titulo 
	
   //Habilita botoes
   setDisable("bIncTabOutDesp",false); 
   
   if (typeof cTitComp != 'undefined') { 
	   
	   if (cTitulo == '1') { 
	   
		   cTitulo = cTitComp;
	   
	   } else {
		   cTitulo += cTitComp;
	   }
   }
	   
   for (var i = 0; i < aMatRet.length; i++) {
	   aRetAux = aMatRet[i].split(";");
	   cCampo = document.getElementById(aRetAux[0]);

	   if (typeof cCampo != 'undefined' && cCampo != null) 
		   cCampo.value = aRetAux[1];
   }
   
   //--------------------------------------------------------------------
   // Se vai incluir ou alterar a linha campo alimentado pela aMatRet 	  
   //--------------------------------------------------------------------
   if (typeof cTableR != 'undefined' && typeof aMatCap != 'undefined' && typeof aMatBut != 'undefined') {
	   cCampo = document.getElementById("cStatusAut");
	   if (typeof cCampo != 'undefined' && cCampo != null) {

		   if (cCampo.value == '5') {
			   lAto = true;
			   cCampo.value = '1';
		   }

		   if (!v.match(/Impede.*/)){ // validação referente a critica de 'codigo tabela invalido'
			   
				if (cTpR == 'I') {
					fGetDadGen(0, cTableR ,3,true,cCampo.value,"",cCampoDefault.replace(/\|/g,","));                
				
					var cTpAut 	  	 = "1";

					var cCodPad = document.getElementById("cCodPadSExe").value;

					var cCodPro 	 = document.getElementById("cCodProSExe").value;
					var nQtdAut 	 = document.getElementById("cQtdSExe").value;
					var cStatus 	 = document.getElementById("cStatusAut").value;
					var dDtExe		 = document.getElementById("dDtExe").value;
					var nRedAcreSExe = document.getElementById("nRedAcreSExe").value;

					//Se for um pacote, adiciona todos os itens do mesmo.
					Ajax.open("W_PPLSITEPCT.APW?cCodPct=" + (cCodPad + cCodPro) + "&qtdAutSSol=" + nQtdAut +"&cStatusAut=" +cStatus  + "&cTpAut=" + cTpAut + '&dDtExe=' + dDtExe + '&nRedAcreSExe=' + nRedAcreSExe, {
						callback: AdicionProcRelPct,
						error: ExibeErro
					});
				
				}else{
					fGetDadGen(document.getElementById(cTableR+"_RECNO").value, cTableR ,4,true,"1","",cCampoDefault.replace(/\|/g,","));
				}
		   
			}else{
				oProcOutDesp.procedimentos.pop() 
			}
		   //--------------------------------------------------------------------
		   // Retorno o valor original											  
		   //--------------------------------------------------------------------
		   cCampo.value == "0";
	   }
   }
   //--------------------------------------------------------------------
   // Mostra o resultado modal so mostra se for negado ou se existir lembrete 
   //--------------------------------------------------------------------
   if ( cTitulo != "1" || cAlerta != 'undefined' && cAlerta != "") { 
	   
	   if (cAlerta != "") {
		   cTexto += cAlerta;
		   ShowModal(cTitulo, cTexto, false, false, true, undefined, (cLembr != "" ? "@Fechar~RepShowModal('Lembrete:', '" + cLembr + "');" : ""));
	   } else {
		   ShowModal(cTitulo, cTexto, undefined, undefined, undefined, undefined, (cLembr != "" ? "@Fechar~RepShowModal('Lembrete:', '" + cLembr + "');" : ""));
	   }
	   
   } else {
	   if (cLembr != "0" && cLembr != "") {
		   ShowModal("Lembrete", cLembr, true);
	   }
   }
   
   //--------------------------------------------------------------------
   // Se for pagamento no ato												   
   //--------------------------------------------------------------------
   if ( lAto )	alert("Realizar o pagamento na Operadora.\nPara este procedimento deve ser efetuado o pagamento no ato.");
	   
}

function OutrasDespLoad(){
var aResult = {};
cVazio = "";
cVirgula = ",";
   //--------------------------------------------------------------------
   // Carrega dados da rda												   
   //--------------------------------------------------------------------
   if( isDitacaoOffline() ){
	   var cNumGuiRef = $("#cNumGuiRef").val();
	   var cTpGuiRef	= $("#cTpGuiRef").val();
	   var cRecGuiRef	= $("#cRecGuiRef").val();
	   var cStrEnv = "W_PPLCHAALT.APW";
	   
	   cStrEnv += "?cNumGuiRef="	+ cNumGuiRef;
	   cStrEnv += "&cTpGuiRef="	+ cTpGuiRef;
	   cStrEnv += "&cRecGuiRef="	+ cRecGuiRef;
	   cStrEnv += "&cRecno"			+ cRecGuiRef;
	   cStrEnv += "&cTipGui=12";
	   Ajax.open(cStrEnv  , { callback : fRespostaOutrasDesp, error : exibeErro });
   }
}

function fRespostaOutrasDesp(v){
   //aMatCabIte -> Tem os dados do Cabe?lho e detalhe. 
   var objJson = '{ "procedimentos":[';
   var objSubJson = "";
   if ( v.indexOf('$') != -1) {
	   var aMatPro = v.split("|-|");
	   var aMatCabIte 	= aMatPro[0].split("<");
	   var aMatCab 	= aMatCabIte[0].split("|");
	   var aProf		= {};
   }
   else{
	   var aMatCabIte 	= v.split("<");
	   var aMatCab 	= aMatCabIte[0].split("|");
   }
   cCampoRefL 		= "";
   //--------------------------------------------------------------------
   // Verifico se a estrutura dos itens foram enviadas					  
   //--------------------------------------------------------------------
   if (typeof aMatCabIte[1] == "undefined") {
	   alert("Estrutura indefinida");
	   return;
   }
   var aMatIte = aMatCabIte[1].split("~");
   //--------------------------------------------------------------------
   // Exibe criticas de procedimentos que nao podem ser executados		  
   //--------------------------------------------------------------------
   if (typeof aMatCab[aMatCab.length-1] != "undefined") {
	   if (aMatCab[aMatCab.length-1] != "") alert(aMatCab[aMatCab.length-1]);
   }
   
	//--------------------------------------------------------------------
   // Cabecalho 		  
   //--------------------------------------------------------------------
   for (var i = 0; i < (aMatCab.length - 1); i++) {
	   var aCamVal = aMatCab[i].split("!");
	   //--------------------------------------------------------------------
	   // Somente se foi passado o nome do campo								  
	   //--------------------------------------------------------------------
	   if (aCamVal[0] != "") {
		   var cCampo = document.getElementById(aCamVal[0]);
		   if (cCampo != null) {
				   cCampo.value = aCamVal[1].trim();
		   }
		   
		   if(aCamVal[0] == "cCid" || aCamVal[0] == "cAteRn"){
				   var input = document.createElement("input");
				   input.setAttribute("type", "hidden");
				   input.setAttribute("name", aCamVal[0]);
				   input.setAttribute("id", aCamVal[0]);
				   input.setAttribute("value", aCamVal[1]);
				   document.forms[0].appendChild(input);
		   }
	   }
   }
   
	   var aMatIteG = new Array()
   
   //--------------------------------------------------------------------
   // Monta o array com os itens do detalhe da solicitação de procedimento 
   //--------------------------------------------------------------------
   var cont = 1;
   for (var i = 0; i < aMatIte.length; i++) {
	   //--------------------------------------------------------------------
	   // Matriz com os campos e valores SERVICO								  
	   //--------------------------------------------------------------------
	   if (aMatIte[i] != "") {
		   //--------------------------------------------------------------------
		   //?Aprimeira posicao da matriz aMatval e o tipo de servico a segunda      		
		   //?e se vai ser exibido ou nao da terceira em diante contem valores dos campos	
		   //--------------------------------------------------------------------
		   var aMatVal = aMatIte[i].split("@");
		   
		   var aAux 
		   objSubJson += "{";
		   for(var j = 0; j < aMatVal.length; j++){
			   aAux = aMatVal[j].split("!");
			   objSubJson += '"' + aAux[0] + '"' + ':{ "defaultValue" : ' + '"' + aAux[1].trim() + '"' + ', "actualValue":' + '"' + aAux[1].trim() + '"}';
			   objSubJson += ","
		   }
		   
		   objSubJson +=  '"sequen":' + '"' + cont.toString() + '",';
		   objSubJson +=  '"lNewIte":false,';
		   objSubJson +=  '"lDelIte":false}';
		   objSubJson +=  i < (aMatIte.length - 2) ? "," : ""
		   cont++;
		   //--------------------------------------------------------------------
		   //?A segunda posicao [1] retorna se e possivel exibir para uma rda o procedimento  
		   //--------------------------------------------------------------------
		   var cMostraSer = aMatVal[1].split("!")[1];
		   
		   /*if(aMatVal[26].split("!")[1] == 'S') //Se for pacote, exibe a mensagem.
			   alert('O pacote de codigo ' + aMatVal[3].split("!")[1] + ' possui procedimentos relacionados, os procedimentos serao carregados e devem compor a guia.');
			   */
			 //--------------------------------------------------------------------
			 //aMatIteG
		   //Estrutura: Tipo - Array, Conte?o - Linha do detalhe
		   //	Estrutura: Tipo - String, Conte?o - Coluna do detalhe: Variavel_Protheus!Valor 
		   //	***N? necess?iamente a coluna existe no grid. Isso ?validado posteriormente
			 //--------------------------------------------------------------------
		   aMatIteG.push(aMatVal);
	   }
   }
   
   objJson += objSubJson +  ']}';
   //-----------------------------------------------------------------------
   // Crio um objeto com escopo global que contém os itens das outras despesas
   //-----------------------------------------------------------------------
   oProcOutDesp = JSON.parse(objJson);
	   //--------------------------------------------------------------------
	   //Chama a função que carrega os grids.
	   //Pede para a função preencher o grid de proc. Sol. "TabSolSer" e copiar os itens pro grid proc. Exec. "TabExeSer"
	   //Pode ser que ainda não existam itens para as outras despesas
	   //--------------------------------------------------------------------
	   if(aMatIteG.length > 0){
		   fCarregaTabela('TabOutDesp$1',aMatIteG,cMostraSer);
		   CalculaTotaisOutDes();
	   }

   if(document.getElementById("cTpGuiRef").value == "5"){
	   document.getElementById("dDtExe").value = "";
   }

}
function fProcFormOutDesp(formulario){
   //Itens adicionados são aqueles que tem a propriedade LNEWITE verdadeira e LDELITE falsa pois se o usuário incluiu e depois deletou o procedimento
   //ainda não foi pra base então desconsidero
   var addedItems = getObjects(oProcOutDesp.procedimentos, "lNewIte", true);
   addedItems = getObjects(addedItems, "lDelIte", false);
   
   var strAdded = "";
   var i = 0;
   //Para os itens adicionados preciso enviar todos os atributos para o servidor.
   for(i=0; i<addedItems.length; i++){		
	   for(var key in addedItems[i]){
			   switch(key) {
				   case "lNewIte":
				   case "lDelIte":
				   case "sequen":
					   strAdded += key+"="+addedItems[i][key]+"$";
					   break;
				   default:
					   strAdded += key+"="+addedItems[i][key].actualValue+"$";
			   }
	   }
	   strAdded = strAdded.slice(0, -1);
	   strAdded += i == (addedItems.length - 1) ? "" : "&";
	   
   }
   
   //Itens excluídos são os que vieram da base, ou seja LNEWITE falso e LDELITE verdadeira
   var deletedItems = getObjects(oProcOutDesp.procedimentos, "lNewIte", false);
   deletedItems = getObjects(deletedItems, "lDelIte", true);
   
   var strDeleted = "";
   
   //Para os itens excluidos preciso enviar apenas os atributos chave para localizar na BD6 e BX6.
   for(i=0; i<deletedItems.length;i++){
		   strDeleted += "cCodPadKey="			+deletedItems[i].cCodPadSExe.defaultValue;
		   strDeleted += "$cCodProKey="			+deletedItems[i].cCodProSExe.defaultValue;
		   strDeleted += "$cSeqMov="				+deletedItems[i].cSeqMov.defaultValue;
		   strDeleted += i == (deletedItems.length - 1) ? "" : "&";
   }
   
   //Itens editados são todos os itens que vieram da base, ou seja LNEWITE falso e LDELITE falso e que possuem algum atributo modificado
   //defaultValue diferente de actualValue
   var editedItems = getObjects(oProcOutDesp.procedimentos, "lNewIte", false);
   editedItems = getObjects(editedItems, "lDelIte", false);
   
   var strEdited = "";
   var edited = false;
   var cCodPadEdited = false;
   var cCodProEdited = false;
   var cCodDespEdited = false;
   var cIteProp = "";
   //Para os itens deletados, preciso enviar os atributos chave para localizar na BD6 e BX6 e mais os atributos modificados (defaultValue diferente de actualValue)
   for(i=0;i<editedItems.length;i++){
	   edited = false;
	   cIteProp = "";
	   cCodPadEdited = false;
	   
	   //verifico se o codigo da tabela ou do procedimento foi alterado, pois vou ter que enviar todos os campos para o servidor para inserir uma nova BD6
	   if(editedItems[i].cCodProSExe.defaultValue != editedItems[i].cCodProSExe.actualValue ||
		  editedItems[i].cCodPadSExe.defaultValue != editedItems[i].cCodPadSExe.actualValue){
		  edited = true;
		  for(var key in editedItems[i]){
			   switch(key) {
				   case "lNewIte":
				   case "lDelIte":
				   case "sequen":
					   cIteProp += key+"="+editedItems[i][key]+"$";
					   break;
				   case "cSeqMov":
					   break;
				   default:
					   strEdited += key+"="+editedItems[i][key].actualValue+"$";
			   }
		   }
   
	   }else{
		   for(var key in editedItems[i]){
			   if(key == "lNewIte" || key ==  "lDelIte" || key ==  "sequen"){
				   cIteProp += key+"="+editedItems[i][key]+"$";
			   }else if(editedItems[i][key].actualValue.toUpperCase() != editedItems[i][key].defaultValue.toUpperCase()){
					   edited = true;
					   
					   //garanto sempre a tabela e o procedimento na string quando o procedimento for alterado
					   //pois preciso fazer o de/para no webservice
					   if(key == "cCodProSExe" && !cCodPadEdited){
						   strEdited += "cCodPadSExe="+editedItems[i]["cCodPadSExe"].actualValue+"$";
						   cCodPadEdited = true;
					   }

					   //garanto que o cCodPadSExe não será adicionado duas vezes
					   if( !(key == "cCodPadSExe" && cCodPadEdited) )
						   strEdited += key+"="+editedItems[i][key].actualValue+"$";
			   }
		   }
	   }
   
	   
	   //garanto que a chave sempre estará presente na string, verifico se foi editada alguma propriedade e adiciono a chave a string
	   if(edited){
		   strEdited +=  "cCodPadKey="  	+editedItems[i].cCodPadSExe.defaultValue+"$";
		   strEdited +=  "cCodProKey="	+editedItems[i].cCodProSExe.defaultValue+"$";
		   strEdited +=  "cSeqMov="+editedItems[i].cSeqMov.defaultValue+"$";
		   strEdited += cIteProp;
		   strEdited = strEdited.slice(0, -1);
	   }
		   
	   // preenchia StrEdited com "&" quando tinha mais de um item na grid, independente se foi editado ou não
	   // fazendo com que o formulario fosse enviado no if abaixo
	   if (strEdited != "") {
		   strEdited += i == (editedItems.length - 1) ? "" : "&";	
	   }
	   
   }
   
   //Crio os hidden no formulario para enviar via POST para o servidor 
   addedItems	= document.createElement('input');
   addedItems.id	 	= 'cAddedItems';
   addedItems.type 	= 'hidden';
   addedItems.value 	= strAdded;
   formulario.appendChild(addedItems);
   
   deletedItems	= document.createElement('input');
   deletedItems.id	 	= 'cDeletedItems';
   deletedItems.type 	= 'hidden';
   deletedItems.value 	= strDeleted;
   formulario.appendChild(deletedItems);
   
   editedItems	= document.createElement('input');
   editedItems.id	 	= 'cEditedItems';
   editedItems.type 	= 'hidden';
   editedItems.value 	= strEdited;
   formulario.appendChild(editedItems);
   
   //if(typeof oTabOutDesp != "string" && oTabOutDesp.aCols.length > 0){
   if (strAdded != "" || strDeleted != "" || strEdited != ""){ 
	   document.forms[0].action = "W_PPLGROUDES.APW";
		//--------------------------------------------------------------------
		// Metodo de envio de formulario pelo ajax								  
		//--------------------------------------------------------------------
		Ajax.send(formulario, { 
			   callback: carregaResp,
			   error: exibeErro 
		});
		
	   document.forms[0].action = "";
	   setDisable("bconfirma",true);
	   setDisable("bimprimir",false);
	   setDisable("bAnexoDoc",true);
   }else{
	   modalBS("Atenção", "Informe ao menos um serviço executado!", "@Fechar~closeModalBS();", "black~#EAEB01");	
   }

}

//---------------------------
//Confirma ação após o modal
//---------------------------
function confirmaOdonto(cTipo){
   var cRecno= "";
   closeModalBS();
   var cCabecalhoEdited = "";
   var objLocalOdonto = window.frames[0].oGuiaOdonto;
   
   if(isDitacaoOffline() && isAlteraGuiaAut()){
	   //Jquery não considera esse campo como alterado, sempre irá alterar.
	   if($("#cRecnoBD5").val() != undefined){
		   cRecno = $("#cRecnoBD5").val();
	   }else{
		   cRecno = window.frames[0].document.getElementById("cRecnoBD5").value;
	   }

	   //Alteracao off-line, recuperar os campos do cabecalho contidos no objeto oGuiaOdonto.
	   //Campos a serem alterados sao os campos cujo conteudo default nao e' igual ao actualvalue, isto e', houve mudanca.
	   //---------------------------------------------------------------------------------
	   //									CABECALHO
	   //---------------------------------------------------------------------------------
	   for (var c in objLocalOdonto.cabecalho){
		   if(objLocalOdonto.cabecalho[c].defaultValue != objLocalOdonto.cabecalho[c].actualValue){
			   cCabecalhoEdited += c + "$" + objLocalOdonto.cabecalho[c].actualValue + ";";
		   }
	   }

	   //---------------------------------------------------------------------------------
	   //							PROCEDIMENTOS ADICIONADOS
	   //---------------------------------------------------------------------------------
	   //Alterações existentes na grid de procedimento da guia odontologica.
	   //Itens adicionados são aqueles que tem a propriedade LNEWITE verdadeira e LDELITE falsa pois se o usuário incluiu e depois deletou o procedimento
	   //ainda não foi pra base então desconsidero
	   var addedItems = getObjects(objLocalOdonto.procedimentos, "lNewIte", true);
	   addedItems = getObjects(addedItems, "lDelIte", false);
	   
	   var strAdded = "";
	   var i = 0;

	   //Para os itens adicionados preciso enviar todos os atributos para o servidor.
	   for(i=0; i< addedItems.length; i++){		
		   for(var key in addedItems[i]){
				   switch(key) {
					   case "lNewIte":
					   case "lDelIte":
					   case "sequen":
						   strAdded += key+"="+addedItems[i][key]+"$";
						   break;
					   default:
						   strAdded += key+"="+addedItems[i][key].actualValue+"$";
				   }
		   }
		   strAdded = strAdded.slice(0, -1);
		   strAdded += i == (addedItems.length - 1) ? "" : "&";
	   }
	   
	   //---------------------------------------------------------------------------------
	   //							PROCEDIMENTOS EXCLUIDOS
	   //---------------------------------------------------------------------------------
	   //Itens excluídos são os que vieram da base, ou seja LNEWITE falso e LDELITE verdadeira
	   var deletedItems = getObjects(objLocalOdonto.procedimentos, "lNewIte", false);
	   deletedItems = getObjects(deletedItems, "lDelIte", true);
	   
	   var strDeleted = "";
	   
	   //Para os itens excluidos preciso enviar apenas os atributos chave para localizar na BD6.
	   for(i=0; i<deletedItems.length;i++){
			   strDeleted += "cCodPadKey="	+deletedItems[i].cCodPadSE.defaultValue;
			   strDeleted += "$cCodProKey="	+deletedItems[i].cCodProSE.defaultValue;
			   strDeleted += "$cDentRegKey="+deletedItems[i].cDenteReg.defaultValue;
			   strDeleted += "$cFaceKey="	+deletedItems[i].cFaceNova.defaultValue;
			   strDeleted += "$cSeqMov="			+deletedItems[i].cSeqMov.defaultValue;
			   strDeleted += i == (deletedItems.length - 1) ? "" : "&";
	   }
	   
	   //---------------------------------------------------------------------------------
	   //							PROCEDIMENTOS ALTERADOS
	   //---------------------------------------------------------------------------------
	   //Itens editados são todos os itens que vieram da base, ou seja LNEWITE falso e LDELITE falso e que possuem algum atributo modificado
	   //defaultValue diferente de actualValue
	   var editedItems = getObjects(objLocalOdonto.procedimentos, "lNewIte", false);
	   editedItems = getObjects(editedItems, "lDelIte", false);
	   
	   var strEdited = "";
	   var edited = false;
	   var cCodPadEdited = false;
	   var cCodProEdited = false;
	   var cDentRegEdited = false;
	   var cFaceEdited	= false;
	   var cIteProp = "";
	   var lQtdSE	    = false;
	   var lVlrUniSE   = false;

	   //Para os itens alterados, preciso enviar os atributos chave para localizar na BD6 e mais os atributos modificados (defaultValue diferente de actualValue)
	   for(i=0; i<editedItems.length;i++){
		   edited = false;
		   cIteProp = "";
		   cCodPadEdited = false;
		   cCodProEdited = false;

		   //verifico se o codigo da tabela ou do procedimento foi alterado, pois vou ter que enviar todos os campos para o servidor para inserir uma nova BD6
		   if(editedItems[i].cCodProSE.defaultValue != editedItems[i].cCodProSE.actualValue ||
			  editedItems[i].cCodPadSE.defaultValue != editedItems[i].cCodPadSE.actualValue){
			  edited = true;
		   for(var key in editedItems[i]){
				   switch(key) {
					   case "lNewIte":
					   case "lDelIte":
					   case "sequen":
						   cIteProp += key+"="+editedItems[i][key]+"$";
						   break;
					   case "cSeqMov":
						   break;
					   default:
						   strEdited += key+"="+editedItems[i][key].actualValue+"$";
				   }
			   }
			   
		   }else{		
			   for(var key in editedItems[i]){
			   if(key == "lNewIte" || key ==  "lDelIte" || key ==  "sequen"){
				   cIteProp += key+"="+editedItems[i][key]+"$";
			   }else if(editedItems[i][key].actualValue.toUpperCase() != editedItems[i][key].defaultValue.toUpperCase()){
					   edited = true;
						   
						   //garanto sempre a tabela e o procedimento na string quando o procedimento for alterado
						   //pois preciso fazer o de/para no webservice
						   if(key == "cCodProSE" && !cCodPadEdited){
							   strEdited += "cCodPadSE="+editedItems[i]["cCodPadSExe"].actualValue+"$";
							   cCodPadEdited = true;
						   }

						   if (key == "nVlrUniSE" ) {
							   lQtdSE = true;
						   }
						   
						   if (key == "cQtdSE" ) {
							   lVlrUniSE = true;
						   }

						   //garanto que o cCodPadSExe não será adicionado duas vezes
						   if( !(key == "cCodPadSE" && cCodPadEdited) )
					   strEdited += key+"="+editedItems[i][key].actualValue+"$";
				   }
			   }
		   }
		   
		   //A chave nem sempre pode ter sido alterada, e não vai entrar no if acima
		   //para garantir que ela sempre estará presente na string, verifico se foi editada alguma propriedade e adiciono a chave a string
		   if(edited){
			   strEdited +=  "cCodPadKey="  	+editedItems[i].cCodPadSE.defaultValue+"$";
			   strEdited +=  "cCodProKey="		+editedItems[i].cCodProSE.defaultValue+"$";
			   strEdited +=  "cDentRegKey="  	+editedItems[i].cDenteReg.defaultValue+"$";
			   strEdited +=  "cFaceKey="  		+editedItems[i].cFaceNova.defaultValue+"$";
			   strEdited +=  "cSeqMov="		+editedItems[i].cSeqMov.defaultValue+"$";
			   //Se alterado valor unitário ou quantidade, devo obrigatoriamente passar os dois parâmetros, para cálculo do valor apresentado.
			   if (lQtdSE && !lVlrUniSE) {
				   strEdited +=  "cQtdSE="	+editedItems[i].cQtdSE.defaultValue+"$";		
			   }
			   if (lVlrUniSE && !lQtdSE) {
				   strEdited +=  "nVlrUniSE="	+editedItems[i].nVlrUniSE.defaultValue+"$";
			   }
			   strEdited += cIteProp;
			   strEdited = strEdited.slice(0, -1);
		   }
		   
		   strEdited += i == (editedItems.length - 1) ? "" : "&";
		   
	   }

	   //---------------------------------------------------------------------------------
	   //							CRIACAO DE HIDDENS
	   // Crio os hidden no formulario para enviar via POST para o servidor 
	   //---------------------------------------------------------------------------------		
	   var cHiddenCabecalhoAlterado	= document.createElement('input');
	   cHiddenCabecalhoAlterado.id	 	= 'cCabecalhoEdited';
	   cHiddenCabecalhoAlterado.type 	= 'hidden';
	   cHiddenCabecalhoAlterado.value 	= cCabecalhoEdited;
	   window.frames[0].document.forms[0].appendChild(cHiddenCabecalhoAlterado);		
	   
	   addedItems	= document.createElement('input');
	   addedItems.id	 	= 'cAddedItems';
	   addedItems.type 	= 'hidden';
	   addedItems.value 	= strAdded;
	   window.frames[0].document.forms[0].appendChild(addedItems);
	   
	   deletedItems	= document.createElement('input');
	   deletedItems.id	 	= 'cDeletedItems';
	   deletedItems.type 	= 'hidden';
	   deletedItems.value 	= strDeleted;
	   window.frames[0].document.forms[0].appendChild(deletedItems);
	   
	   editedItems	= document.createElement('input');
	   editedItems.id	 	= 'cEditedItems';
	   editedItems.type 	= 'hidden';
	   editedItems.value 	= strEdited;
	   window.frames[0].document.forms[0].appendChild(editedItems);

	   //Atribuo a action ao form - alteração é tratada por outra web function
	   window.frames[0].document.forms[0].action = "W_PPLGRODO.APW?cRecno="+cRecno+"&cTipoOrigem=digitacao&cTipoConfirm="+cTipo;	   

	   Ajax.send(window.frames[0].document.forms[0], {
		   callback: carregaResp,
		   error: ExibeErro
	   });	   
   }else{
	   window.frames[0].document.forms[0].action = "W_PPLPROCGUI.APW?cTipoOrigem=digitacao&cTipoConfirm="+cTipo;

   Ajax.send(window.frames[0].document.forms[0], {
	   callback: CarregaProcForm,
	   error: ExibeErro
   });
   }

   document.forms[0].action = "";
}

function carregaResp(v){
   var response = v.split("|");
   var cTitulo = "";
   var cTexto = "";
   var lExb = false;
				   
   if ( (lGuiResInt) ) { 
	   if ( (document.getElementById("cCritProc") != undefined) && (!isEmpty(document.getElementById("cCritProc").value)) ) {
		   //cTexto = atob(document.getElementById("cCritProc").value);
		   lExb = true;
	   } else if ( (window.frames[0].document.getElementById("cCritProc") != undefined) && (!isEmpty(window.frames[0].document.getElementById("cCritProc").value)) ){
		   //cTexto = atob(window.frames[0].document.getElementById("cCritProc").value);
		   lExb = true;
	   }
	   if (lExb) {  
		   cCores      = "white~#960000";
		   cTitulo     = "Atenção";
		   response[0] = "warning";

		   response[1] = response[1] + "<br> ATENÇÃO: A guia contêm algumas críticas! Consulte as críticas na tela de pesquisa de guias."
		   lGuiResInt  = false;
	   }
   }
   
   if(response[0] == "success"){
	   cCores = "white~#009652"
	   cTitulo = "Sucesso";
   }else if(response[0] == "warning"){
	   cCores = "white~#FABE3E";
	   cTitulo = "Alerta";
   }else{
	   cCores = "white~#960000";
	   cTitulo = "Falha";
	   window.frames[0].document.getElementById("bimprimir").disabled = true;
   }
				   
   if(response[0] != ""){			
	   modalBS(cTitulo, "<p>" + response[1] + "</p>", "@Fechar~closeModalBS();", cCores, "large");	
   }	
			   
}				
//Funcao para selecionar o item de um combobox a partir do 'value' desejado. Util para CODRDA, CODLOC, CBOS, etc.
function setSelectedValue(selectObj, valueToSet) {
   for (var i = 0; i < selectObj.options.length; i++) {
	   if (selectObj.options[i].value == valueToSet) {
		   selectObj.options[i].selected = true;
		   return;
	   }
   }
}

function fCarregaTabelaAltOdonto(aMatTabAux, aMatVal, cMostraSer) {

   //Para habilitar o click ou nao na tabela e pegar o nome da tabela
   var aMatTab  = aMatTabAux.split('$');
   var cTable 	 = aMatTab[0];
   var cTipoAcao= aMatTab[1];
   var cSeqCont = '0';

   //Carrega variaveis
   fMontMatGer('I', cTable);
   
   //Se vai carregar na matriz original ou vai espelhar em outra matriz
   if (cTipoAcao == '0') {
	   var aMatCampVal = '';
	   var aMatCol 	= aMatCap.split("|");

	   //Verifica toda a matriz com campos e valores para cada registro
	   for (var y = 0; y < aMatVal.length; y++) {
		   for (var x = 0; x < aMatVal[y].length; x++) {
			   var aMatColVal 	= aMatVal[y][x].split("!");
			   var cCampo 		= aMatColVal[0];
			   var cConteudo 	= aMatColVal[1];

			   //Procura o campo padrao no campo do form
			   for (var i = 0; i < aMatCol.length; i++) {
				   var aMatCampoForm = aMatCol[i].split("$");
				   if (aMatCampoForm[1]==cCampo) { 
					   cCampo = aMatCampoForm[0];
					   break;
				   }
			   }

			   if (cCampo == "cDentRegSE") {
				   cCampo = "cDenteReg";
			   } else if(cCampo == "cFaceSE") {
				   cCampo = "cFaceNova";
			   }
			   if (typeof cCampo != 'undefined' && document.getElementById(cCampo) != null) {
					if (document.getElementById(cCampo).type == "select-one"){     
					   setTC(document.getElementById(cCampo),"");
					   if (cConteudo != '-') {
						   var e = document.getElementById(cCampo);
						   var aIten = cConteudo.split("-");
						   e.options[0] = new Option(cConteudo, aIten[0]);
					   }
				   }else{
					   document.getElementById(cCampo).value = cConteudo;
					 }

				   //Matriz para compatibilizar tabelas exemplo. solicitacao com execucao.
				   //Como a quantidade de campos e diferente deve dizer onde o valor da
				   //solicitacao vai ficar na execucao
				   aMatCampVal += cCampo + "$" + cConteudo + "|"
			   }

			   if (cCampo == 'cSeqMov') {
				   cSeqCont = cConteudo;
			   }
		   }

   //Insere e limpa a linha
   IncLinhaTab(cTable, aMatCap, aMatBut, '', cCampoDefault, '1');
	   }	
   }    

   oTable = document.getElementById(cTable);                               

}

function gatilhoHiddenJS(cCampoHidden){
   var parentForm = parent.frames['principal'].document.forms[0];
   
   if((typeof parentForm) != "undefined" && (typeof parentForm[cCampoHidden]) != "undefined"){
	   if ( (parentForm['cTp'].value == "2" || parentForm['cTp'].value == "11" || parentForm['cTp'].value == "3" || parentForm['cTp'].value == "4") && cCampoHidden == "cProSol") {
		   //SADT e profissional solicitante
		   fProfSau(parentForm[cCampoHidden].value,'S');
	   }else{
		   //Profissional executante
		   //Para consulta (cTp == '1'), o campo é profsol mas é carregado como executante.
		   fProfSau(parentForm[cCampoHidden].value,'E');
	   }
   }
}

function vldBlqUsrZ1(oMat, oData){
   
   var cMat  = oMat.value;
   var cData = oData.value;
   var lGo   = validaCmp(oData,'data','Data invalida') && verificaDtRetro(oData);
   
   if (lGo){
	   Ajax.open("W_PPLVLBLBen.APW?cBenef=" + cMat + "&cDatPro=" + cData, {
		   callback: vldBlqUsrZ2,
		   error: ExibeErro
	   });
   }else{
	   document.getElementById(oData.id).value = "";
   }
}

function vldBlqUsrZ2(v){
   
   var lRet = v.split("|")[0];
   var msg = v.split("|")[1];
   
   if (lRet == "false" && msg != ""){
	   alert(msg);
	   document.getElementById('dDtExe').value = "";
	   document.getElementById('dDtExe').focus();
   }
   return lRet
}

function actionVoltar(){
   if (parent.window[0].document.getElementById('cTipoOrigem') != null && parent.window[0].document.getElementById('cTipoOrigem').value != "" && parent.window[0].document.getElementById('bVoltar') != null){
	   parent.window[0].document.getElementById('bVoltar').click();
   }
}

//====================================================
//FUNÇÕES Prorrogação
//====================================================
function fMontItProrrInt(cTp, cTable,nRecno) {
   cTpR 		 	 = cTp;
   cTableR 	 	 = cTable;
   var lResult 	 = false;
   var cRda 	 	 = document.getElementById('cRda').value;
   var cCodLoc		 = document.getElementById('cCodLoc').value;
   var cQueryString = "";
   var cChavAut 	 = document.getElementById("cNumAut").value;

   //Desabilita botoes
   setDisable("bIncTabSolSer",true);
   setDisable("bSaveTabSolSer",true);
   
   //--------------------------------------------------------------------
   // Monta conteudo das tabelas solicitacao e execucao
   //--------------------------------------------------------------------
   aMatAux = [["TabSolSer",oTabSolSer]];

   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento
   //--------------------------------------------------------------------
   cStringEnvTab = "";
   aMat = aMatAux;
   for (var i = 0; i < aMat.length; i++) {
	   aMatAux = aMat[i]
	   //Se o grid foi preenchido
	   if(typeof aMatAux[1] != "string" && aMatAux[1].aCols.length > 0){
		   //Recupera os dados do grid
		   oTable = aMatAux[1].getObjCols();

		   fMontMatGerInt('A', aMatAux[0]);

		   aMatCampAux = aMatCap.split("|");
		   for (var y = 1; y < oTable.rows.length; y++) {
			   nf = 0;
			   cStringEnvTab += "cSeq@"+getTC(oTable.rows[y].cells[0])+"$";
			   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {

				   cCampo = aMatCampAux[x - 2].split("$")[1];
				   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
					   celula = oTable.rows[y].cells[x + 1 - nf];

					   if (typeof celula.value == 'undefined' || celula.value == '')
							conteudo = getTC(celula);
					   else conteudo = celula.value;

					   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
				   }
				   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;
			   }
			   cStringEnvTab += "|";
		   }
	   }
   }

   //--------------------------------------------------------------------
   // Define parametros para uso na funcao de resultado
   //--------------------------------------------------------------------
   fMontMatGerInt(cTp, cTable);
   //--------------------------------------------------------------------
   // Matriz de campos
   //--------------------------------------------------------------------
   var aMatCol = aMatCap.split("|");
   e = eval("o"+cTable)
   if (e != "" && e.aCols.length > 0){
	   var oTable  = e.getObjCols();
   }else{
	   var oTable = null
   }

   //--------------------------------------------------------------------
   // Tratamento inclusao ou alteracao
   //--------------------------------------------------------------------
   if (cTp == 'I' || cTp == 'A') {
	   if (document.getElementById('cQtdSSol').value == "" || document.getElementById('cQtdSSol').value == "0") {
		   alert('Informe a quantidade de Serviço');
		   document.getElementById('cQtdSSol').focus();
		   //Habilita botoes
		   setDisable("bIncTabSolSer",false);
		   return;
	   }

	   //--------------------------------------------------------------------
	   // Atribui qtd sol para qtd aut
	   //--------------------------------------------------------------------
	   if (cTp == 'I')
		   document.getElementById('cQtdAutSSol').value = document.getElementById('cQtdSSol').value;

	   //--------------------------------------------------------------------
	   // Verifica duplicidade
	   //--------------------------------------------------------------------
	   var nCol 		  = 0;
	   if (typeof oTable != "string" && oTable != null){
		   var nQtdLinTab  = oTable.rows.length;
	   }else{
		   var nQtdLinTab = 0
	   }

	   var cString 	  = "1|";
	   var cContChave    = document.getElementById(cChave).value;
	   if (cContChave == "") {
		  alert("Serviço não informado");
		  document.getElementById(cChave).focus();
		  //Habilita botoes
		  setDisable("bIncTabSolSer",false);
		  return;
	   }

	   //--------------------------------------------------------------------
	   // Monta a sequencia e matriz de retorno
	   //--------------------------------------------------------------------
	   if (document.getElementById(aMatAux[1]) != null) {
		   if (typeof document.getElementById(aMatAux[1]).length != 'undefined') {
			   if (cTp == 'I')
					cString = String(document.getElementById(aMatAux[1]).length + 1) + "|";
			   else cString = String(document.getElementById(aMatAux[1]).length) + "|";
		   }
	   }
	   //--------------------------------------------------------------------
	   // Cbos do executante ou solicitante
	   //--------------------------------------------------------------------
	   cCbos = "";
	   if (cChavAut == '') {
		   cCbos = document.getElementById("cCbosSol").value;
	   }
	   //--------------------------------------------------------------------
	   // Monta envio das variaveis de sessao GET
	   //--------------------------------------------------------------------
	   cQueryString =	"&cRda="+cRda+
					   "&cCodLoc="+cCodLoc+
					   "&cProSol="+document.getElementById('cProSol').value+
					   "&cNumAut="+cChavAut+
					   "&cCbos="+cCbos+
					   "&cChvBD6="+document.getElementById('cChvBD6').value+
					   "&cChkPro="+( (cChavAut != "") ? '1' : '0' );

	   if (document.getElementById("cIndCliSol") != null) {
		   cQueryString += "&cIndCli="+(document.getElementById('cIndCliSol').value == "" ? "" : "1");
	   }

	   if (document.getElementById("cGuiaOpe") != null) {
		   cQueryString += "&cGuiaOpe="+document.getElementById('cGuiaOpe').value;
	   }

	   cCamGer = "";
	   for (var i = 0; i < aMatCol.length; i++) {
		   var aMatColAux = aMatCol[i].split("$");
		   cCampo = document.getElementById(aMatColAux[0]);
		   if (typeof cCampo != 'undefined' && cCampo != null && aMatNGet.indexOf(aMatColAux[1])==-1) {
			   cQueryString += "&" + aMatColAux[1] + "=" + cCampo.value;
		   }
	   }
	   
	   
	   //--------------------------------------------------------------------
	   // Verifica duplicidade												  
	   //--------------------------------------------------------------------
	   for (var i = 0; i < nQtdLinTab; i++) {
		  
		  for (var y = 0; y < aMatCol.length; y++) {
			   var aMatColAux = aMatCol[y].split("$");
			   if (aMatColAux[0] == cChave) {
				   nCol = y;
				   break;
			   }	
		   }
		   
		   if(cTp == 'A') nCol++;
		  
		   //--------------------------------------------------------------------
		   // Verfica se existe um registro igual na tabela						  
		   //--------------------------------------------------------------------
		   var lResult = false;   
		   if ( (cTp == 'I' || i+1 != parseInt(nRecno)) && getTC(oTable.rows[i].cells[nCol+2]) ==	cContChave) {
			   modalBS("Atenção", "<p>Este procedimento já foi informado, utilize o campo quantidade</p>", "@Fechar~closeModalBS();", "white~#960000", "large");
			   //Habilita botoes
			   setDisable("bIncTabSolSer",false);
			   return;
		   }
	   }
	   
	   //--------------------------------------------------------------------
	   // Validacoes
	   //--------------------------------------------------------------------
		 if ( cTable == "TabSolSer" && cTp == 'A') {
		   //--------------------------------------------------------------------
		   // Verifica se alguma campo que necessita de checar a regra novamente foi alterado
		   //--------------------------------------------------------------------
		   cSt = "0";
		   lResult = true;
		   for (var y = 3; y < oTable.rows[nRecno-1].cells.length; y++) {
			   var aMatColAux = aMatCol[y - 3].split("$");
			   cCampo = document.getElementById(aMatColAux[0]);
			   if ( getTC(oTable.rows[nRecno-1].cells[y]) != cCampo.value) {
				   cSt = "1";
				   if (aValAlt.indexOf(aMatColAux[0]) != -1) lResult = false;
			   }
		   }
		   
		   //--------------------------------------------------------------------
		   // Altera a tabela sem checar a regra novamente								  
		   //--------------------------------------------------------------------
		   if (lResult) {
				   fGetDadGen(nRecno, cTable ,4,true,cCampo.value,"",cCampoDefault.replace(/\|/g,","));
				   //Habilita botoes
				   setDisable("bIncTabSolSer",false);
				   return;
		   }
	   }

	   cString += aMatRet + "|" + cStringEnvTab + "|";
	   nRecnoX = nRecno;
	   //--------------------------------------------------------------------
	   // Executa o metodo
	   //--------------------------------------------------------------------
	   if (!lResult){
		   Ajax.open("W_PPLSAUTITE.APW?cString=" + cString + cQueryString, {
						   callback: CarregaMontItensInt,
						   error: ExibeErroInt
					  });
	   }
   }

   //--------------------------------------------------------------------
   // Calculo de valores primeiro campo recebe segundo campo o valor do
   // campo e pego da tabela
   //--------------------------------------------------------------------
   if (typeof aCalVal != 'undefined' && aCalVal != null) {
	   var aCalValAux = aCalVal.split("|");
	   for (var i = 0; i < aCalValAux.length; i++) {
		   if (aCalValAux[i] != "") {
			   var aMatCamp = aCalValAux[i].split("$");
			   //--------------------------------------------------------------------
			   // Para pegar os campos de informacao e recebimento
			   //--------------------------------------------------------------------
			   if (typeof aMatCamp[0] != 'undefined' && aMatCamp[0] != null && typeof aMatCamp[1] != 'undefined' && aMatCamp[1] != null) {
				   //--------------------------------------------------------------------
				   // Descobrir a coluna na tabela
				   //--------------------------------------------------------------------
				   for (var x = 0; x < aMatCol.length; x++) {
					   var aMatColAux = aMatCol[x].split("$");
					   if (aMatColAux[0] == aMatCamp[1]) {
						   nCol = x;
						   break;
					   }
				   }
				   if (cTp != 'I') nCol++;
				   //--------------------------------------------------------------------
				   // atualiza os campos com base no valor da tabela
				   //--------------------------------------------------------------------
				   var nValor = 0;
				   var cCampo = document.getElementById(aMatCamp[0]);
				   for (var x = 1; x < oTable.rows.length; x++) {
					   nValor += parseInt( getTC(oTable.rows[x].cells[nCol + 1]).replace(/\D/g, ""));
				   }
				   cCampo.value = MaskMoeda(nValor);
			   }
		   }
	   }
   }
}

//--------------------------------------------------------------------
// Processa
//--------------------------------------------------------------------
function fProcFormProrrInt(formulario) {
   var lDigOff = false;
   var lProrroga = false;

   document.forms[0].action = "W_PPLPROCGUI.APW";

   // Valida formulario
   //--------------------------------------------------------------------
   if( !valida() ) return;

   //--------------------------------------------------------------------
   // Verfica se foi digitado algum procedimento
   //--------------------------------------------------------------------
   var lVld = false;
   if (document.getElementById("cNumAut").value=="") {
	   if(typeof oTabSolSer == "string"){
		   lVld = true;
		   cMsg = 'Solicitação';
	   }
   } else {
	   cMsg = 'Prorrogação';
	   lProrroga = true;
	   if(typeof oTabProSer == "string"){
		   lVld = true;
	   } else {
		   lVld = true;
		var oTable  = oTabProSer.getObjCols();
	   if(oTable == null){
		 alert("Informe pelo menos uma prorrogação");
		 return;
	   }
		   for (var y = 0; y < oTable.rows.length; y++) {
			   lVld = false;
			   break
			   //}
		   }
	   }
   }
   
   //--------------------------------------------------------------------
   // Monta conteudo das tabelas solicitacao e execucao
   //--------------------------------------------------------------------
   if (document.getElementById("cNumAut").value=="")
	   aMatAux = "TabSolSer";
   else
	   aMatAux = "TabProSer";
   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento
   //--------------------------------------------------------------------
   cStringEnvTab = "";
   var nSeq 	  = 0;
   //--------------------------------------------------------------------
   // Pega a sequencia de maior numero
   //--------------------------------------------------------------------
   if (document.getElementById("cNumAut").value!="") {
	   var aMatAnt = "TabSolSer|TabProSer";
	   aMat 		= aMatAnt.split("|");

	   for (var i = 0; i < aMat.length; i++) {
		   e = eval("o" + aMat[i])
		   oTable = e.getObjCols();

		   for (var y = 1; y < oTable.rows.length; y++) {

				   if ( oTable.rows[y].innerHTML.indexOf('chkbox') == -1) {
				   if ( parseInt( getTC(oTable.rows[y].cells[0]) , 10 ) > nSeq ) {
					   nSeq = parseInt( getTC(oTable.rows[y].cells[0]) , 10 );
				   }
			   }
		   }
	   }
   }

   aMat = aMatAux.split("|");
   //--------------------------------------------------------------------
   // Monta envio para processamento
   //--------------------------------------------------------------------
   for (var i = 0; i < aMat.length; i++) {
	   e = eval("o" + aMat[i]);

	   if(e != "")
		   oTable = e.getObjCols();

	   fMontMatGerInt('A', aMat[i]);

	   aMatCampAux = aMatCap.split("|");
	   if(oTable != null){
		   for (var y = 0; y < oTable.rows.length; y++) {
			   nf = 0;
			   celula = oTable.rows[y].cells[4];
			   if ((!lProrroga) || (lProrroga && ( isEmpty(getTC(celula))  ))){

				   nSeq = nSeq + 1;

				   cStringEnvTab += "cSeq@" + parseInt( nSeq , 10 ) + "$";

				   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {

					   cCampo = aMatCampAux[x - 2].split("$")[1];
					   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
						   celula = oTable.rows[y].cells[x + 1 - nf];

						   if (typeof celula.value == 'undefined' || celula.value == '')
							   conteudo = getTC(celula);
						   else conteudo = celula.value;

						   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
					   }
					   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;
				   }
				   cStringEnvTab += "|";
			   }
		   }
	   }
   }

   //Roberto - Caso a prorrogação seja incluída sem item, o sistema irá incluir o item genérico.
   if (cStringEnvTab == ''){
	   cStringEnvTab += "cSeq@" + parseInt( 1 , 10 ) + "$";
	   cStringEnvTab += "cCodPad@" + "-1" + "$";
	   cStringEnvTab += "cCodPro@" + "-1" + "$";
	   cStringEnvTab += "cDesPro@" + "Procedimento Genérico para Inclusão de Prorrogação sem Procedimento." + "$";
	   cStringEnvTab += "nQtdSol@" + "1" + "$";
	   cStringEnvTab += "nQtdAut@" + "1" + "$";

	   cStringEnvTab += "|";
   }

   if (cStringEnvTab == ''){
	   alert("Informe pelo menos um serviço para a " + cMsg);
	   return; 
   }
   document.getElementById("cMatTabES").value = cStringEnvTab + "|";
   //--------------------------------------------------------------------
   // Trata Campos
   //--------------------------------------------------------------------
   setDisable("cCbosSol",false);
   setDisable("cCnpjSolT",false);
   setDisable("cNomeSolT",false);
   setDisable("cCnpjCpfSol",false);
   setDisable("cNomeRdaSol",false);

   setDisable("bIncTabProSer",true);
   setDisable("bconfirma",true);
   setDisable("bimprimir",false);
   setDisable("bAnexoDoc",false);
   setDisable("bcomplemento",false);
   //--------------------------------------------------------------------
   // Metodo de envio de formulario pelo ajax
   //--------------------------------------------------------------------
   Ajax.send(formulario, {
		   callback: CarregaProcFormInt,
		   error: ExibeErro
   });
   document.forms[0].action = "";
}

//Carrega o número do protocolo
function CarregaProtoc(v){
   var aResult = v.split("|");
   bProtoc = document.getElementById(aResult[1]);
   document.getElementById(aResult[2]).value = aResult[0];
   cProtocOri = v;
   document.getElementById(aResult[2]).readOnly = true;
   bProtoc.setAttribute("onclick","");
}


//Valida o numero do protocolo digitado, apenas quando for intercambio
function fVldProtoc(cProtoc, cMatric) {
   cMatric = typeof cMatric !== 'undefined' ? cMatric : 'cNumeCart';
   
   if (cMatric.substring(0,3) == 'B4A'){
	   cCampoRef = 'B4A_PROATE';
	   cCampoRefL = 'B4A_PROATE';
   } else {
	   cCampoRef = 'cProtoc';
	   cCampoRefL = 'cProtoc';
   }
   if(cProtoc.length != 0){
	   Ajax.open("W_PPLVLDPROT.APW?cProtoc=" + cProtoc + "&cMatric=" + document.getElementById(cMatric).value, { 
		   callback: true, 
		   error: ExibeErro,
		   showProc: false 
	   });
   }	 
} 

//Chama função que vai gerar protocolo, 
//Foi criada uma função diferenciada nos anexos devido a eles não possuirem usuário pré-estabelecido como na rotina de atendimento
function fGeraProtocAnexos(bId, cId) {
   if ( isEmpty(document.getElementById("B4A_PROATE").value) ) {
	   Ajax.open("W_PPLGETPATD.APW?bId=" + bId + "&cId=" + cId + "&lAnexos=" + true, { 
		   callback: CarregaProtoc,
		   error: ExibeErro 
	   });  
   }  
}

//Chama função que vai gerar protocolo, para a guia de Prorrogação de Internação
function fGeraProtocProrrogacao(bId, cId) {
   Ajax.open("W_PPLGETPATD.APW?bId=" + bId + "&cId=" + cId + "&lAnexos=" + true, { 
	   callback: CarregaProtoc,
	   error: ExibeErro 
   });    
}

//Chama função que vai gerar o número do protocolo de atendimento
//Caso seja um usuário de intercambio verifica se o parametro de integração está ativado, 
//se estiver chama Dialog para fazer a comunicação com a UNIMED origem
function fChamInterc(cMatric) {
   if(typeof cMatric == "undefined"){
	   cMatric = "";
   }

   Ajax.open("W_PPLVERINT.APW?cMatric=" + cMatric, { 
	callback: fCarregaIntegracao,
	error: ExibeErro 
});
   
}

function fCarregaIntegracao(v){
   var aResult = v.split("|");
   ChamaPoP('W_PPLINTPROTOC.APW?cMatric='+ aResult[0] ,'_bank', 'yes', 0, 700, 500);
}

//Valida se a data do procedimento é maior que a data de atendimento e se está dentro do limite máximo retroativo.
function fValidarDtOutDesp(cData){
   var lRet = true;
   
   if(document.getElementById("cTpGuiRef").value != "5"){
   if(verificaDtRetro(cData) && isObject("cDatAtd")){
	   //a data vem no formato dd/mm/aaaa e para fazer um new Date preciso fazer aaaa/mm/dd
	   var valEncDt = $("#cDatAtd").val();		
	   $.base64.utf8encode = true;
	   var parsedStr = ($.base64.decode(valEncDt));
	   var dtAtend = new Date(parsedStr.split("/").reverse().join("/"));
	   var dtInf = new Date(cData.value.split("/").reverse().join("/"));
	   if(dtAtend > dtInf){
		   alert("A data inserida é inferior à data de atendimento da guia principal.");
		   lRet = false;
		   document.getElementById(cData.id).value = "";
	   }
   }
   }else{
	   if(verificaDtRetro(cData)){
		   //a data vem no formato dd/mm/aaaa e para fazer um new Date preciso fazer aaaa/mm/dd
		   var valEncDt = $("#cDatAtd").val();	
		   var valDtIniFat = document.getElementById("cDatIniFat").value;
		   var valDtFimFat = document.getElementById("cDatFimFat").value;

		   var dtFatIni = new Date(valDtIniFat.split("/").reverse().join("/"));
		   var dtFatFim = new Date(valDtFimFat.split("/").reverse().join("/"));

		   var dtInf = new Date(cData.value.split("/").reverse().join("/"));


		   if(dtInf < dtFatIni){
			   alert("A data inserida é inferior a data de inicio de faturamento da guia principal.");
			   document.getElementById("dDtExe").value = "";
			   lRet = false;
		   }else if(dtInf > dtFatFim){
			   alert("A data inserida é superior a data de fim de faturamento da guia principal.");
			   document.getElementById("dDtExe").value = "";
			   lRet = false;
		   }
	   }		
   }
   
   if(!lRet) {
	   //Foi necessario usar desta forma pois o FIREFOX tem um BUG que nao suporta .focus()
	   globalvar = cData;
	   setTimeout("globalvar.focus()",250);
   }
   
   return lRet;
}

function vldDatLimOutDes(oData){

   var cData = oData.value;

   var lGo   = validaCmp(oData,'data','Data invalida') && verificaDtRetro(oData);
   
   if (lGo){
	   Ajax.open("W_PPLdtFut.APW?cDatPro=" + cData, {
		   callback: vldBlqUsrZ2,
		   error: ExibeErro
	   });
   }else{
	   document.getElementById(oData.id).value = "";
   }
}

//--------------------------------------------------------------------
// Exibe erros no processamento das funcoes						 	    
//--------------------------------------------------------------------
function ExibeErroJson(v) {
   var aResult = v.split("|");

   if (aResult[0] != "true" && aResult[0] != "false") alert("Erro: " + aResult[0])
   else {
	   if (aResult[0] == "false") {
		   modalBS("Atenção", aResult[1], "@Fechar~closeModalBS();", "white~#960000");
		   
		   //Essa função existe por causa desse if aqui em baixo
		   if((typeof lAddExec != 'undefined') && lAddExec){
			   lAddExec = false;
			   if (typeof oGuiaOff != 'undefined'){
				   oGuiaOff.executantes.pop();
			   }
		   }
		   else{
			   if (typeof oGuiaOff != 'undefined'){
				   oGuiaOff.procedimentos.pop();
			   }
			   
			   //Pro outras despesas também			
			   if (typeof oProcOutDesp != 'undefined'){
				   oProcOutDesp.procedimentos.pop();
			   }
		   }
		   
		   //--------------------------------------------------------------------
		   // Move o focu para o campo											  
		   //--------------------------------------------------------------------
		   if (typeof cCampoRef != 'undefined' && !document.getElementById(cCampoRef).disabled) document.getElementById(cCampoRef).focus();
		   //--------------------------------------------------------------------
		   // Limpa campo															  
		   //--------------------------------------------------------------------
		   if (typeof cCampoRefL != 'undefined' && cCampoRefL != '' && !document.getElementById(cCampoRefL).disabled) {
			   document.getElementById(cCampoRefL).value = "";
			   cCampoRefL = "";
		   }
		   //--------------------------------------------------------------------
		   // Ativa campo como obrigatorio										  
		   //--------------------------------------------------------------------
		   if (typeof cCampoRefObr != 'undefined') {
			   oForm.add(document.getElementById(cCampoRefObr), "tudo", false, false);
		   }
		   //--------------------------------------------------------------------
		   // Para controle de exclusao											  
		   //--------------------------------------------------------------------
		   if (typeof cCpoRegEsp != 'undefined' && typeof cCpoRegCon != 'undefined') {
			   document.getElementById(cCpoRegEsp).value += cCpoRegCon + '|';
		   }
	   }
   }
}

//--------------------------------------------------------------------
// Altera função do campo protocolo se for intercambio nas guias de anexo/honorarios					 	    
//--------------------------------------------------------------------
function changeProtocAnexos(v){
   var oForm = new xform( document.forms[0] );	
   var bProtoc = document.getElementById("BB4A_PROATE");
   if (typeof v == 'string'){ 		
	   oForm.add( document.forms[0].B4A_PROATE	,"numero", false, true );
	   //Comentado para processo WebServices RN 395, caso algum cliente aponte a necessidade de gerar o protocolo
	   //deve ser analisado a questão PTU Online x Protocolos RN 395
	   
	   //document.getElementById("B4A_PROATE").readOnly = false;
	   //document.getElementById("B4A_PROATE").value = "";
	   //bProtoc.setAttribute("onclick","fChamInterc(B4A_USUARI.value)"); 
   } else {
	   oForm.add( document.forms[0].B4A_PROATE	,"numero", false, false );
	   document.getElementById("B4A_PROATE").readOnly = true;
	   bProtoc.setAttribute("onclick",'fGeraProtocAnexos(this.id, "B4A_PROATE")');
	   document.getElementById("B4A_PROATE").onblur = "";
   }
   
}

//--------------------------------------------------------------------
// Altera função do campo protocolo se for intercambio nas guias de atendimento				 	    
//--------------------------------------------------------------------
function changeProtoc(v){

   if(typeof document.forms[0].cProtoc != "undefined") {
	   var oForm = new xform( document.forms[0] );	
	   var bProtoc = document.getElementById("BFuncProtoc");
	   if (typeof v == 'string'){ 		
		   oForm.add( document.forms[0].cProtoc	,"numero", false, true );
		   document.getElementById("cProtoc").readOnly = false;
		   document.getElementById("cProtoc").value = "";
		   bProtoc.setAttribute("onclick","fChamInterc()"); 
	   } else {
		   oForm.add( document.forms[0].cProtoc	,"numero", false, false );
		   bProtoc.setAttribute("onclick",'fGeraProtocAnexos(this.id, "cProtoc")');
		   document.getElementById("cProtoc").onblur = "";
	   }
   }
   
}

//------------------------------------------------
//Função utilizada para criptografar datas.
//------------------------------------------------
function CalcDateBase64(cDate){
   if(cDate != undefined && cDate != ""){
	   $.base64.utf8encode = true;
	   return ($.base64.encode(cDate));
   }else{
	   return "";
   }
}

function anexoDocGui(cNumAut, cTypeDoc, lIsModal){
   
   var lModal = false;
   
   if(typeof cNumAut != "undefined"){
       var lModal = typeof lIsModal != "undefined" ? lIsModal : true;
	   var cTpGui = typeof cTypeDoc != "undefined" ? cTypeDoc : window.frames["principal"].document.getElementById("cTp").value;
	   closeModalBS();
	   
   }else{
   
	   var cTpGui = (wasDef( typeof cTp) ? cTp.value : '1');
	   if(document.getElementById("cNumAut") != null  ){
		   var cNumAut = document.getElementById("cNumAut").value;
	   }
	   
   }
   
   //faço esse de/para por conta do combobox que existe na página de anexo de documentos
   var nTpGui = parseInt(cTpGui);
   if(nTpGui == 1 || nTpGui == 2 || nTpGui == 4){
	   cTpGui = "1";
   }else if(nTpGui == 3){
	   cTpGui = "2";
   }else if(nTpGui == 11){
	   cTpGui = "3";
   }else if(nTpGui == 7 || nTpGui == 9){
	   cTpGui = "4";
   }else if(nTpGui == 8 ){
	   cTpGui = "5";
   }
   
   if(lModal)
	   window.frames['principal'].location="W_PPLDOCG.APW?cChvPes=" + cTpGui + "|" + cNumAut;
   else
	   window.location="W_PPLDOCG.APW?cChvPes=" + cTpGui + "|" + cNumAut;
}                                                                                                                                                                                                                                

//------------------------------------------------
//Função utilizada para validar os campos obrigatórios
//------------------------------------------------
function fValCampoObrig(cTabela){ 

var nCount      = document.getElementsByTagName('input').length;
var cIdCampo    = '';
var cDescrCampo = '';
var i;
var cTabCampo = '';      

for (i = 0; i < nCount; i++) {
   
   if(document.getElementsByTagName("input")[i].getAttribute("type") == 'text') {
	   
	   cIdCampo = document.getElementsByTagName('input')[i].id;
	   cTabCampo = cIdCampo.substr(0, 3);
	   
	   if(document.getElementById(cIdCampo).parentNode.parentNode.textContent.indexOf('*') >= 0 && (cTabela == null || cTabela == cTabCampo)) {

		   if(document.getElementsByTagName('input')[i].value == ''){
			   
			   cDescrCampo = document.getElementById(cIdCampo).parentNode.parentNode.textContent.substr(0,document.getElementById(cIdCampo).parentNode.parentNode.textContent.search("\\*")).trim();
			   document.getElementById(cIdCampo).focus();
			   ShowModal("Atenção",'Campo obrigatório não preenchido [' + cDescrCampo + ']',true,false,true); 
			   
			   return false;
		   }
	   }
   }
}

return true;
}

//-----------------------------------------------------------------
//Função genérica para validar a quantidade de caracteres digitados
//-----------------------------------------------------------------
function fValQtdCarac(nQtdDigit,nFormatoCorreto,cMsg,lRetorno){  

var	cMsgExib = (cMsg == "" || cMsg == undefined ? "Número de dígitos da guia incorreto. <br/> Quantidade digitada: " + nQtdDigit.toString().length + "<br/> Quantidade necessária: " + nFormatoCorreto.toString(): cMsg);
var lRet     = (lRetorno == "" || lRetorno == undefined ? false : lRetorno);

if(nQtdDigit.length > 0 && nFormatoCorreto > 0){
   
   if(nQtdDigit.length < nFormatoCorreto){
	   
	   ShowModal("Atenção",cMsgExib,true,false,true,"actionVoltar();");
	   return lRet;
   }else{
	   return !lRet;
   }
	   
}else{
   return true;
}
}

//-----------------------------------------------------------------
//Função para chamar a F3 das guias no portal, no campo da B7B estava ficando muito grande
//-----------------------------------------------------------------
function f3ProfGuia(nTpGui, lExec){

   //Executante SADT_______________________________________________________________________________________________________
   if(nTpGui == 2 && wasDef( typeof lExec) && lExec){
	   return ChamaPoP('W_PPLSXF3.APW?cFunName=PLF3PROF&F3Nome=cProExeDesc&cCampoOri=cProExe&cVldGen='+cRda.value+'|'+cCodLoc.value+'&F3CmpDes=cProExe,cProExeDesc&BuscaEsp=3;Número C.R.&NoCod=1','jF3','yes');
   }
   
   //Executante Honorario__________________________________________________________________________________________________
   if(nTpGui == 6 && wasDef( typeof lExec) && lExec){
	   return ChamaPoP('W_PPLSXF3.APW?cFunName=PLF3PROF&F3Nome=cProExeDesc&cCampoOri=cProExe&cVldGen='+cRda.value+'|'+cCodLoc.value+'&F3CmpDes=cCpfExe,cProExeDesc,cCodSigExe,cNumCrExe,cEstSigExe,cCpfExe&BuscaEsp=3;Numero C.R.','jF3','yes');  
   }
   
   switch(nTpGui) {
	   //Consulta_______________________________________________________________________________________________________
	   case 1:
		   return ChamaPoP('W_PPLSXF3.APW?cFunName=PLF3PROF&F3Nome=cProSolDesc&cCampoOri=cProExe&cVldGen='+cRda.value+'|'+cCodLoc.value+'&F3CmpDes=cProSol,cProSolDesc&BuscaEsp=3;Número C.R.&NoCod=1&DefaultBusca=3','jF3','yes');
		   break;
	   //SADT__________________________________________________________________________________________________________
	   case 2:
		   return ChamaPoP('W_PPLSXF3.APW?cFunName=PLF3PROF&F3Nome=cProSolDesc&cCampoOri=cProSol&cVldGen='+cRda.value+'|'+cCodLoc.value+'&F3CmpDes=cProSol,cProSolDesc&BuscaEsp=3;Número C.R.&NoCod=1&DefaultBusca=3','jF3','yes');
		   break;
	   //Internação_______________________________________________________________________________________________________
	   case 3:
		   return ChamaPoP('W_PPLSXF3.APW?cFunName=PLF3PROF&F3Nome=cProSolDesc&cCampoOri=cProSol&cVldGen='+cRda.value+'|'+cCodLoc.value+'&F3CmpDes=cProSol,cProSolDesc&BuscaEsp=3;Número C.R.&NoCod=1&DefaultBusca=3','jF3','yes');
		   break;
	   //Honorário________________________________________________________________________________________________________
	   case 6:
		   return ChamaPoP('W_PPLSXF3.APW?cFunName=PLF3PROF&F3Nome=cProExeDesc&cCampoOri=cProExe&cVldGen='+cRda.value+'|'+cCodLoc.value+'&F3CmpDes=cProSol,cProExeDesc,cCodSigExe,cNumCrExe,cEstSigExe,cCpfExe&BuscaEsp=3;Número C.R.&NoCod=1&DefaultBusca=3','yes');
		   break;
	   //Anexo OPME_____________________________________________________________________________________________________
	   case 7:
		   return ChamaPoP('W_PPLSXF3.APW?cFunName=PLF3PROF&F3Nome=B4A_NOMSOL&cCampoOri=B4A_NOMSOL&cVldGen=ANC&F3CmpDes=B4A_NOMSOL&BuscaEsp=3;Número C.R.&NoCod=1&DefaultBusca=3','jF3','yes');
		   break;
	   //Anexo Quimio_____________________________________________________________________________________________________
	   case 8:
		   return ChamaPoP('W_PPLSXF3.APW?cFunName=PLF3PROF&F3Nome=B4A_NOMSOL&cCampoOri=B4A_NOMSOL&cVldGen=ANC&F3CmpDes=B4A_NOMSOL&BuscaEsp=3;Número C.R.&NoCod=1&DefaultBusca=3','jF3','yes');
		   break;
	   //Anexo Radio______________________________________________________________________________________________________
	   case 9:
		   return ChamaPoP('W_PPLSXF3.APW?cFunName=PLF3PROF&F3Nome=B4A_NOMSOL&cCampoOri=B4A_NOMSOL&cVldGen=ANC&F3CmpDes=B4A_NOMSOL&BuscaEsp=3;Número C.R.&NoCod=1&DefaultBusca=3','jF3','yes');
		   break;
	   //Prorrogação_______________________________________________________________________________________________________
	   case 11:
		   return ChamaPoP('W_PPLSXF3.APW?cFunName=PLF3PROF&F3Nome=cProSolDesc&cCampoOri=cProSol&cVldGen='+cRda.value+'|'+cCodLoc.value+'&F3CmpDes=cProSol,cProSolDesc&BuscaEsp=3;Número C.R.&NoCod=1&DefaultBusca=3','jF3','yes');
		   break;		
   }

}

//--------------------------------------------------------------------
// Processa Formulário de Resumo de Internação 															  
//--------------------------------------------------------------------
function fProcFormResInt(formulario) {
   var aMatAux2 = "";
   var lDigOff = false;
   var cMatAux = "";
   var cMatAux2 = "";
   var x = document.getElementById('cMsnBloInt').value;

   //--------------------------------------------------------------------
   // Verfica se foi digitado algum procedimento							   
   //--------------------------------------------------------------------
   lVld = false;

   if ( typeof oTabExeSer == "string") {  
	   lVld = true;
	   cMsg = "Informe pelo menos um procedimento";
   } 


   //--------------------------------------------------------------------
   // aviso																   
   //--------------------------------------------------------------------
   if (lVld) {
	   ShowModal("Atenção", cMsg, true, false, true, "");
	   return;
   }


   //--------------------------------------------------------------------
   // ValiDa formulario													   
   //--------------------------------------------------------------------
   if( !valida() ) return;

   if (isDitacaoOffline())
   {	
	   lDigOff = true;
//		modalBS('<i class="fa fa-exclamation-triangle" style="font-weight: bold; color: #000; text-shadow: 0 1px 0 #fff; filter: alpha(opacity=20); opacity: .2;"></i>&nbsp;&nbsp;&nbsp;Alerta', '<p>Tem certeza que deseja finalizar a guia?</p>', "@Sim, conclui a digitação!~confirmaSADT('1')@Não, desejo continuar posteriormente!~confirmaSADT('2');", "white~ #f8c80a", "large","N");	
   } else {
	   document.forms[0].action = "W_PPLPROCGUI.APW";
   }


   //--------------------------------------------------------------------
   // Monta conteudo das tabelas	solicitacao e execucao					  
   //--------------------------------------------------------------------
   if(lDigOff){
	   aMatAux = ["TabExeSer",oTabExeSer];
	   aMatAux2 = ["TabExe",oTabExe];
   }

   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   aMat   		  = aMatAux;
   cStringEnvTab = "";

   for (var i = 0; i < aMat.length; i++) {
	   aInfoAux = aMat
	   if (typeof aInfoAux[i] != "undefined" && typeof aInfoAux[i] != "string" && aInfoAux[i].aCols.length > 0) {
		   //Pega o nome do grid
		   oTable = aInfoAux[1].getObjCols();
		   //Associa a coluna com a variável do post
		   fMontMatGer('A', aInfoAux[0]);
		   aMatCampAux = aMatCap.split("|");

		   for (var y = 0; y < oTable.rows.length; y++) {
			   nf = 0;

			   cStringEnvTab += "cSeq@" + (++y) + "$";
			   --y;


				 for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {

					 cCampo = aMatCampAux[x - 2].split("$")[1];
				   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo) == -1) {
					   celula = oTable.rows[y].cells[x + 1 - nf];

						  if (typeof celula.value == 'undefined' || celula.value == '')
							  conteudo = getTC(celula);
						  else
							  conteudo = celula.value;

					   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
				   }

				   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo')
					   nf += 1;			  		
				 }

				 cStringEnvTab += "|";
		   }
	   }
   }

   document.getElementById("cMatTabES").value = cStringEnvTab + "|";

   //Monta variável do grid de executantes	
   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   if(aMatAux2 != ""){
	   aMat   		  = aMatAux2;
	   cStringEnvTab = "";

	   for (var i = 0; i < aMat.length; i++) {

		   aInfoAux = aMat 
		   if ( typeof aInfoAux[i] != "undefined" && typeof aInfoAux[i] != "string" && aInfoAux[i].aCols.length > 0 ){ 
			   //Pega o nome do grid
			   oTable = aInfoAux[1].getObjCols();
			   //Associa a coluna com a variável do post
			   fMontMatGer('A', aInfoAux[0]);
			   aMatCampAux = aMatCap.split("|");    

			   for (var y = 0; y < oTable.rows.length; y++) {
				   nf 	 = 0;

				   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {						
					   cCampo = aMatCampAux[x - 2].split("$")[1];

					   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
						   celula = oTable.rows[y].cells[x + 1 - nf];

						   if (typeof celula.value == 'undefined' || celula.value == '')
							   conteudo = getTC(celula);
							else
								  conteudo = celula.value;

						   cStringEnvTab += cCampo + "@" + conteudo.split("*")[0] + "$";
					   }

						 if (aMatCampAux[x - 2].split("$")[0] == 'cfixo')
							nf += 1;
				   }

				   cStringEnvTab += "|";
			   }
		   }			
	   }
   }

   document.getElementById("cMatTabExe").value = cStringEnvTab + "|";

   //--------------------------------------------------------------------
   // Trata campos														  
   //--------------------------------------------------------------------
   setDisable("cIndCliSol",false);
   setDisable("cCbosSol",false);
   setDisable("cCbosExe",false);
   setDisable("cProSolDesc",false);
   setDisable("cProExeDesc",false);
   setDisable("bconfirma",true);
   setDisable("bcomplemento",false);
   setDisable("bimprimir",false);
   setDisable("bAnexoDoc",false);

   if(!lDigOff){
	   Ajax.send(formulario, { 
			   callback: CarregaProcForm,
			   error: ExibeErro 
	   });
   }else{
	   lGuiResInt = true;
	   modalBS('<i class="fa fa-exclamation-triangle" style="font-weight: bold; color: #000; text-shadow: 0 1px 0 #fff; filter: alpha(opacity=20); opacity: .2;"></i>&nbsp;&nbsp;&nbsp;Alerta', '<p>Tem certeza que deseja finalizar a guia?</p>', "@Sim, conclui a digitação!~confirmaHon('1')@Não, desejo continuar posteriormente!~confirmaHon('2');", "white~ #f8c80a", "large","N");	
   }

   document.forms[0].action = "";

   if( isDitacaoOffline() && isAlteraGuiaAut() ){
	   document.getElementById("bconfirma").disabled = true;
   }

   //--------------------------------------------------------------------
   // Desabilita os campos												  
   //--------------------------------------------------------------------
   FDisElemen('TabExeSer|bIncTabExeSer|bSaveTabExeSer',true);
}


//--------------------------------------------------------------------
// Monta tabela de procedimento e quantidades linha a linha (autorizacao) 
//--------------------------------------------------------------------
function fMontItensResInt (cTp, cTable,nRecno) {
   var rowCount = $('#tabTabExeSer tr').length;
   var cNumGuiTrc = (document.getElementById("cNumGuiRef").value).split("|")[1];
   var cNumGuiRes = document.getElementById("cNumGuiRes").value;
   var aNum;
   var cCodOpe = "";
   var cCodLdp = "";
   var cCodPeg = "";
   var cNumero = "";


   if(cNumGuiRes != ""){
	   aNum = cNumGuiRes.split(";");
	   cCodOpe = aNum[0];
	   cCodLdp = aNum[1];
	   cCodPeg = aNum[2];
	   cNumero = aNum[3];
   }

   cTpR 		 = cTp;
   cTableR 	 = cTable;
   cQueryString = "&cRda=" + document.getElementById('cRda').value + "&cCodLoc=" + document.getElementById('cCodLoc').value;

   //--------------------------------------------------------------------
   // Monta conteudo das tabelas solicitacao e execucao					  
   //--------------------------------------------------------------------
   if (cTable == "TabExeSer") 
	   aMatAux = "TabExeSer$oTabExeSer";
   //--------------------------------------------------------------------
   // Carrega as linhas das tabelas para processamento					   
   //--------------------------------------------------------------------
   cStringEnvTab = "";
   aMat = aMatAux.split("|");
   var x = document.getElementById('cMsnBloInt').value;

   if ( (document.getElementById('cGuiaInter').value == "") && x != "" ) {
	   alert('Informe a Guia Principal');
	   document.getElementById('cGuiaInter').focus();
	   return;
   } 
   if ( (document.getElementById('dDataIniFat').value == "") || (document.getElementById('dDataFimFat').value == "") ) {
	   alert('Informe a data inicial e final de faturamento!');
	   return;
   }

   if ( ValDatResInt((document.getElementById('dDtExe')), '2') ) {
	   return;
   }


   for (var i = 0; i < aMat.length; i++) {
	   aMatAux = aMat[i].split("$")
	   //Se o grid foi preenchido
	   if(typeof eval(aMatAux[1]) != "string" && eval(aMatAux[1]).aCols.length > 0){
		   //Recupera os dados do grid
		   oTable = eval(aMatAux[1]).getObjCols();
		   //oTable = document.getElementById(aMat[i]);

		   fMontMatGer('A', aMatAux[0]);

		   aMatCampAux = aMatCap.split("|");
		   for (var y = 1; y < oTable.rows.length; y++) {
			   nf = 0;                  
			   cStringEnvTab += "cSeq@"+getTC(oTable.rows[y].cells[0])+"$";
			   for (var x = 2; x < (oTable.rows[y].cells.length + nf - 1); x++) {

				   cCampo = aMatCampAux[x - 2].split("$")[1];
				   if (cCampo != "NIL" && aMatNGet.indexOf(cCampo)==-1) {
					   celula = oTable.rows[y].cells[x + 1 - nf];

					   if (typeof celula.value == 'undefined' || celula.value == '')
							conteudo = getTC(celula);
					   else conteudo = celula.value;	

					   cStringEnvTab += cCampo + "@" + conteudo + "$";
				   }
				   if (aMatCampAux[x - 2].split("$")[0] == 'cfixo') nf += 1;
			   }      
			   cStringEnvTab += "|";
		   }
	   }
   }
   //--------------------------------------------------------------------
   // Define parametros para uso na funcao de resultado					  
   //--------------------------------------------------------------------
   fMontMatGer(cTp, cTable);
   //--------------------------------------------------------------------
   // Matriz de campos													  
   //--------------------------------------------------------------------
   var aMatCol = aMatCap.split("|");
   if (eval(aMatAux[1]) != "" && eval(aMatAux[1]).aCols.length > 0){
	   var oTable  = eval(aMatAux[1]).getObjCols();//document.getElementById(aMatAux[1]);
   }else{
	   var oTable = null
   }
   //--------------------------------------------------------------------
   // Tratamento inclusao ou alteracao									  
   //--------------------------------------------------------------------
   if (cTp == 'I' || cTp == 'A') {
	   switch (cTable) {
		   case "TabSolSer":
			   if (document.getElementById('cQtdSSol').value == "" || document.getElementById('cQtdSSol').value == "0") {
				   alert('Informe a quantidade de Serviço');
				   document.getElementById('cQtdSSol').focus();
				   return;
			   }               
			   if (cTp == 'I')
				   document.getElementById('cQtdAutSSol').value = document.getElementById('cQtdSSol').value;
			   break;   
		   case "TabExeSer":
			   if (document.getElementById('cQtdSExe').value == "" || document.getElementById('cQtdSExe').value == "0") {
				   alert('Informe a quantidade de Serviço');   
				   document.getElementById('cQtdSExe').focus();
				   return;
			   }
			   if (document.getElementById('nVlrUniSExe').value == "" || (parseFloat(document.getElementById('nVlrUniSExe').value.replace(",","")) <= 0) ) {
				   alert('Informe o valor do serviço.');   
				   document.getElementById('nVlrUniSExe').focus();
				   return;
			   }
			   if (document.getElementById('cCodPadSExe').value == "" ) { 
				   alert('Informe o código da Tabela.');   
				   document.getElementById('cCodPadSExe').focus();
				   return;
			   }	

			   if (document.getElementById('cCodProSExe').value == "" ) {
				   alert('Informe o código do Procedimento.');   
				   document.getElementById('cCodProSExe').focus();
				   return;
			   }	
			   break;

		   }
	   //--------------------------------------------------------------------
	   // Verifica duplicidade												   
	   //--------------------------------------------------------------------
	   var nCol 		= 0;
	   if (typeof oTable != "string" && oTable != null){
		   var nQtdLinTab  = oTable.rows.length;
	   }else{
		   var nQtdLinTab = 0;
	   }
	   var cString 	= '1'+"|";
	   var cContChave  = document.getElementById(cChave).value;
	   if (cContChave == "") {
		  alert("Serviço não informado");
		  document.getElementById(cChave).focus();
		  return;
	   }
	   //--------------------------------------------------------------------
	   // Monta a sequencia e matriz de retorno								   
	   //--------------------------------------------------------------------
	   if (document.getElementById(aMatAux[1]) != null) {
		   if (typeof document.getElementById(aMatAux[1]).length != 'undefined') {
			   if (cTp == 'I') 
					cString = String(document.getElementById(aMatAux[1]).length + 1) + "|";
			   else cString = String(document.getElementById(aMatAux[1]).length) + "|";
		   }
	   }
	   //--------------------------------------------------------------------
	   // Cbos do executante								  
	   //--------------------------------------------------------------------
		   cCbos = document.getElementById("cCbosExe").value;

	   //--------------------------------------------------------------------
	   // Monta envio das variaveis de sessao GET								  
	   //--------------------------------------------------------------------
	   cQueryString =	"&cRda="+document.getElementById('cRda').value+
					   "&cCodLoc="+document.getElementById('cCodLoc').value+
					   "&cProSol="+document.getElementById('cProSol').value+
					   "&cProExe="+document.getElementById('cProExe').value+
					   "&cNumAut="+document.getElementById('cGuiaInter').value+
					   "&cCbos="+cCbos+
					   "&cAteRN="+document.getElementById('cAtendRN').value+
					   "&cChvBD6="+document.getElementById('cChvBD6').value+
					   "&cCarSolicit="+document.getElementById('cCarSolicit').value+
					   "&cCnes="+document.getElementById('cCnes').value+
					   "&cCid="+document.getElementById('cCid').value+ 
					   "&cCid2="+document.getElementById('cCid2').value+ 
					   "&cCid3="+document.getElementById('cCid3').value+ 
					   "&cCid4="+document.getElementById('cCid4').value+ 
					   "&cCidObt="+document.getElementById('cCidObt').value+ 
					   "&cTpSai="+document.getElementById('cTpSai').value+
					   "&cTipFaT="+document.getElementById('cTipFat').value+ 
					   "&cIndAcid="+document.getElementById('cIndAcid').value+ 
					   "&cTpIntern="+document.getElementById('cTpIntern').value+ 
					   "&cNumInt="+document.getElementById('cGuiaInter').value+
					   "&dDataIniFat="+document.getElementById('dDataIniFat').value+
					   "&cHorIniFat="+document.getElementById('cHorIniFat').value+
					   "&dDataFimFat="+document.getElementById('dDataFimFat').value+
					   "&cHorFimFat="+document.getElementById('cHorFimFat').value+
					   "&cCodOpe="+cCodOpe+
					   "&cCodLdp="+cCodLdp+
					   "&cCodPeg="+cCodPeg+
					   "&cNumero="+cNumero+
					   "&cSequen="+(nQtdLinTab+1)+
					   "&cNumGuiTrc="+cNumGuiTrc+ 
					   "&cOperacao="+cTp+ 
					   "&cRegInter="+document.getElementById('cRegInter').value+
					   "&cObserv="+document.getElementById('cObs').value+
					   "&cPadCon="+document.getElementById('cPadConfSol').value+
					   "&cTpAcom="+document.getElementById('cTpAcomSol').value+
					   "&cVlrUniSExe="+document.getElementById('nVlrUniSExe').value;     		


	   cCamGer = "";
	   var objSubJson = "{";
	  for (var i = 0; i < aMatCol.length; i++) {
		   var aMatColAux = aMatCol[i].split("$");
		   cCampo = document.getElementById(aMatColAux[0]);
		   if (typeof cCampo != 'undefined' && cCampo != null && aMatNGet.indexOf(aMatColAux[1])==-1) {
			   cQueryString += "&" + aMatColAux[1] + "=" + cCampo.value;

			   if(typeof oGuiaOff != 'undefined'){
				   if(cTp == 'I'){
					   objSubJson += '"' + aMatColAux[1] + '"' + ':{ "defaultValue" : ' + '"' + cCampo.value.trim() + '"' + ', "actualValue": ' + '"' + cCampo.value.trim() + '"}';
					   objSubJson += ","
				   }else{
					   objSubJson = getObjects(oGuiaOff, "sequen",nRecno);
					   if(objSubJson.length > 0){
						   objSubJson = objSubJson[0];
						   if(objSubJson[aMatColAux[1]] != undefined){ 
							   objSubJson[aMatColAux[1]].actualValue = cCampo.value.trim();
						   }
					   }
				   }
			   }

		   }
	   }

	   if(cTp == 'I'){
		   if ( !(isAlteraGuiaAut()) ) {
			   objSubJson +=  '"cSeqMov" :{ "defaultValue" : ' + '"' + (typeof eval(aMatAux[1]) != "string" ? (eval(aMatAux[1]).aCols.length+1).toString() : "1")  + '"' + ', "actualValue": ' + '"' + (typeof eval(aMatAux[1]) != "string" ? (eval(aMatAux[1]).aCols.length+1).toString() : "1") + '"},';
		   }
		   objSubJson +=  '"sequen":' + '"' + (typeof eval(aMatAux[1]) != "string" ? (eval(aMatAux[1]).aCols.length+1).toString() : "1") + '",';
		   objSubJson +=  isAlteraGuiaAut() ? '"lNewIte":false,' : '"lNewIte":false,'; // Se não for alteração, coloco newitem como false pois no resumo o item é gravado na base assim que inserido no grid
		   objSubJson +=  '"lDelIte":false}';
	   }
	   //--------------------------------------------------------------------
	   // Verifica duplicidade												  
	   //--------------------------------------------------------------------
	   /*for (var i = 0; i < nQtdLinTab; i++) {
		   for (var y = 0; y < aMatCol.length; y++) {
			   var aMatColAux = aMatCol[y].split("$");
			   if (aMatColAux[0] == cChave) {
				   nCol = y;
				   break;
			   }	
		   }
		   if (cTp == 'A') nCol++;
		   //--------------------------------------------------------------------
		   // Verfica se existe um registro igual na tabela						  
		   //--------------------------------------------------------------------
		   var lResult = false;   
		   if (i+1 != parseInt(nRecno) && getTC(oTable.rows[i].cells[nCol+2]) ==	cContChave) {
			   //--------------------------------------------------------------------
			   // verifica se algum campo foi alterado			   					   
			   //--------------------------------------------------------------------
			   if (oTable.rows[i].style.backgroundColor != "") {
				   cSt = "0";
				   //--------------------------------------------------------------------
				   // Verifica se alguma campo que necessita de checar a regra novamente foi alterado
				   //--------------------------------------------------------------------
				   lResult = true;

				   var ldata   = false;
				   var lcodpro = false;
				   var lcodtab = false;

				   for (var y = 2; y < oTable.rows[i].cells.length; y++) {
					   if (aMatCol[y - 2] != undefined){
						   var aMatColAux = aMatCol[y - 2].split("$");
						   cCampo = document.getElementById(aMatColAux[0]);
						   if (cCampo != null){
							   if (getTC(oTable.rows[i].cells[3]) == cCampo.value){
								   ldata   = true;
							   }
							   if (getTC(oTable.rows[i].cells[6]) == cCampo.value){
								   lcodtab   = true;
							   }	
							   if (getTC(oTable.rows[i].cells[7]) == cCampo.value){
								   lcodpro   = true;
							   }						
						   }
						   if (cCampo != undefined && getTC(oTable.rows[i].cells[y]) != cCampo.value) {
							   cSt = "1";
							   if (aValAlt.indexOf(aMatColAux[0]) != -1) lResult = false;
						   }
					   }
				   }
				   //--------------------------------------------------------------------
				   // Altera a tabela sem checar a regra novamente								  
				   //--------------------------------------------------------------------
				   if (lResult) {
					   fGetDadGen(nRecno, cTable ,4,true,cCampo.value,"",cCampoDefault.replace(/\|/g,","));
					   //AltLinhaTab(cTable, aMatCap, aMatBut, cSt, "", cCampoDefault);
					   if (lcodpro && lcodtab &&ldata)
					   {
						   alert("Procedimento já inserido! Para informar mais de um procedimento na mesma data, utilize o campo de Quantidade");
					   }
					   return;
				   }
			   } else {
				   if (cTp != 'A'){ 
					   console.log("já existe este registro"); 
					   return;
				   }
			   }
		   }
	   }*/
	   cString += aMatRet + "|" + cStringEnvTab + "|"; 

	   if ((cTp == "I") && (typeof oGuiaOff != 'undefined'))
		   oGuiaOff.procedimentos.push(JSON.parse(objSubJson));
	   //--------------------------------------------------------------------
	   // Executa o metodo													  
	   //--------------------------------------------------------------------
		
	   lGuiResInt = true;
	   Ajax.open("W_PPLSAUTITE.APW?cString=" + cString + cQueryString, { 
					   callback: CarregaMontItensSADT,
					   error: ExibeErroJson 
				  });
	   
   }
   //--------------------------------------------------------------------
   // Calculo de valores primeiro campo recebe segundo campo o valor do	  
   // campo e pego da tabela												  
   //--------------------------------------------------------------------
   if (typeof aCalVal != 'undefined' && aCalVal != null) {
	   var aCalValAux = aCalVal.split("|");
	   for (var i = 0; i < aCalValAux.length; i++) {
		   if (aCalValAux[i] != "") {
			   var aMatCamp = aCalValAux[i].split("$");
			   //--------------------------------------------------------------------
			   // Para pegar os campos de informacao e recebimento					  
			   //--------------------------------------------------------------------
			   if (typeof aMatCamp[0] != 'undefined' && aMatCamp[0] != null && typeof aMatCamp[1] != 'undefined' && aMatCamp[1] != null) {
				   //--------------------------------------------------------------------
				   // Descobrir a coluna na tabela										  
				   //--------------------------------------------------------------------
				   for (var x = 0; x < aMatCol.length; x++) {
					   var aMatColAux = aMatCol[x].split("$");
					   if (aMatColAux[0] == aMatCamp[1]) {
						   nCol = x;
						   break;
					   }
				   }
				   if (cTp != 'I') nCol++;
				   //--------------------------------------------------------------------
				   // atualiza os campos com base no valor da tabela						  
				   //--------------------------------------------------------------------
				   var nValor = 0;
				   var cCampo = document.getElementById(aMatCamp[0]);
				   for (var x = 1; x < oTable.rows.length; x++) {
					   nValor += parseInt(getTC(oTable.rows[x].cells[nCol + 1]).replace(/\D/g, ""));
				   }
				   cCampo.value = MaskMoeda(nValor);
			   }
		   }
	   }
   }
}


//--------------------------------------------------------------------
// Função de LOAD da Guia de Resumo de Internação													  
//--------------------------------------------------------------------
function RESINTLoad(){
   var cNumGuiSol = document.getElementById("cNumGuiRef").value;

   cPasgridCe = document.getElementById("cTp").value;
   setDisable("bimprimir",true);	
   if(cNumGuiSol.split("|")[0].length == 21)
	   document.getElementById("cGuiaInter").value = cNumGuiSol.split("|")[0];
   else
   document.getElementById("cGuiaInter").value = cNumGuiSol.substr(0, 4) + "." + cNumGuiSol.substr(4, 4) + "." + cNumGuiSol.substr(8, 2) + "-" + cNumGuiSol.substr(10, 8); //Numero da autorizacao

   if ( !(isAlteraGuiaAut()) ) {
	   if (cNumGuiSol == ""){
		   alert("Informe o número da Guia de Sol. Internação.");
	   }else{

		   Ajax.open("W_PPLSHON.APW?cNumeAut=" + cNumGuiSol.replace(/\D/g, "") + "&cTp=" + '3', {
			   callback: CarregaResInt,
			   error: ExibeErro
		   });
	   }
   }
   //to do

   //--------------------------------------------------------------------
   // Carrega eventos dos campos
   //--------------------------------------------------------------------
   var oForm = new xform( document.forms[0] );
   oForm.add( document.forms[0].cCodPadSExe	,"numero", false, true );
   oForm.add( document.forms[0].cCodProSExe		,"numero", false, true );
   oForm.add( document.forms[0].cQtdSExe			,"numero", false, true );

   //--------------------------------------------------------------------
   // Carrega dados da rda												   
   //--------------------------------------------------------------------
   if( isDitacaoOffline() && isAlteraGuiaAut() ){
	   var cRecno = $("#cRecnoBD5").val();
	   lGuiResInt = true;
	   Ajax.open("W_PPLCHAALT.APW?cRecno="+ cRecno + "&cTipGui=5" , { callback : fRespostaHon, error : exibeErro });	
   }else{

	   fExe();
	   setDisable("bimprimir",true);
	   //fRdaHon(document.getElementById("cRda").value,document.getElementById("cCodLoc").value);
	   alterarCamposGuias();
  }
}


//--------------------------------------------------------------------
// Carrega os dados do Resumo de Internação, baseado no número da Guia														  
//--------------------------------------------------------------------
function CarregaResInt(v){
   var aMatCabIte = v.split("<");
   var aMatCab = aMatCabIte[0].split("|");

   var objJson = '{ ';	
   var objSubJsonCabec = "";
   var objSubJsonProc = "";
   var objSubJsonExec = "";
   var aJsonCamposCabec = new Array();	

   _$Forminputs = $('form :input:not([type=submit][type=button])');

   for (var i = 0; i < _$Forminputs.length; i++) {

	   $(_$Forminputs[i]).data('default', $(_$Forminputs[i]).val());
   }  

   //--------------------------------------------------------------------
   // Verifico se a estrutura dos itens foram enviadas
   //--------------------------------------------------------------------
   if (typeof aMatCabIte[1] == "undefined") {
	   alert("Estrutura indefinida");
	   return;
   }

   var aMatIte = aMatCabIte[1].split("~");

   if (typeof aMatCabIte[2] == "undefined") {
	   alert("Estrutura indefinida");
	   return;
   }

   var aMatExe = aMatCabIte[2].split("~");
   var aMatIteG = new Array()

   //--------------------------------------------------------------------
   // Cabecalho
   //--------------------------------------------------------------------
   for (var i = 0; i < (aMatCab.length - 1); i++) {
	   var aCamVal = aMatCab[i].split("!");
	   //--------------------------------------------------------------------
	   // Somente se foi passado o nome do campo
	   //--------------------------------------------------------------------
	   if (aCamVal[0] != "") {
		   if(aCamVal[0] != "dDataIniFat" && aCamVal[0] != "dDataFimFat"){
			   var cCampo = document.getElementById(aCamVal[0]);

			   if (cCampo != null) {
				   cCampo.value = aCamVal[1];
			   }else{

				   if (aCamVal[0] == "cDtVldCar"){
					   cCampo = document.getElementById("cVldCarteira");
					   cCampo.value = aCamVal[1];
				   }else if(aCamVal[0] == "cCarSaud"){
					   cCampo = document.getElementById("cNumCarSau");
					   cCampo.value = aCamVal[1].trim();
				   }else if(aCamVal[0] == "cCnesSol"){
					   cCampo = document.getElementById("cCnes");
					   cCampo.value = aCamVal[1].trim();
				   }else if(aCamVal[0] == "cCnpjCpfSol"){
					   cCampo = document.getElementById("cCnpjCpfExe");
					   cCampo.value = aCamVal[1].trim();					
				   }else if(aCamVal[0] == "cNomeRdaSol"){
					   cCampo = document.getElementById("cNomeRdaExe");
					   cCampo.value = aCamVal[1].trim();					
				   }else if(aCamVal[0] == "cPadCon") {
					   cCampo = document.getElementById("cPadConfSol");
					   cCampo.value = aCamVal[1].trim();
				   }else if(aCamVal[0] == "cTpAcom") {
					   cCampo = document.getElementById("cTpAcomSol");
					   cCampo.value = aCamVal[1].trim();	
				   }else if(aCamVal[0] == "cNumMaxAux") {
					   cCampo = document.getElementById("cNumMaxAux");
					   cCampo.value = aCamVal[1].trim();
				   }
			   }
		   }

		   if (cCampo != null) 
			   aJsonCamposCabec.push('"' + cCampo.id + '"' + ':{ "defaultValue" : ' + '"' + cCampo.value.trim()  + '"' + ', "actualValue":' + '"' + cCampo.value.trim() + '"}');
	   }
   }

   //-----------------------------------------------------------------------
   //Concatena objetos JSON
   //-----------------------------------------------------------------------
   for (var n = 0; n < aJsonCamposCabec.length; n++) {
		   objSubJsonCabec += aJsonCamposCabec[n];

		   //Se não for o último índice do array, adiciona vírgula no json 
		   if (n != aJsonCamposCabec.length - 1)
			   objSubJsonCabec += ",";
   }


   objSubJsonCabec = ' {"cabecalho":{' + objSubJsonCabec + '}} ';
   objSubJsonCabec = JSON.parse(objSubJsonCabec);

   objSubJsonProc = ' {"procedimentos":[]} ';
   objSubJsonExec = ' {"executantes":[]} ';

   objSubJsonProc = JSON.parse(objSubJsonProc);
   objSubJsonExec = JSON.parse(objSubJsonExec);

   oGuiaOff = $.extend({}, objSubJsonCabec, objSubJsonProc, objSubJsonExec); 

   _$Forminputs.on('change', function(e) {
	   for (var i = 0; i < _$Forminputs.length; i++) {
		   if(oGuiaOff.cabecalho[$(_$Forminputs[i]).prop('id')] != undefined && $(_$Forminputs[i]).val() != null){
			   if (oGuiaOff.cabecalho[$(_$Forminputs[i]).prop('id')].defaultValue != $(_$Forminputs[i]).val()){
				   //Se o valor atual for diferente do default, atribui o valor do campo ao atual.
				   if($(_$Forminputs[i]).prop('id') == "cCbosSol" || $(_$Forminputs[i]).prop('id') == "cCbosExe"){
					   oGuiaOff.cabecalho[$(_$Forminputs[i]).prop('id')].actualValue = $(_$Forminputs[i]).val().substring(0,3);
				   }else{
					   oGuiaOff.cabecalho[$(_$Forminputs[i]).prop('id')].actualValue = $(_$Forminputs[i]).val();
				   }
			   }
		   }
	   }
   });

   //Deixar readonly o campo Cid Obito, para não desabilitar o botão / Deixa não editavel caso RN seja não
   fHabilitaCampoResIn2('','1');
   fHabilitaCampoResIn2('','2');
   $('#GrpIndExe').slideUp();
   $('#GrpObsAss').slideUp();
}

function GrvItemResumo(){

   //W_PPLSAUTITE

   Ajax.open("W_PPLSINCITE.APW?cString=" + cString + cQueryString, { 
					   callback: CarregaMontItensInt,
					   error: ExibeErro 
			 });
}

//Armazenar nome do campo
var cNomeDoCmpResint;

function ValDatResInt(cData, cTipo) {
   var cGuia = document.getElementById('cGuiaInter').value;
   var cCampoRef = cData.name;
   var cValor = cData.value;
   cNomeDoCmpResint = cCampoRef;
   cCampoRef = ((cCampoRef == "dDataIniFat") ? " Data Início de faturamento" : ((cCampoRef == "dDataFimFat") ? " Data Final Faturamento" : " Data do procedimento") );
   if (cTipo == '1') {
	   if ( isEmpty(cGuia) || isEmpty(cValor) ) {
		   alert("Informe o número da guia e a data no campo " + cCampoRef);
		   return;
	   }	
	   Ajax.open("W_PPLVerSInt.APW?cCodGuia="+cGuia+"&dDtaAtd="+cValor+"&cRda="+cRda.value, {callback: ResultDataRes, error: ResultDataRes} );
   } else {
	   var cdataini = document.getElementById('dDataIniFat').value;
	   var cdatafim = document.getElementById('dDataFimFat').value;
	   cdataini = cdataini.split("/").reverse().join("/");
	   cdatafim = cdatafim.split("/").reverse().join("/");
	   cValor = cValor.split("/").reverse().join("/");
	   if ( isEmpty(cdataini) || isEmpty(cdatafim) ) {
		   alert("Informe a data Inicial e Final de faturamento!");
		   document.getElementById(cNomeDoCmpResint).value = '';
		   document.getElementById(cNomeDoCmpResint).focus();
		   return true;
	   } else if ( cValor < cdataini || cValor > cdatafim  ) {
		   alert("A data do procedimento deve estar entre a Data Inicial e data Final de Faturamento!");
		   document.getElementById(cNomeDoCmpResint).value = '';
		   document.getElementById(cNomeDoCmpResint).focus();
		   return true;
	   }
   }
}


function ResultDataRes(v) {
   var aResposta = v.split("|")[0];	
   var cTexto = v.split("|")[1];

   if (aResposta != "S") {
	   alert(cTexto);
	   document.getElementById(cNomeDoCmpResint).value = '';
	   document.getElementById(cNomeDoCmpResint).focus();
	   return ;
   } 
}


function fHabCResInt(cCampoor, cCampoAbr) {
   var cValor =  cCampoor.value;
   var aCampos = cCampoAbr.split("|");
   var iT = 0;
   if (cValor == '41' || cValor == '42' || cValor == '43' || cValor == '65' || cValor == '66' || cValor == '67' ) {
	   for (iT = 0; iT < aCampos.length; iT++) {
		   document.getElementById(aCampos[iT]).readOnly = false;
		   if (aCampos[iT] == 'cCidObt') {
			   document.querySelector("#BcCidObt").style.opacity = 1;
			   document.querySelector("#BcCidObt").disabled = true;
		   }
	   }	
   }
}      

function fHabilitaCampoResIn2(cData, cTipo) {
   var cValor =  document.getElementById('cTpSai').value;
   if (cTipo == '1') {
	   if ( !isEmpty(cData) ) {
		   fChkBTQ(cData,'39');  
	   }
	   if (cValor == '41' || cValor == '42' || cValor == '43' || cValor == '65' || cValor == '66' || cValor == '67' ) {
			   document.getElementById('cCidObt').readOnly = false;
			   document.getElementById('cNumDecObt').readOnly = false;
			   document.querySelector("#BcCidObt").style.opacity = 1;
			   document.querySelector("#BcCidObt").disabled = false;	
			   document.getElementById('cIndicRN').disabled = false;
	   } else {
			   document.getElementById('cCidObt').readOnly = true;
			   document.getElementById('cNumDecObt').readOnly = true;
			   document.querySelector("#BcCidObt").style.opacity = 0;
			   document.querySelector("#BcCidObt").disabled = true;
			   document.getElementById("cCidObt").value = '';
			   document.getElementById("cNumDecObt").value = '';
			   document.getElementById('cIndicRN').disabled = true;
	   }
   } else {
	   if (document.getElementById('cAtendRN').value == '0') {
		   document.getElementById('cNumDecVivo').readOnly = true;
	   } else {
		   document.getElementById('cNumDecVivo').readOnly = false;
	   }
   }
}      


function isDupGui(cNumGui,cMatric){
   var cRda	= document.getElementById("cRda").value;
   var cTpGui	= document.getElementById("cTp").value;
   var oDate	= new Date();
   var cDate	= oDate.toLocaleDateString();
   
   if(isEmpty(cMatric)){
	   cMatric = document.getElementById("cNumeCart").value;
   }
   
   if(!isEmpty(cNumGui)){
	   Ajax.open("W_PPLDUPGUI.APW?cRda=" + cRda + "&cTpGui=" + cTpGui + "&cMatric=" + cMatric + "&cDate=" + cDate + "&cNumGui=" + cNumGui , { 
		   callback: DupGuiMod, 
		   error: ExibeErro
	   });
   }
}

function DupGuiMod(v,cAct){
   var aResult 	= v.split("|");
   var lShowModal	= aResult[0] == "S" ? true : false;
   var cMsg		= aResult[1];
   
   if(isEmpty(cAct)){
	   cAct = 'location.reload()';
   }
   
   if(lShowModal){
	   modalBS("Atenção", cMsg, "@Sim~closeModalBS();@Não~window.frames['principal']." + cAct + ";closeModalBS();", "white~#f8c80a", "large");
   }
}


//Valida a menor data dentro de um grid passado por parâmetro
function fValidaMenDtAtd(cTabela, cTipEnv) {
   var dDataAtd	
   var oTabela  	= "";
   var nQtdLinTab	= 0;
   var nI			= 0;
   var oTabela		= "";
   var cTipEnvio	= (isEmpty(cTipEnv)) ? "0" : cTipEnv;
   
   cTabela 		= (cTabela == "TabExeSer") ? window.frames[0].oTabExeSer : "";
   
   if (typeof eval(cTabela) != "string" && eval(cTabela).aCols.length > 0 ) {
	   oTabela = eval(cTabela).getObjCols();
   }
	   
   if ( typeof oTabela != "string" && oTabela != null ) {
	   nQtdLinTab  = oTabela.rows.length;
	   dDataAtd	= getTC(oTabela.rows[0].cells[3]).trim() //Pego a data da primeira posição
   }else{
	   nQtdLinTab = 0;
   }
   
   //Verificar a menor data
   for (i = 0; i < nQtdLinTab; i++) {
	   if (dDataAtd.trim().split("/").reverse().join("/") > getTC(oTabela.rows[i].cells[3]).trim().split("/").reverse().join("/")){
		   dDataAtd = getTC(oTabela.rows[i].cells[3]).trim();
	   }
   }
   
   if (cTipEnvio == "1") {
	   var dDataCor	= document.createElement('input');
	   dDataCor.id	 	= 'dDataCorDig';
	   dDataCor.type 	= 'hidden';
	   dDataCor.value 	= dDataAtd;
	   window.frames[0].document.forms[0].appendChild(dDataCor);
   }	

   return dDataAtd;
}


//Valida a quantidade de aux permitida por procedimento, de acordo com o procedimentos da guia e relacionados
function fValidaAuxLanc(cTabela, cSeqRef, cGraP, nRecno) {
   var cCodSeq		= "";	
   var lRet		= false;
   var cSeqTiss	= "01, 02, 03, 04"
   var oTabela  	= "";
   var nQtdLinTab	= 0;
   var nI			= 0;
   var oTabela		= "";
   var nNumAux		= (document.getElementById("cNumMaxAux") != null) ? parseInt(document.getElementById("cNumMaxAux").value) : 0;
   var nCont		= 0;
   
   //Se inclusão, vem como númerico
   nRecno = nRecno.toString()
   
   cTabela 		= (cTabela == "TabExe") ? oTabExe : "";
   
   //Verificar se a participação informada é válida, de acordo com a quantidade. Ou seja, se nNumAux igual a 2, posso inserir participação 01, 02 e as demais não.
   if (cSeqTiss.indexOf(cGraP.trim()) >= 0 && nNumAux > 0) { 
	   if ( (parseInt(cGraP,10) > nNumAux) ) {
		   lRet = true;
	   }
   }
   
   //Se o grau de participação não faz parte, nem valido a regra e deve ser maior que 0, pois se 0, deve deixar o usuário lançar e receber a crítica, não podemos "travar" o lançamento
   if (cSeqTiss.indexOf(cGraP.trim()) >= 0 && nNumAux > 0 && !isEmpty(cTabela)) {
   
	   if (typeof eval(cTabela) != "string" && eval(cTabela).aCols.length > 0 ) {
		   oTabela = eval(cTabela).getObjCols();
	   }
		   
	   if ( typeof oTabela != "string" && oTabela != null ) {
		   nQtdLinTab  = oTabela.rows.length;
	   }else{
		   nQtdLinTab = 0;
	   }
	   
	   
	   if (!lRet) {
		   //Verificar a quantidade no grid
		   for (i = 0; i < nQtdLinTab; i++) {
			   if (getTC(oTabela.rows[i].cells[3]).trim() == cSeqRef.trim() && getTC(oTabela.rows[i].cells[0]).trim() != nRecno.trim()){
				   var cTmp = getTC(oTabela.rows[i].cells[4]).trim()
				   if ( cSeqTiss.indexOf(cTmp) >= 0 ) {
					   nCont++;
				   }
			   }
		   }
			   
		   if (nCont >= nNumAux) {
			   lRet = true;
		   }
	   }
   }

   return lRet;
}

//Preenche os campos totalizadores da guia de outras despesas
function CalculaTotaisOutDes(){
   var total     = 0;
   var totalPro  = 0;
   var totalGas  = 0;
   var totalMed  = 0;
   var totalMat  = 0;
   var totalDia  = 0;
   var totalTax  = 0;
   var totalOpme = 0;
	 var lachou    = false;
	 var nVlrRec   = 0;
   var cTpProc   = "";
   
   aCalcProcTotal = []

   $('#tabTabOutDesp > tbody  > tr').each(function(index, item) {
	   nVlrRec = parseFloat(item.cells[13].innerText.replace(/\D/g, "")); // Valor total do procedimento
	   cTpProc = item.cells[3].innerText; // Tipo do procedimento
	   if(nVlrRec === ""){
		   nVlrRec = 0
	   }
	   
	   switch(cTpProc) {
		   case "01":
			   totalGas += nVlrRec;
			   break;
		   case "02":
			   totalMed += nVlrRec;				
			   break;
		   case "03":
			   totalMat += nVlrRec;				
			   break;
		   case "05":
			   totalDia += nVlrRec;				
			   break;
		   case "07":
			   totalTax += nVlrRec;				
			   break;
		   case "08":
			   totalOpme += nVlrRec;				
			   break;				
		   default:
			   
			   break;
	   }

	   total += nVlrRec;		
	   aCalcProcTotal.push([index.toString(),  nVlrRec, cTpProc]); //Popula o Array
   });
	   var aCampos  = [["nTotGas",totalGas], ["nTotMed", totalMed], ["nTotMat",totalMat], ["nTotDiarias", totalDia], ["nTotTaxAlug", totalTax], ["nTotOPME", totalOpme]];		
   for (var i = 0; i < aCampos.length; i++) {
	   // verifico se o campo existe
	   if( typeof document.getElementById(aCampos[i][0]) != "undefined") {
		   // preencho o campo com o valor atual
		   document.getElementById(aCampos[i][0]).value = MaskMoeda(aCampos[i][1]);
	   }
   }
   document.getElementById("nTotGeral").value = MaskMoeda(total);	
}


function VerCodTabGRIGH(Codigo){
var cCampoRef = Codigo.name;
var cValor    = Codigo.value;	
var aTabelas  = ['00', '22', '98'];
var lAchou    = false;
   if (isEmpty(cValor)) {
	   alert("Informe um código de tabela - 00, 22 ou 98.");
	   document.getElementById(cCampoRef).value = '22';
	   document.getElementById(cCampoRef).focus();
	   return;
   }
   for (var i = 0; i < aTabelas.length; i++) {
	   if (cValor == aTabelas[i]) {
		   lAchou = true;
		   break;
	   }	
   }
   
   if (!lAchou) {
	   alert("Código informado inválido. Verifique a informação ou use a pesquisa!");
	   document.getElementById(cCampoRef).value = '22';
	   document.getElementById(cCampoRef).focus();
	   return;
   }
}	

function ValidDataGRIOp(cCont, cTipo) {
var cCampoRef = cCont.name;
var cValor    = cCont.value;
   if ( !validaCmp(cCont,'data','Data invalida')) {
	   document.getElementById(cCampoRef).value = '';
	   document.getElementById(cCampoRef).focus();
	   return;
   }
   if	(!verificaDtRetro(cCont)) {
	   document.getElementById(cCampoRef).value = '';
	   document.getElementById(cCampoRef).focus();
	   return;
   } 
   if (ValDatResInt(cCont,cTipo)){
	   document.getElementById(cCampoRef).value = '';
	   document.getElementById(cCampoRef).focus();
	   return;
   }

}


function fProfSauOdonto(cProSaud, cTpProf) {
   cTpPrestador = cTpProf;   
   cCodCbo = wasDef( typeof(cCodCbos) ) && (cCodCbos.trim() != "" );
   var cMatric = parent.frames['principal'].document.forms[0]["cNumeCart"].value;
   var cCodLoc = parent.frames['principal'].document.forms[0]["cCodLoc"].value;
   var cRda = parent.frames['principal'].document.forms[0]["cRda"].value;
   //--------------------------------------------------------------------
   // Executa o metodo													  
   //--------------------------------------------------------------------
   Ajax.open("W_PPCBOSPSAU.APW?cProSaud=" + cProSaud + "&cMatric=" + cMatric + "&cRda=" +cRda+ "&cCodLoc=" +cCodLoc+"&cTpProf="+cTpProf, {
	   callback: CarregaProSaudeOdo, 
	   error: ExibeErro,
	   showProc: false 
   });
}                 

//Atenção, saída contorno apenas para carregar o combo de acordo com o valor proveniente do banco.
function CarregaProSaudeOdo(v) {
   var aResult = v.split("|");

   if ( typeof(cTpPrestador) != 'undefined' ) {
	   //--------------------------------------------------------------------
	   // alimenta variaveis													  
	   //--------------------------------------------------------------------
	   if (cTpPrestador == "E") {
			   if (parent.window.frames['principal'].document.getElementById("cCodSigExe") != undefined) {
				   parent.window.frames['principal'].document.getElementById("cCodSigExe").value = aResult[0];
			   }
			   parent.window.frames['principal'].document.getElementById("cNumCrExe").value	= aResult[1];
			   parent.window.frames['principal'].document.getElementById("cEstSigExe").value	= aResult[2];
				  if (parent.window.frames['principal'].document.getElementById("cCpfExe") != null) {
					  parent.window.frames['principal'].document.getElementById("cCpfExe").value	= aResult[4];
			   }
			   if (aResult.length >= 6){			    
				   if ( typeof(aResult[6]) != 'undefined' ) {
						setTC(parent.window.frames['principal'].document.getElementById("cCbosExe"),"");			
					   var aEspeci = aResult[6].split('$');		
					   
					   var e = parent.window.frames['principal'].document.getElementById("cCbosExe");
					   for (var i = 0; i < aEspeci.length; i++) {
						   var aIten = aEspeci[i].split("#");
						   if (aIten[0] != '') {                  
							   e.options[i] = new Option(aIten[1], aIten[0]);
							}	
						   
						   if((typeof parent.window.frames[0].document.forms[0].tmpCboHidden == "object") && aIten[0] == parent.window.frames[0].document.forms[0].tmpCboHidden.value){
							   e.options[i].selected = true;
							   parent.window.frames[0].document.forms[0].tmpCboHidden.remove();
						   }
					   }
					   
					   if (e.options.length > 0){
						   e.selectedIndex = 1;
					   }
				   }else{        
					   var cRda 	= parent.window.frames['principal'].document.getElementById("cRda").value;
					   var cCodLoc = parent.window.frames['principal'].document.getElementById("cCodLoc").value;
					   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
						   callback: CarrEspAntExe, 
						   error: ExibeErro
					   });    
				   }
			   }else{        
					   var cRda 	= parent.window.frames['principal'].document.getElementById("cRda").value;
					   var cCodLoc = parent.window.frames['principal'].document.getElementById("cCodLoc").value;
					   Ajax.open("W_PPLDADRDA.APW?cRda=" + cRda + "&cCodLoc=" + cCodLoc, { 
						   callback: CarrEspAntExe, 
						   error: ExibeErro
					   });    
				   }
	   }                                   
   }       
setSelectedValue(aCodEspOdo[0], aCodEspOdo[1].substr(0,3));      
}


function fVerProLoad(Sigla, NumCR, EstSigla) {
var cSigla 		= Sigla;
var cNumCR 		= NumCR;
var cEstSigla	= EstSigla;
var aChaveRel	= document.getElementById("cRelExecCar").value.split('&*');
var aChaveDRel	= [];
var cRetorno	= '';

for (i = 0; i < aChaveRel.length; i++) {
   aChaveDRel = aChaveRel[i].split('&');
   if (aChaveDRel.length > 0) {
	   if ( (cSigla.trim() == aChaveDRel[1].trim()) && (cNumCR.trim() == aChaveDRel[2].trim()) && (cEstSigla.trim() == aChaveDRel[3].trim()) ) {
		   cRetorno = aChaveDRel[0].trim();
		   break;
	   }
   }	
}
return cRetorno;

}


function CalculaSadtResIntOutDes(totalPro, totalMat, totalMed, totalTax, totalOpme, totalGas, total, totalDia) {
   var cTipoGuia = document.getElementById("cTp").value;
   var lVlOutDesp = isEmpty(document.getElementById("cVlOutDesp").value);
   var aCampos = [];
 var cTot = isEmpty( document.getElementById("nTotGerGui").value ) ? "0" : document.getElementById("nTotGerGui").value;
   
 cTot = cTipoGuia == "5" ? cTot : "0";
 if (cTipoGuia == "5") {
   document.getElementById("nTotPro").value = cTot;
 }

   if ( !lVlOutDesp && isDitacaoOffline() && isAlteraGuiaAut() && (cTipoGuia == "2" || cTipoGuia == "5") ) {
	   var aValorOutDesp = document.getElementById("cVlOutDesp").value.split(";");

	   for (var i = 0; i < aValorOutDesp.length; i++) {
		   var aValOut = aValorOutDesp[i].split("*");
		   
		   switch(aValOut[0]) {
		   //0=Procedimento; 1=Material; 2=Medicamento; 3=Taxas; 4=Diarias; 5=Ortese/Protese; 6=Pacote; 7=Gases Medicinais; 8=Alugueis; 9=Outros
			   case "1":
				   totalMat += parseFloat(aValOut[1].replace(/\D/g, ""));
				   break;
			   case "2":
				   totalMed += parseFloat(aValOut[1].replace(/\D/g, ""));
				   break;
			   case "3":
				   totalTax += parseFloat(aValOut[1].replace(/\D/g, ""));
				   break;
			   case "4":
				 if (document.getElementById("cTp").value == "5") {
					 totalDia += parseFloat(aValOut[1].replace(/\D/g, ""))
				 }
				   break;
			   case "5":
				   totalOpme += parseFloat(aValOut[1].replace(/\D/g, ""));
				   break;
			   case "7":
				   totalGas += parseFloat(aValOut[1].replace(/\D/g, ""));				
				   break;
			   case "8":
				   totalTax += parseFloat(aValOut[1].replace(/\D/g, ""));			
				   break;					
			   default:	
				   break;
		   }
		   totalArray += parseFloat(aValOut[1].replace(/\D/g, ""));		
	   }	

   total += parseFloat( totalMat + totalMed + totalTax + totalDia + totalOpme + totalGas ) + parseFloat(cTot.replace(/\D/g, ""));

   }
   
   if (cTipoGuia == "2") {
	   aCampos  = [["nTotPro",totalPro], ["nTotMat", totalMat], ["nTotMed",totalMed], ["nTotTax", totalTax], ["nVlrTotOExeG", totalOpme], ["nTotGas", totalGas]];		
   } else {
	   aCampos  = [["nTotMat", totalMat], ["nTotMed",totalMed], ["nTotTax", totalTax], ["nTotDiarias", totalDia], ["nVlrTotOExeG", totalOpme], ["nTotGas", totalGas]];		
   }
   
   return ([aCampos, total]);

}


//------------------------------------------------
// Carregar relatorio Outras Despesas.
//------------------------------------------------
function carregaRelODesp(){

   var altura = "910px";
   var largura = "1200px";
   var alturafrm = "750";
   var iframe;
   var style = [altura, largura];
   var styfrm = [alturafrm];
   var objSubJson = '{';
   var StringODesp;
   var seq = 0;
   var objODesp;
   var oDesp = [];
   var aDadoODesp = [];

   StringODesp = '"DespRealizados":';
   aDadoOdesp = dadostable("tabTabOutDesp");

   if(aDadoOdesp != false){
	   
	   for (var i = 0; i < aDadoOdesp.length; i++) {
		   for (var j = 0; j < aDadoOdesp[i].length; j++) {
			   if(j != 15){
				   aDadoOdesp[i][j] = aDadoOdesp[i][j].replace(/[^a-zA-Z 0-9]+/g, '');
			   }else{
				   aDadoOdesp[i][j] = aDadoOdesp[i][j].trim();
			   }
		   }
	   }
   // Itens relacionados
   for (var i = 0; i < aDadoOdesp.length; i++) {
	   var retorno = aDadoOdesp[i][0];
	   var cd = aDadoOdesp[i][1];
	   var data = aDadoOdesp[i][2];
	   var hrIni = aDadoOdesp[i][3];
	   var hrFin = aDadoOdesp[i][4];
	   var tabela = aDadoOdesp[i][5];
	   var codPro = aDadoOdesp[i][6];
	   var qtd = aDadoOdesp[i][7];
	   var uniMed = aDadoOdesp[i][8];
	   var fatRedAc = aDadoOdesp[i][9];
	   var vlrUni = aDadoOdesp[i][10];
	   var vlrTotal = aDadoOdesp[i][11];
	   var regAnvMat = aDadoOdesp[i][12];
	   var refMat = aDadoOdesp[i][13];
	   var numAut = aDadoOdesp[i][14];
	   var desc = aDadoOdesp[i][15];
		   
	   seq++;
	   oDesp.push({
		   retorno: [seq.toString(),
					 cd,
						data, 
					 hrIni, 
					 hrFin, 
					 tabela, 
					 codPro, 
					 qtd, 
					 uniMed, 
					 fatRedAc,
					 vlrUni, 
					 vlrTotal, 
					 regAnvMat.substring(0,15),
					 refMat.substring(0,45),
					 numAut.substring(0,30),
					 desc]
	   });
   }
   }
   objSubJson += '"RegistroANS":"' + document.getElementById("cRegAns").value + '",';
   objSubJson += '"NrGuiaRef":"' + document.getElementById("cGuiRef").value + '",';
   objSubJson += '"CodOperadora":"' + document.getElementById("cCodOpe").value + '",';
   objSubJson += '"NomeContratado":"' + document.getElementById("cNomeRdaExe").value + '",';
   objSubJson += '"CodCNES":"' + document.getElementById("cAutCnes").value + '",';
   objODesp = StringODesp.concat(JSON.stringify(oDesp));
   objSubJson += objODesp.concat(",");
   objSubJson += '"TotalDiarias":"' + document.getElementById("nTotDiarias").value + '",';
   objSubJson += '"TotalTaxa":"' + document.getElementById("nTotTaxAlug").value + '",';
   objSubJson += '"TotalMateriais":"' + document.getElementById("nTotMat").value + '",';
   objSubJson += '"TotalOPME":"' + document.getElementById("nTotOPME").value + '",';
   objSubJson += '"TotalMedicam":"' + document.getElementById("nTotMed").value + '",';
   objSubJson += '"TotalGasesMed":"' + document.getElementById("nTotGas").value + '",';
   objSubJson += '"TotalGeral":"' + document.getElementById("nTotGeral").value + '"}';
   iframe = document.createElement("iframe");
   iframe.id = "iframeRel";
   iframe.src = "W_PPLSRELGOD.APW?data=" + objSubJson;
   iframe.width = "100%";
   iframe.height = "100%";
   iframe.frameBorder = "0";
   iframe.scrolling = "yes";
   
   if (!(aDadoOdesp === false)){
	  ViewRel("Relatorio Outras Despesas", "@Gerar PDF~exportFormPdf()@Fechar~closeMViewRel();",undefined, iframe, style, styfrm);
   }else{alert("Não há impressão existem inconsistência no preenchimento para Outras Despesas")}
   
   window.setDisable('bimprimir',true);
   
}



//------------------------------------------------
// Carregar relatorio Resumo Internação.
//------------------------------------------------
function carregaRelResInt() {

   var altura = "910px";
   var largura = "1200px";
   var alturafrm = "750";
   var cMatrix = "";
   var iframe;
   var style = [altura, largura];
   var styfrm = [alturafrm];
   var objSubJson = '{';
   var StringItens;
   var StringProfiss;
   var objItens;
   var objProfiss;
   var Itens = [];
   var Profiss = [];
   var Profissionais = [];
   var aDadoItens = [];
   var aDadoTabExe = [];
   var cTendRn = "";
   var cIndoRn = "";
   

   StringItens = '"ProcRealizados":';
   StringProfiss = '"IdentEquipe":';
   aDadoItens = dadostable("tabTabExeSer");
   
   // Itens relacionados
   if(aDadoItens != false){
	   for (var i = 0; i < aDadoItens.length; i++) {
		   for (var j = 0; j < aDadoItens[i].length; j++) {
			   if(j != 6){
				   aDadoItens[i][j] = aDadoItens[i][j].replace(/[^a-zA-Z 0-9]+/g, '');
			   }else{
				   aDadoItens[i][j] = aDadoItens[i][j].trim();
				   aDadoItens[i][j] = aDadoItens[i][j].substring(0,136);
			   }
		   }
	   }
	   
	  for (var i = 0; i < aDadoItens.length; i++) {
		   var retorno = aDadoItens[i][0];
		   var data = aDadoItens[i][1];
		   var hrIni = aDadoItens[i][2];
		   var hrFim = aDadoItens[i][3];
		   var tabela = aDadoItens[i][4];
		   var codpro = aDadoItens[i][5];
		   var desc = aDadoItens[i][6];
		   var qtde = aDadoItens[i][7];
		   var via = aDadoItens[i][8];
		   var tec = aDadoItens[i][9];
		   var fatRedAc = aDadoItens[i][10];
		   var vlrUni = aDadoItens[i][11];
		   var vlrTotal = aDadoItens[i][12];
		   Itens.push({
			   retorno: [data, 
						 hrIni, 
						 hrFim, 
						 tabela, 
						 codpro, 
						 desc, 
						 qtde, 
						 via, 
						 tec, 
						 fatRedAc, 
						 vlrUni, vlrTotal]
		   });
	   }
	   
   }	
   
   // Profissionais relacionados.
   aDadoTabExe = dadostable("tabTabExe");
   if(aDadoTabExe != false){

	   for (var i = 0; i < aDadoTabExe.length; i++) {
		   for (j = 0; j < aDadoTabExe[i].length; j++) {
			   aDadoTabExe[i][j] = aDadoTabExe[i][j].replace(/[^a-zA-Z 0-9]+/g, '');
		   }
	   }

	   for (var i = 0; i < aDadoTabExe.length; i++) {
		   var retorno = aDadoTabExe[i][0];
		   var seq = aDadoTabExe[i][1];
		   var grauPart = aDadoTabExe[i][2];
		   var codOpe = aDadoTabExe[i][3];
		   var nomeProf = aDadoTabExe[i][4];
		   var consProf = aDadoTabExe[i][5];
		   var numCons = aDadoTabExe[i][6];
		   var uf = aDadoTabExe[i][7];
		   var codCbo = aDadoTabExe[i][8];
		   Profiss.push({
			   retorno: [seq, 
						 grauPart, 
						 codOpe, 
						 nomeProf, 
						 consProf, 
						 numCons, 
						 uf, codCbo]
		   });
	   }
	   
   }
   
   cTendRn = document.getElementById("cAtendRN").value;
   if(cTendRn == "0"){
	   cTendRn = "Nao";
   }else{cTendRn = "Sim"};
   cIndoRn = document.getElementById("cIndicRN").value 
   if(cIndoRn == "SELECTED" ){
	   cIndoRn = "";
   }else if(cIndoRn == "0"){
	   cIndoRn = "Nao";
   }else{
	   cIndoRn = "Sim";
   }
   objSubJson += '"NrPrestador":"' + document.getElementById("cNumAut").value + '",';
   objSubJson += '"RegistroANS":"' + document.getElementById("cRegAns").value + '",';
   objSubJson += '"NrGuiaSolic":"' + document.getElementById("cGuiaInter").value + '",';
   objSubJson += '"DtAutorizacao":"' + document.getElementById("dDtAut").value + '",';
   objSubJson += '"Senha":"' + document.getElementById("cSenha").value + '",';
   objSubJson += '"DtValSenha":"' + document.getElementById("dDtValid").value + '",';
   objSubJson += '"NrGuiaOperadora":"' + document.getElementById("cGuiaOpe").value + '",';
   objSubJson += '"NrCarteira":"' + document.getElementById("cNumeCart").value + '",';
   objSubJson += '"validCarteira":"' + document.getElementById("cVldCarteira").value + '",';
   objSubJson += '"Nome":"' + document.getElementById("cNomeUsu").value + '",';
   objSubJson += '"CarteiraNacionalSaude":"' + document.getElementById("cNumCarSau").value + '",';
   objSubJson += '"AtendRN":"' + cTendRn + '",';
   objSubJson += '"CodOperadora":"' + document.getElementById("cCnpjCpfExe").value + '",';
   objSubJson += '"NomeContratado":"' + document.getElementById("cNomeRdaExe").value + '",';
   objSubJson += '"CodCNES":"' + document.getElementById("cCnes").value + '",';
   objSubJson += '"CaraterAtend":"' + document.getElementById("cCarSolicit").value + '",';
   objSubJson += '"TpFaturamento":"' + document.getElementById("cTipFat").value + '",';
   objSubJson += '"DtIniFat":"' + document.getElementById("dDataIniFat").value + '",';
   objSubJson += '"HrIniFat":"' + document.getElementById("cHorIniFat").value + '",';
   objSubJson += '"DtFimFat":"' + document.getElementById("dDataFimFat").value + '",';
   objSubJson += '"HrFimFat":"' + document.getElementById("cHorFimFat").value + '",';
   objSubJson += '"TpInternacao":"' + document.getElementById("cTpIntern").value + '",';
   objSubJson += '"RgInternacao":"' + document.getElementById("cRegInter").value + '",';
   objSubJson += '"Cid10Principal":"' + document.getElementById("cCid").value + '",';
   objSubJson += '"Cid102":"' + document.getElementById("cCid2").value + '",';
   objSubJson += '"Cid103":"' + document.getElementById("cCid3").value + '",';
   objSubJson += '"Cid104":"' + document.getElementById("cCid4").value + '",';
   objSubJson += '"IndAcindente":"' + document.getElementById("cIndAcid").value + '",';
   objSubJson += '"MotEncInternacao":"' + document.getElementById("cTpSai").value + '",';
   objSubJson += '"NrNascVivo":"' + document.getElementById("cNumDecVivo").value + '",';
   objSubJson += '"Cid10Obito":"' + document.getElementById("cCidObt").value + '",';
   objSubJson += '"NrObito":"' + document.getElementById("cNumDecObt").value + '",';
   objSubJson += '"IndDoRN":"' +cIndoRn+ '",';
   objItens = StringItens.concat(JSON.stringify(Itens));
   objSubJson += objItens.concat(",");
   objProfiss = StringProfiss.concat(JSON.stringify(Profiss));
   objSubJson += objProfiss.concat(",");
   objSubJson += '"TotalProc":"' + document.getElementById("nTotPro").value + '",';
   objSubJson += '"TotalDiarias":"' + document.getElementById("nTotDiarias").value + '",';
   objSubJson += '"TotalTaxa":"' + document.getElementById("nTotTax").value + '",';
   objSubJson += '"TotalMateriais":"' + document.getElementById("nTotMat").value + '",';
   objSubJson += '"TotalOPME":"' + document.getElementById("nVlrTotOExeG").value + '",';
   objSubJson += '"TotalMedicam":"' + document.getElementById("nTotMed").value + '",';
   objSubJson += '"TotalGasesMed":"' + document.getElementById("nTotGas").value + '",';
   objSubJson += '"TotalGeral":"' + document.getElementById("nTotGerGui").value + '",';
   objSubJson += '"DtAssinatura":"' + document.getElementById("dDatAssCon").value + '",';
   objSubJson += '"AssinContrato":"' + document.getElementById("ASSCON").value + '",';
   objSubJson += '"AssinAudOper":"' + document.getElementById("ASSAUDOPE").value + '",';
   objSubJson += '"Observacao":"' + document.getElementById("cObs").value + '"}';
   iframe = document.createElement("iframe");
   iframe.id = "iframeRel";
   iframe.src = "W_PPLSRELHG.APW?data=" + objSubJson;
   iframe.width = "100%";
   iframe.height = "100%";
   iframe.frameBorder = "0";
   iframe.scrolling = "yes";
   
   if ((!(aDadoItens === false) && !(aDadoTabExe === false)) && (aDadoItens.length > 0)){
	  ViewRel("Relatorio de guias medicas", "@Gerar PDF~exportFormPdf()@Fechar~closeMViewRel();",undefined, iframe, style, styfrm);
   }else{alert("Não há impressão existem inconsistência no preenchimento dos Procedimentos e Exames Realizados/Identificacao da Equipe!")}
   window.setDisable('bimprimir',true);
   
}

//------------------------------------------------
// Carregar tabela de Itens e profissionais.
//------------------------------------------------
function dadostable(tabela) {

   var dados = [];
   $('#' + tabela + ' tbody tr').each(function() {
	   var colunas = $(this).children();
	   var ntam = colunas.length;
	   switch (tabela) {
		   case "tabTabExeSer":
			   if(ntam === 15){
				   dados.push([colunas[0].innerText,
					   colunas[3].innerText,
					   colunas[4].innerText,
					   colunas[5].innerText,
					   colunas[6].innerText,
					   colunas[7].innerText,
					   colunas[8].innerText,
					   colunas[9].innerText,
					   colunas[10].innerText,
					   colunas[11].innerText,
					   colunas[12].innerText,
					   colunas[13].innerText,
					   colunas[14].innerText
					   
				   ]);
			   }else{dados = false}
			   break;
			   
		   case "tabTabExe":
			   if(ntam === 11){
				   dados.push([colunas[0].innerText,
					   colunas[3].innerText,
					   colunas[4].innerText,
					   colunas[5].innerText,
					   colunas[6].innerText,
					   colunas[7].innerText,
					   colunas[8].innerText,
					   colunas[9].innerText,
					   colunas[10].innerText
				   ]);
			   }else{dados = false}
			   break;

		  case "tabTabOutDesp":
			   if(ntam === 18){
				   dados.push([colunas[0].innerText,
					   colunas[3].innerText,
					   colunas[4].innerText,
					   colunas[5].innerText,
					   colunas[6].innerText,
					   colunas[7].innerText,
					   colunas[8].innerText,
					   colunas[9].innerText,
					   colunas[10].innerText,
					   colunas[11].innerText,
					   colunas[12].innerText,
					   colunas[13].innerText,
					   colunas[14].innerText,
					   colunas[15].innerText,
					   colunas[16].innerText,
					   colunas[17].innerText
				   ]);
			   }else{dados = false}
			   break;		
	   }
   });
   return dados;
}

function fGridValDig(cVar) {
	var cdado = document.getElementById(cVar).value

   if (isDitacaoOffline() && (cdado == "18" ||cdado == "19" ||cdado == "20" ) ) {
	   alert('Não é permitido utilizar esta tabela na digitação de Guias OFF-Line.');
       document.getElementById(cVar).value = ""
  	   return;
    }

} 