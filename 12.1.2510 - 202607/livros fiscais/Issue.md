## Issue 
 A organização RITZ MG COMERCIAL LTDA informou que, ao vincular um participante a um perfil, é gerada uma linha em branco na F22, resultando no seguinte erro:
 
F22010: DB error (Insert): -37 File: F22010 - Error : 2601 (23000) (RC=-1) - [Microsoft][ODBC Driver 13 for SQL Server][SQL Server]Cannot insert duplicate key row in object 'dbo.F22010' with unique index 'F22
 
Tivemos histórico de clientes relacionando este perfil pelo MV_FACAUTO = .T. (pelo cadastro de clientes/fornecedores), mas também ao criar um perfil novo no FISA170, onde o mesmo erro ocorre. Até o momento, todos os casos ocorreram apenas em banco SQL Server com sistema operacional Windows .
 
Na pilha de chamadas do log do cliente, observa-se:
 
[TOTVS build: 7.00.240223P-20260211]
Called from EXFORMCOMMIT(PROTHEUSFUNCTIONMVC.PRX) 08/08/2025 16:04:23 line : 2200
Called from FSA164GF22(FISA164.PRW) 16/01/2026 10:41:07 line : 662
 
A empresa informou que o problema ocorre somente após aplicação da expedição contínua, que disponibilizou a data do FISA164 para 16/01. 
 
Um pouco acima da linha 662 citada no log, ocorre a seguinte validação:
 
If oPartic:SeekLine({{"F22_TPPART", cTpPart},

{"F22_CLIFOR", cCliFor}
, {"F22_LOJA", cLoja}})
   oPartic:DeleteLine()
EndIf
 
If oModel:VldData()
   lRet := oModel:CommitData()   // linha que estoura o erro
EndIf
 
O cliente nos encaminhou um vídeo demonstrando que somente os campos F22_TPPART, F22_CLIFOR e F22_LOJA estavam em branco na aplicação, exatamente os mesmos utilizados na validação acima, enquanto os demais campos da F22 eram preenchidos normalmente na APSDU (campos não apresentáveis na rotina).
 
Analisando o erro, identifiquei que ao utilizar SeekLine() seguido de DeleteLine() em um grid MVC no AdvPL, a rotina localiza corretamente o registro pelos campos de chave, porém, após a execução do DeleteLine(), a linha não é removida do grid/model.
 
Ela permanece visível, mas com os campos da chave zerados, enquanto os demais campos continuam preenchidos no banco de dados.
 
Durante a análise, validei que os dados estavam corretos antes da exclusão e que somente os campos utilizados na busca eram afetados. Isso me levou à conclusão de que o comportamento não está no SeekLine(), mas no próprio DeleteLine(), que no MVC apenas marca a linha como deletada no buffer, sem removê-la fisicamente e ainda limpa os campos-chave como parte do controle interno.
 
O problema ocorre porque essa linha “deletada” continua existindo no model e participa do processo de gravação. Como os campos de chave ficam em branco, múltiplas linhas podem assumir a mesma chave vazia, resultando em erro de duplicidade na tabela.
 
Portanto, meu ponto de vista é que, neste cenário, o DeleteLine() não impede a persistência da linha deletada, o que gera inconsistência de dados e pode explicar a ocorrência de linhas em branco e o erro de chave duplicada observado.
 
Drive:
https://drive.google.com/drive/folders/1TcKz6YLJiRThvSQ-t5NUqGUAVBdQjYkC

## Analise

O que está precisa ser analisado são locais que façam a gravação da F22 sem verificar se a foram preenchidos os campos chave.

O cadastro de perfil possui validação da função `VldCliFor` para evitar que seja criado um perfil com os campos chave em branco, mas  precisamos cercar os facilitadores (FISA171 e FISA172) para evitar que seja possível criar um perfil com os campos chave em branco, ou seja, sem vincular um cliente/fornecedor específico.

Na rotina FISA171 não usa o modelo para gravar os dados e sim a função `TCSqlExec` na função `CommitInsQry` de uma query montada pela `GrvF22Regs`, tentadno simular a funcionalidade de `Bulk`, que na epoca não existia a classe `fwbulk`, realizando inserção direta no banco, o que pode ser um dos motivos para o erro de chave duplicada, pois não há uma validação prévia para verificar se os campos chave estão preenchidos antes de realizar a inserção.

Precisamos cercar todos os locais de gravação, modelo FISA164, facilitadores FISA171 e FISA172, para garantir que não seja possível gravar um registro na F22 com os campos chave em branco, evitando assim o erro de chave duplicada e a geração de linhas em branco na tabela.

## Tratar problema dos dados no banco 

Vamos precisar criar um processo para identificar e corrigir os registros com campos chave em branco na tabela F22, para evitar que o erro de chave duplicada continue ocorrendo.

Precisamos adicionar na função `x170Carga` uma chamada de função que irá verificar a tabela F22 e corrigir os registros com campos chave em branco, removendo esses registros, assim que usuário acessar FISA170, garantindo que a tabela F22 esteja limpa de registros inválidos antes de realizar qualquer operação de vinculação de perfil.




