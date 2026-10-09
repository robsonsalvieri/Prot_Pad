/*
+---------+--------------------------------------------------------------------+
|Função   | DLGA250 - Cadastro de Produto x Zona                               |
+---------+--------------------------------------------------------------------+
|Objetivo | Um produto pode estar em mais de uma zona. Esta amarracao          |
|         | Produto x Zona determina o fluxo de enderecamento, a medida que a  |
|         | capacidade da zona de armazenagem for esgotando.                   |
+---------+--------------------------------------------------------------------+
*/
Function DLGA250()
Return WMSA250()
