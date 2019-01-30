pragma solidity ^0.4.25;

import "./erc20_token_v2_1.sol";

contract Kickstart {
    
    // struct investor
    struct Investor {
        address wallet;
        string name;
        //Utilizamos para conocer el saldo la funcion balanceOf del token. 
    }
    
    //struct of Request
    struct Request {
        string description;                             // Purpose of Request
        uint amount;                                    // Ether to transfer
        address recipient;                              // Who gets de money
        bool complete;                                  // Whether the request is done
        mapping ( address => bool) approvalsMap;        // Track who has voted, 0x0 no voted, T or F voted.
        uint approvalCount;                             // Track number of approvals. Increase 1 with each approval.
    }
    
    // Variables de tipo storage grabadas en el blockchain
    address public manager;                             // @ of person who is managin campaign. Campaign argument
    uint public minimumContribution;                    // Minimum donation required to be approver. Campaign argument
    mapping ( uint => address ) public approversMap;    // list of addresses of contributors indexed
    mapping ( address => Investor) public investorsMap;
    Request[] public requests;                          // List of requests created by mananager in this campaign. Dinamic array
    uint private numContributors;                       // contributors count index

    // variables a utilizar en el uso del token
    address addressVotekstoken;     // dirección donde esta desplegado nuestro token
    uint maxContribution;           // máxima numero de tokens autorizados a devolver al inversor.
    uint ratio;                     // Introducimos ratio, el número de tokens a entregar por ether, tipicamente sera 1 tokens = 1 Ether
    uint totalSupply ;               // Necesitamos conocer el número máximo de token emitidos y transferidos al manager.
    address addressInvestor;
    mapping (address => uint) public balances2; // anotamos los tokens pendientes de enviar al inversor no debemos usuar la misma variable que en el contrato del token
    uint remainingAutorice;
    
    
    constructor (uint _minimumContribution, uint _maxContribution, address _addresVotekstoken, uint _ratio) public  {    // Constructor Campaign. MinimumContribution is parameter. Argument must be introduced.
        manager = msg.sender;                           // who deploy is the manager
        minimumContribution = _minimumContribution;     // Init minimumContribution internal varialble
        numContributors = 0 ;                           // Init index of contributors mapping

        // address del token ERC20 VOTEKS utilizado por Kickstart en
        addressVotekstoken = _addresVotekstoken;
        maxContribution = _maxContribution * 1 ether;
        ratio = _ratio;
        totalSupply = ERC20Interface(addressVotekstoken).totalSupply(); // Llamada directamente a la funcion del ERC20 totalSupply().
    }

    function getTotalSupply () public view returns (uint) {
        return totalSupply;
    }
    
    function contribute (string _name) public payable {             // Payable function
        require ( msg.value >= minimumContribution );       // Require that contribution is equal or major to minimumContribution
        require (msg.value <= maxContribution);             // maxContribution in ethers
        require ( investorsMap[msg.sender].wallet == 0x0);   // Para que no se duplique, aunque seria interesante que pudiera ampliar la aportacion.
        numContributors++;                                  // increase number of contributors and index of array
        approversMap[numContributors] = msg.sender;         // set @ in list of contributors

        Investor memory newInvestor = Investor({
            wallet: msg.sender,
            name: _name
        });    
        investorsMap[msg.sender] = newInvestor;
        // anotamos el balance de tokens pendientes de enviar al Investor
        balances2[msg.sender] = msg.value;
    }

// no funciona cuando realizamos la tranferencia de tokens ¡¡¡¡  
    function sendTokensBalance (address _addressInvestor) public {
        // unicamente deberia funcionar correctamente si contribute se ejecuta desde la cuenta del manager con saldo de tokens 
        addressInvestor = _addressInvestor;
//        uint c = balances2[addressInvestor];
        uint c = 999;
        ERC20Interface(addressVotekstoken).transfer(addressInvestor, c);
        // si la transferencia es correcta reseteamos el balance
        balances2[addressInvestor]= 0;
    }
    

 // funcion para visualizar el número de tokens del Investor   
   function getBalanceTokens (address _addresInvestor) public view returns (uint){
       address addresInvestor = _addresInvestor;
       return ERC20Interface(addressVotekstoken).balanceOf(addresInvestor);
   }
   
   
 
}
