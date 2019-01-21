pragma solidity ^0.4.25;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// Anotamos el interface estandard ERC20.
// ----------------------------------------------------------------------------

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

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
    mapping (address => uint) public balances; // anotamos los tokens pendientes de enviar al inversor.
    uint remainingAutorice;
    
    
    constructor (uint _minimumContribution, uint _maxContribution, address _addresVotekstoken, uint _ratio) public  {    // Constructor Campaign. MinimumContribution is parameter. Argument must be introduced.
        manager = msg.sender;                           // who deploy is the manager
        minimumContribution = _minimumContribution;     // Init minimumContribution internal varialble
        numContributors = 0 ;                           // Init index of contributors mapping

        // address del token ERC20 VOTEKS utilizado por Kickstart en
        addressVotekstoken = _addresVotekstoken;
        maxContribution = _maxContribution * 1 ether;
        ratio = _ratio;
        totalSupply = ERC20Interface(addressVotekstoken).balanceOf(msg.sender); // al inicio el manager dispone de todo el saldo de tokens = _totalSupply
//      const totalSupply = VoteKickstart.methods._totalSupply; /// ¿como haríamos la llamada directamente a la variable pública del contracto del ERC20 _totalSupply?
    }

    function getTotalSupply () public view returns (uint) {
        return totalSupply;
    }
    
    function getmaxContribution () public view returns (uint) {
        return maxContribution;
    }

//No es necesario el autorice?
    function autoriceManager () public returns (uint) { // NO
        //Debemos autorizar previamente a transferir de la cuenta del manager a la cuenta del Investor.
        //El token owner deber autorizar al manager del contrato. En este caso es el mismo.
        //En este caso el propio manager se autoriza a transferir los tokens desde la cuenta del manager al investor.
        // ponemos una cantidad máxima de 1000 que en una implementacion de mejora deberia ser un parametro maxContribution del contract.
        ERC20Interface(addressVotekstoken).approve(msg.sender, maxContribution);
        remainingAutorice = ERC20Interface(addressVotekstoken).allowance(msg.sender,msg.sender);
        return remainingAutorice;
    }
    
    function getremainingAutorice() public view returns(uint) {
        return remainingAutorice;
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
        balances[msg.sender] = msg.value;
    }
    
    function sendTokensBalance (address _addressInvestor) public {
        // unicamente funciona correctamente si contribute se ejecuta desde la cuenta del manager con saldo de tokens 
        addressInvestor = _addressInvestor;
        ERC20Interface(addressVotekstoken).transfer(addressInvestor, balances[addressInvestor]);
        // si la transferencia es correcta reseteamos el balance
        balances[addressInvestor]= 0;
    }
    
    function sendFixTokens () public {
        //test transfer fucntion 3*10^18 to account 3
        ERC20Interface(0xcbbe6ec46746218a5bed5b336ab86a0a22804d39).approve(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c, 3000000000000000000);
        ERC20Interface(0xcbbe6ec46746218a5bed5b336ab86a0a22804d39).transferFrom(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c,0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db, 3000000000000000000);

 //       ERC20Interface(0xcbbe6ec46746218a5bed5b336ab86a0a22804d39).transfer(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db, 3000000000000000000);

    }
     
     
       // si transferimos desde la cuenta del manager
//       ERC20Interface(addressVotekstoken).transferFrom(manager,msg.sender, msg.value*ratio);
//      Generamos un evento de trasnferencia en la funcion transferFrom
     
    
 
 // funcion para visualizar el número de tokens del Investor   
   function getBalanceTokens (address _addresInvestor) public view returns (uint){
       address addresInvestor = _addresInvestor;
//    function balanceOf(address tokenOwner) public constant returns (uint balance);
       return ERC20Interface(addressVotekstoken).balanceOf(addresInvestor);
   }
   
   
    // la funcion es public (non-payable default) puesto que no añade al balance del contrato pero modifica variables generales en BC?????.
    function createRequest (string _description, uint _amount, address _recipient) public {
        require (msg.sender == manager );               // unicamente puede ejecutar un Request si es el manager
        // permito crear un request aunque no tenga contributors pero no podra finalizar el request.
        // el importe sea com maximo el balance disponible
        require( _amount <= address(this).balance);
        // La direccion destino se autoriza que sea la del manager
        
        Request memory newRequest = Request({
           description: _description,
           amount: _amount,
           recipient: _recipient,
           complete: false,
           approvalCount:0
        });
        
//      requests[requests.length] = newRequest;     // ¡¡¡ con esta expresión no funciona la transacción¡¡¡
        requests.push(newRequest);                  // si es un array hay que realizar el push para escribir el valor
     }
    
// La funcionalidad de token establece que el numero de votos sera proporcional a la aportacion del inversor
// cada token representa un derecho de voto numero de votos= número de token = número de ethers * ratio
    
    function ApproveRequest () public {             
       // require Request not finalize. No podemos votar si esta cerrado el request actual.
       require (requests[requests.length-1].complete == false);
       // requiere not be manager. No le dejamos votar al manager
       require (msg.sender != manager);
        // require be investor. Requiere que la direccion que mapea el contributor sea diferente de 0x0.
        require(investorsMap[msg.sender].wallet != 0x0 );
       // require not vote previously
        require(requests[requests.length-1].approvalsMap[msg.sender] == false );
       // Add my @ to approvalsMap in current request structure
        requests[requests.length-1].approvalsMap[msg.sender] = true;
        // añadirmos un approver al approvalCount sin tokens
//        requests[requests.length-1].approvalCount++;
        // con tokens añadimos tantos approvalCount como votos tenga el inversor
        uint numVotos = getBalanceTokens (msg.sender);
        requests[requests.length-1].approvalCount = requests[requests.length-1].approvalCount + numVotos ;

    }                      
    
    function finalizeRequest () public {
        // require only executed by manager
        require(msg.sender == manager);
        
        // Sin tokens 
        //require approvalCount >= numContributors/2. Como mínimo necesitamos el voto afirmativo de la mitad +1 de los contributors.
        require (requests[requests.length-1].approvalCount >= 1+numContributors/2);
        // con tokens aprobaremos cuando el número de votos sea >= a la mitad +1 de los tokens traspasados a los inversores
        // el número de tokens traspasados a los inversores es totalSupply - el saldo del manager, puesto que los ha ido transfiriendo
        require (requests[requests.length-1].approvalCount >= (totalSupply-getBalanceTokens(manager))/2+1);
        
        //send money to recipient (vendor). Public transaccion non payable.
        //  En Remix la tranferencia la realiza en wei pero nuestra anotación se refiere a ethers 1 ether = 1*10^18 wei
       //  requests[requests.length-1].recipient.transfer(requests[requests.length-1].amount *1000000000000000000) ;
       // En visual estudio lo toma como ether
      requests[requests.length-1].recipient.transfer (requests[requests.length-1].amount * 1 ether);
    // declara Request completado cambiando el estado del variable complete a true 
        requests[requests.length-1].complete = true;
    }
    
    function getBalanceContract() public view returns(uint) {   // retorna la suma de contribuciones al proyecto
        return address(this).balance;                           // retorna el balance del smart contrcat. función this accede a SmartContract
    }
    
    function getMitadNumContributorsmas1 () public view returns (uint) {
        return 1+numContributors/2; // retorna la parte entera el valor mitad
    }
}