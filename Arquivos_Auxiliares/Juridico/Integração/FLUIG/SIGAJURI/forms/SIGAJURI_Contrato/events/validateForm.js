function validateForm(form){

	if (isNullOrUndefined(form.getValue('cdFilialNS7'), true)){
		throw "Favor selecionar a Filial.";
	}
	
	if (isNullOrUndefined(form.getValue('cdAreaSol'), true)){
		throw "Favor selecionar a Área Solicitante.";
	}
	
	if (isNullOrUndefined(form.getValue('cdTipoCon'), true)){
		throw "Favor selecionar o Tipo de Contrato.";
	}
	
	if (isNullOrUndefined(form.getValue('sDescSol'), false)){
		throw "Favor detalhar a solicitação.";
	}
	
	if ( isNullOrUndefined(form.getValue('sAtivo'), false) && (form.getValue('optAtivo') == "optCli" || form.getValue('optAtivo') == "optForn") ) {
		throw "Você deve escolher um Contratante.";
	}
	
	if ( isNullOrUndefined(form.getValue('sPassivo'), false) && (form.getValue('optPassivo') == "optCli" || form.getValue('optPassivo') == "optForn") ) {
		throw "Você deve escolher um Contratado.";
	}
	
	//Nova parte ativo
	if ( isNullOrUndefined(form.getValue('sAtivo'), false) && (form.getValue('optAtivo') == "optOutros") ) {
		if  (form.getValue('sRazaoSocial') == null || form.getValue('sRazaoSocial') == ""){
			throw "Você deve informar a razão social da parte cadastrada.";
		}
		
	}
	
	//Nova parte passivo
	if ( isNullOrUndefined(form.getValue('sPassivo'), false) && (form.getValue('optPassivo') == "optOutros") ) {
		if  (form.getValue('sRazaoSocial') == null || form.getValue('sRazaoSocial') == ""){
			throw "Você deve informar a razão social da parte cadastrada.";
		}
		
	}
	
	if ( !isNullOrUndefined(form.getValue('sCnpj'), false) ) {
		//valida cpf/cpnj
		if (!valida_cpf_cnpj(form.getValue('sCnpj'))){
			throw "Você informou um número de CPF/CNPJ inválido. Favor verificar.";
		}
		
	}

	if (!isNullOrUndefined(form.getValue('sVigenciaDe'), false) &&
		!isNullOrUndefined(form.getValue('sVigenciaAte'), false) ) {
		var aDtIniVig = form.getValue('sVigenciaDe').split('/')
		var aDtFimVig = form.getValue('sVigenciaAte').split('/')
		var dDtIniVig = new Date(
			parseInt(aDtIniVig[2]),
			(parseInt(aDtIniVig[1]) - 1),
			parseInt(aDtIniVig[0])
		)
		var dDtFimVig = new Date(
			parseInt(aDtFimVig[2]),
			(parseInt(aDtFimVig[1]) - 1),
			parseInt(aDtFimVig[0])
		)

		if (dDtIniVig.getTime() > dDtFimVig.getTime()) {
			throw 'Data inicio não pode ser maior que a data final da vigência!';
		}
	}
}

/*
verifica_cpf_cnpj

Verifica se é CPF ou CNPJ

@see http://www.todoespacoonline.com/w/
*/
function verifica_cpf_cnpj ( valor ) {

   // Garante que o valor é uma string
   valor = valor.toString();
   
   valor = valor.replace("/", "");
   valor = valor.replace("-", "");
   valor = valor.replace(".", "");
   
   log.info("*** VALIDA VALOR DEPOIS REPLACE:" + valor);

   // Verifica CPF
   if ( valor.length() === 11 ) {
       return 'CPF';
   } 
   
   // Verifica CNPJ
   else if ( valor.length() === 14 ) {
       return 'CNPJ';
   } 
   
   // Não retorna nada
   else {
       return false;
   }
   
} // verifica_cpf_cnpj

/*
calc_digitos_posicoes

Multiplica dígitos vezes posições

@param string digitos Os digitos desejados
@param string posicoes A posição que vai iniciar a regressão
@param string soma_digitos A soma das multiplicações entre posições e dígitos
@return string Os dígitos enviados concatenados com o último dígito
*/
function calc_digitos_posicoes( digitos, posicoes, soma_digitos ) {
	
	if (posicoes === undefined){
		posicoes = 10;
	}
	
	if (soma_digitos === undefined){
		soma_digitos = 0;
	}

   // Garante que o valor é uma string
   digitos = digitos.toString();

   // Faz a soma dos dígitos com a posição
   // Ex. para 10 posições:
   //   0    2    5    4    6    2    8    8   4
   // x10   x9   x8   x7   x6   x5   x4   x3  x2
   //   0 + 18 + 40 + 28 + 36 + 10 + 32 + 24 + 8 = 196
   for ( var i = 0; i < digitos.length; i++  ) {
       // Preenche a soma com o dígito vezes a posição
       soma_digitos = soma_digitos + ( digitos[i] * posicoes );

       // Subtrai 1 da posição
       posicoes--;

       // Parte específica para CNPJ
       // Ex.: 5-4-3-2-9-8-7-6-5-4-3-2
       if ( posicoes < 2 ) {
           // Retorno a posição para 9
           posicoes = 9;
       }
   }

   // Captura o resto da divisão entre soma_digitos dividido por 11
   // Ex.: 196 % 11 = 9
   
   soma_digitos = soma_digitos % 11;
   
   // Verifica se soma_digitos é menor que 2
   if ( soma_digitos < 2 ) {
       // soma_digitos agora será zero
       soma_digitos = 0;
   } else {
       // Se for maior que 2, o resultado é 11 menos soma_digitos
       // Ex.: 11 - 9 = 2
       // Nosso dígito procurado é 2
       soma_digitos = 11 - soma_digitos;
   }

   // Concatena mais um dígito aos primeiro nove dígitos
   // Ex.: 025462884 + 2 = 0254628842
   var cpf = digitos + soma_digitos;

   // Retorna
   return cpf;
   
} // calc_digitos_posicoes

/*
Valida CPF

Valida se for CPF

@param  string cpf O CPF com ou sem pontos e traço
@return bool True para CPF correto - False para CPF incorreto
*/
function valida_cpf( valor ) {
	
	// Garante que o valor é uma string
	valor = valor.toString();
   
   // Remove caracteres inválidos do valor
	valor = valor.replace("/", "");
   valor = valor.replace("-", "");
   valor = valor.replace(".", "");

   // Captura os 9 primeiros dígitos do CPF
   // Ex.: 02546288423 = 025462884
   var digitos = valor.substr(0, 9);

   // Faz o cálculo dos 9 primeiros dígitos do CPF para obter o primeiro dígito
   var novo_cpf = calc_digitos_posicoes( digitos );

   // Faz o cálculo dos 10 dígitos do CPF para obter o último dígito
   var novo_cpf = calc_digitos_posicoes( novo_cpf, 11 );
   
   // Verifica se o novo CPF gerado é idêntico ao CPF enviado
   if ( novo_cpf === String(valor) ) {
       // CPF válido
       return true;
   } else {
       // CPF inválido
       return false;
   }
   
} // valida_cpf

/*
valida_cnpj

Valida se for um CNPJ

@param string cnpj
@return bool true para CNPJ correto
*/
function valida_cnpj ( valor ) {

   // Garante que o valor é uma string
   valor = valor.toString();
   
   // Remove caracteres inválidos do valor
   valor = valor.replace("/", "");
   valor = valor.replace("-", "");
   valor = valor.replace(".", "");
   
   // O valor original
   var cnpj_original = valor;

   // Captura os primeiros 12 números do CNPJ
   var primeiros_numeros_cnpj = valor.substr( 0, 12 );

   // Faz o primeiro cálculo
   var primeiro_calculo = calc_digitos_posicoes( primeiros_numeros_cnpj, 5 );

   // O segundo cálculo é a mesma coisa do primeiro, porém, começa na posição 6
   var segundo_calculo = calc_digitos_posicoes( primeiro_calculo, 6 );

   // Concatena o segundo dígito ao CNPJ
   var cnpj = segundo_calculo;

   // Verifica se o CNPJ gerado é idêntico ao enviado
   if ( cnpj === String(cnpj_original) ) {
       return true;
   }
   
   // Retorna falso por padrão
   return false;
   
} // valida_cnpj

/*
valida_cpf_cnpj

Valida o CPF ou CNPJ

@access public
@return bool true para válido, false para inválido
*/
function valida_cpf_cnpj ( valor ) {

   // Verifica se é CPF ou CNPJ
   var valida = verifica_cpf_cnpj( valor );
   
   // Garante que o valor é uma string
   valor = valor.toString();
   
   // Remove caracteres inválidos do valor
   valor = valor.replace("/", "");
   valor = valor.replace("-", "");
   valor = valor.replace(".", "");

   // Valida CPF
   if ( valida === 'CPF' ) {
       // Retorna true para cpf válido
       return valida_cpf( valor );
   } 
   
   // Valida CNPJ
   else if ( valida === 'CNPJ' ) {
       // Retorna true para CNPJ válido
       return valida_cnpj( valor );
   } 
   
   // Não retorna nada
   else {
       return false;
   }
   
} // valida_cpf_cnpj

function isNullOrUndefined(value, isVldTraco) {
	if ( value == null || value == '' || ( isVldTraco && value == '-') ) {
		return true;
	}

	return false;
}