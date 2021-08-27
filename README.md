# preco_medio_ativos

###
**Resumo**: pequeno script para calcular o preço médio de ações em um dataframe considerando a ordem temporal de compra e venda entre esses diferentes ativos.
###

Considerando um investidor que toda vez que executa uma operação de venda ou de compra de um ativo negociado na bolsa de valores, anota tais informações, me deparei com um problema: sendo seis variáveis (ticker de determinado ativo, data da operação, tipo da operação - se foi uma compra ou uma venda, quantidade negociada, preço de compra ou de venda, e o valor total da operação) os dados mais relevantes, com diversas observações (negociações), se simplesmente fizermos o valor da operação dividido pela quantidade negociada para todos esses ativos, com o objetivo de obter o preço médio, incorreríamos no erro de não considerar a ordem temporal de compra e venda entre esses diferentes ativos.

Há um tempo atrás, mais ou menos quando iniciei meus estudos em R, com o foco em calcular automatizadamente os preços médios (considerando as ordens de compra e venda), criei um script que recebia como input um arquivo _.xlsx_ contendo essas seis variáveis; e como output retornava um arquivo _.xlsx_ com duas variáveis (ticker e preço médio).

**Nota**: claramente o código pode ser otimizado, porém com a ideia de expor o processo de criação 'raw' de um iniciante, deixei da forma em que se encontrava.

Como foi esse processo?

**1.** Lê-se o arquivo gerado pelo investidor com diferentes observações para as seis variáveis;

**2.** Criou-se uma função em que recebe como argumento uma _string_ de um ticker de uma ação que foi negociada pelo investidor, ou seja, que está dentro do arquivo dado como input (por exemplo, "MOVI3").

**2.1**. Para esta ação, primeiro é criada uma coluna de saldo das quantidades, onde temos que caso o _'tipo = C'_ (uma compra): **(i)** se for a primeira observação, será igual à quantidade negociada; **(ii)** caso contrário, será o saldo no período _t-1_ somado ao saldo no período _t_. Caso o _'tipo = V'_ (uma venda): teremos o saldo no período _t-1_ subtraído do saldo no período _t_.

**2.2.** Após isso, é criada uma coluna com o custo total até o período _t_. Caso o _'tipo = C'_ (uma compra): **(i)** se for a primeira observação, será igual ao valor total da operação; **(ii)** caso contrário, será o custo total no período _t-1_ somado ao valor total no período _t_. Caso o _'tipo = V'_ (uma venda): teremos o custo total no período _t-1_.

**2.3.** Por fim, é criada uma coluna com o preço médio (pode-se observar como ele varia com o tempo). Caso o _'tipo = C'_ (uma compra): **(i)** se for a primeira observação, será igual ao preço pago; **(ii)** caso contrário, será o preço médio de compra em _t-1_ multiplicado pelo saldo de quantidade em _t-1_ somado ao valor total da operação em _t_, tudo isso dividido pelo saldo de quantidade em _t_. Caso o _'tipo = V'_ (uma venda): teremos o preço médio no período _t-1_.

**2.4.** Foi criada ainda uma coluna para observar os resultados das vendas (quando houve), para saber se foi incorrido em um lucro ou prejuízo. Aqui, caso o _'tipo = C'_ (uma compra), o resultado será igual à zero. Caso o _'tipo = V'_ (uma venda), o resultado será igual ao preço da venda em _t_ multiplicado pela quantidade vendida subtraindo o preço médio de compra multiplicado pela quantidade em _t_.

**3.** É feito então um processo iterativo, onde para cada ativo uma vez negociado, a função é aplicada.

**4.** Por fim, temos nosso output, contendo os ativos e seus preços médios (considerando a ordem de compra).
