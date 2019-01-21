
Documentación erc20_tutorialvjr.sol

* El token de voto desplegado es un ERC20.
* El contract del token ERC20 se denomina VoteKickstart

Descripción VoteKickstart contract:

Asignaremos a cada Investor un token VOTEKS ( Voto de Kicksatarter), por cada Ether invertido.
El ratio es de 1 VOTEKS = 1 Ether.

Votekickstart tiene un argumento que es la dirección del manager de la campaña el cual recibirá los 100M de tokens creados. De esta forma el deploy del token es posible realizarlo desde caulquier cuenta. Típicamente será la del manager de la campaña, pero podría ser desde cualquier otra por ejemplo la del administrador de Kickstarter. Los tokens generados ( _totalSupply) seran anotados en la @ del manager pasada como argumento.


Documentación kickstarv2.sol

Branch de versión kiskstarjr.sol incluyendo tokens de voto.

La campaña del contrato Kickstart debe ser desplegada por el mismo manager indicado en el despligue del token y que dispondrá inicialmente del totalSupply de tokens. En nuestro caso 100M. 

_Duda 1. Podemos acceder a la variable _totalSupply del ERC20?_

Para el deploy del Kickstart contract contaremos con 4 argumentos en el constructor:

1. Mínima contribution
2. Máxima contribución.
3. La dirección del contrato desplegado del token VOTEKS
4. El ratio de retribución de tokens por Ether. Típicamente 1



