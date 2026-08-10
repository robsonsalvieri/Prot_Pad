#Include "Protheus.ch"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA117
Esta Rotina tem como objetivo a Emissao do Arquivo Magnetico do Sped Fiscal

@Author Rodrigo Aguilar
@Since  28/12/2012
@Version 1.0

Alterações Realizadas:

Altered By: Rodrigo Aguilar ( 25/11/2014 )
- Implementação da geração do Sped Fiscal em Multi Thread

- Geração do bloco 0 passa a ser realizada durante o processamento dos demais blocos
e não de forma separada.

- O Bloco 9 e os registros de encerramento de cada bloco também deixam de ser
gerados de forma separada e passam a ser gerados após o final do processamento
de todos os blocos.

- Foram criadas as tabelas de controle de geração com o conceito de farois, ou seja,
caso o usuário deseje reprocessar o mesmo período pode optar por apenas gerar o arquivo
magnético sem refazer todo o processamento, ou até mesmo selecionar apenas alguns blocos
para serem refeitos.

@Return ( Nil )
/*/
//--------------------------------------------------------------------------------------------------
Function TAFA117()

	//Mensagem adicionada em 21/03/2025				                   
	MsgInfo("Prezado cliente, esta rotina foi descontinuada, para SPED Fiscal utilize o módulo fiscal do ERP.")

Return( .T. )
