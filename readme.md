# <center align="center">Allowance Smart Contract</center>

Um contrato inteligente (Smart Contract) com funcionalidades de permissão de valor para alguma carteira crypto por um estimado período de tempo, bloqueando o acesso à esse valor após o prazo acabar. É possível atribuir mesada/subsídio especificando o valor e o tempo de permissão para a carteira, revogar a permissão e sacar os valores de volta do contrato.

O contrato foi feito em **Solidity**, destinado para blockchains como Ethereum, Polygon, ou qualquer outra que possua integração com a linguagem Solidity.

----

## Sumário das funções do contrato:

1. ### Funções de leitura de valores:
   
   1. #### [getTotalBalance](#gettotalbalance) (obterSaldoTotal)
   2. #### [getMyBalance](#getmybalance) (obterMeuSaldo)
   3. #### [getAllMyAllowanceBalances](#getallmyallowancebalances) (obterTodosOsMeusSaldosDeSubsídio)
   4. #### [getMyReservedBalanceFrom](#getmyreservedbalancefrom) (obterMeuSaldoReservadoDe)
   5. #### [getMyAllowanceFrom](#getmyallowancefrom) (obterMeuSubsídioDe)

2. ### Funções de subsídio:
   
   - #### Atribuir subsídio/mesada:
     1. #### [giveAllowance](#giveallowance) (atribuirSubsídio)
     2. #### [depositAndGiveAllowance](#depositandgiveallowance) (depositarEAtribuirSubsídio)
     3. #### [transferAndGiveAllowance](#transferandgiveallowance) (transferirEAtribuirSubsídio)
   - #### Revogar subsídio/mesada:
     1. #### [revokeAllowanceOf](#revokeallowanceof) (revogarSubsídioDe)
     2. #### [redeemFreeValueFromTheBalanceOf](#redeemfreevaluefromthebalanceof) (resgatarValorDisponívelDoSaldoDe)

3. ### Funções de saque:
   
   1. #### [withdrawFromMyBalance](#withdrawfrommybalance) (sacarDoMeuSaldo)
   2. #### [withdrawFromAllowance](#withdrawfromallowance) (sacarDeSubsídio)

---

## Funções de leitura de valores:

1. ### <a name="gettotalbalance"></a> getTotalBalance (obterSaldoTotal)
   
   Obtém o saldo total do contrato, todo o valor que está depositado nele.

2. ### <a name="getmybalance"></a> getMyBalance (obterMeuSaldo)
   
   Obtém o saldo da carteira que executa a função, o valor disponível que esta carteira possui depositada no contrato (um valor que é atribuído como subsídio/mesada à uma carteira não mais faz parte do saldo da carteira que atribuiu).

3. ### <a name="getallmyallowancebalances"></a> getAllMyAllowanceBalances (obterTodosOsMeusSaldosDeSubsídio)
   
    Obtém todo o saldo proveniente de subsídios/mesadas, a soma de todos os subsídios/mesadas atribuídas à carteira que executa a função.

4. ### <a name="getmyreservedbalancefrom"></a> getMyReservedBalanceFrom (obterMeuSaldoReservadoDe)
   *\[Parâmetro:
   **_allowner**: representa o endereço da carteira do qual se quer verificar o saldo.\]* 
   
    Obtém da carteira passada (**\_allowner**) o saldo de dinheiro reservado desta para a carteira que executa a função. 
    (Ex: a carteira A tem reservado 5 Ethers para a carteira B, mas dá um subsídio de apenas 1 Ether para a carteira B. Quando esta função for chamada pela carteira B retornará o valor de 5 Ether pois esse é o saldo que está reservado da carteira A para ela, mesmo que somente 1 Ether esteja disponível no subsídio.)

5. ### <a name="getmyallowancefrom"></a> getMyAllowanceFrom (obterMeuSubsídioDe)
	*\[Parâmetro:
	**_allowner**: representa o endereço da carteira do qual se quer verificar o subsídio.\]*
	
	Obtém os dados do subsídio/mesada recebido pela carteira passada como parâmetro (**\_allowner**). Os dados são:
    
	- Índice (número identificador do subsídio)
	- Horário (quando o subsídio foi feito, em formato timestamp)
	- Duração (tempo de permissão do subsídio)
	- Tempo restante (quanto tempo resta até acabar a duração do subsídio)
	- Tempo atual do block (em formato timestamp)
	- Valor (valor permitido para sacar deste subsídio)

## Funções de subsídio:

- ### Atribuir subsídio/mesada:
  
	1. ### <a name="giveallowance"></a> giveAllowance (atribuirSubsídio)
	     *\[Parâmetros: <br>
	     **_to**: representa o endereço da carteira que se quer dar o subsídio.<br>
	     **_duration**: o tempo (em segundos) de duração do subsídio.<br>
	     **_amount**: a quantidade a ser permitida.\]* 
	     
	      Atribui um subsídio à uma carteira, especificando o endereço desta (**\_to**), a duração (**\_duration**) e a quantidade do subsídio (**\_amount**). 
	      **O dinheiro é retirado do saldo já reservado para esta carteira.**
	     
		 Ex:  é dado um subsídio da carteira A para a carteira B com o valor de 5 Ethers, mas logo em seguida se quer dar um novo subsídio com um valor inferior, 3 Ethers por exemplo. Não há necessidade de se adicionar mais Ethers para dar um novo subsídio, pode se criar um novo com base no valor reservado que já existe da carteora A para a carteira B, basta apenas que o "**\_amount**" seja um valor menor ou igual ao saldo reservado para a carteira que se quer subsidiar.
	     
	     Ou seja, esta função deve ser usada caso já exista um saldo reservado para a carteira "**\_to**" e se quer criar um subsídio com base nesse valor existente, sem precisar depositar/transferir algum valor.
	     
	     *Caso queira dar um subsídio ao mesmo tempo em que se deposita o valor, use a função [depositAndGiveAllowance](#depositandgiveallowance); se quiser dar um subsídio com o valor do saldo da carteira que irá subsidiar, use a função [transferAndGiveAllowance](#transferandgiveallowance)*.
	2. ### <a name="depositandgiveallowance"></a> depositAndGiveAllowance (depositarEAtribuirSubsídio)
	     *\[Parâmetros: <br>
	     **_to**: representa o endereço da carteira que se quer dar o subsídio.<br>
	     **_duration**: o tempo (em segundos) de duração do subsídio.\]*
	     
	     Atribui um subsídio à uma carteira ao mesmo tempo em que se deposita o valor no contrato, especificando o endereço da carteira (**\_to**) e a duração (**\_duration**). O valor depositado equivale ao valor do subsídio.
	     
	     *Caso queira dar um subsídio com base em um valor que já exista no saldo reservado de determinada carteira, use a função [giveallowance](#giveallowance); se quiser dar um subsídio com o valor do saldo da carteira que irá subsidiar, use a função [transferAndGiveAllowance](#transferandgiveallowance)*.
	
	3. ### <a name="transferandgiveallowance"></a> transferAndGiveAllowance (transferirEAtribuirSubsídio)
		*\[Parâmetros: <br>
		**_to**: representa o endereço da carteira que se quer dar o subsídio.<br>
		**_duration**: o tempo (em segundos) de duração do subsídio.<br>
		**_amount**: a quantidade a ser permitida.\]*
		
		Atribui um subsídio à uma carteira ao mesmo tempo em que se transfere o valor de seu próprio saldo para esta carteira, especificando o endereço desta (**\_to**), a duração (**\_duration**) e a quantidade do subsídio (**\_amount**; a quantidade é a quantidade que será transferida do saldo de quem executa a função). 
		**O dinheiro é retirado do saldo de quem executa a função, ocorrendo uma transferência do valor.**
		
		*Caso queira dar um subsídio com base em um valor que já exista no saldo reservado de determinada carteira, use a função [giveallowance](#giveallowance); se quiser dar um subsídio ao mesmo tempo em que se deposita o valor, use a função [depositAndGiveAllowance](#depositandgiveallowance).
- ### Revogar subsídio/mesada:
  
  1. ### <a name="revokeallowanceof"></a> revokeAllowanceOf (revogarSubsídioDe)
	  *\[Parâmetro:<br>
	  **_wallet**: representa o endereço da carteira do qual se quer revogar o subsídio.\]*
	  
	  Revoga um subsídio dado à uma carteira (**\_wallet**) e resgata o valor que ainda não foi usado, transferindo de volta para o saldo de quem deu o subsídio/executa a função.
  
  2. ### <a name="redeemfreevaluefromthebalanceof"></a> redeemFreeValueFromTheBalanceOf (resgatarValorDisponívelDoSaldoDe)
	  *\[Parâmetro:<br>
	  **_wallet**: representa o endereço da carteira do qual se quer resgatar o valor.\]*
	  
	  Resgata o valor livre de uma carteira (**\_wallet**), transferindo de volta para a carteira que tinha tranferido este valor. Valor livre significa um valor reservado para uma carteira que não está sendo aplicado em nenhum subsídio.
	  
	  Ex: a carteira A tem 5 Ethers reservados para a carteira B, mas no momento existe um subsídio de apenas 1 Ether atribuído para a carteira B. A carteira A pode resgatar os 4 Ethers livres chamando a função *redeemFreeValueFromTheBalanceOf*, isso fará com que a carteira A consiga sacar todo o valor disponível com exceção do valor subisidiado.

## Funções de saque:

1. ### <a name="withdrawfrommybalance"></a> withdrawFromMyBalance (sacarDoMeuSaldo)
	*\[Parâmetro:<br>
	**_amount**: representa o valor a ser sacado.\]*
	
	Saca de seu próprio saldo, o valor depositado no contrato, a quantidade especificada (**\_amount**) (para sacar valores que estão sendo usados em subsídios, primeiro revogue os subsídios para resgatar os valores).

2. ### <a name="withdrawfromallowance"></a> withdrawFromAllowance (sacarDeSubsídio)
	*\[Parâmetro:<br>
	**_allowner**: o endereço da carteira que deu o subsídio, de quem se quer sacar.<br>
	**_amount**: representa o valor a ser sacado.\]*
	
	Saca a quantida especificada (**\_amount**) de um subsídio atribuído a você por alguma carteira (**\_allowner**)(Para sacar valores que estão sendo usados em subsídios, primeiro revogue os subsídios para resgatar os valores).