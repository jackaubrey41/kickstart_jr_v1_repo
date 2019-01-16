pragma solidity ^0.4.25;

contract Kickstart {
    
    // struct investor
    struct Investor {
        address wallet;
        string name;
        // posible variable de balanceInvestor para acumular varias aportaciones. 
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
    uint public minimumContribution;                   // Minimum donation required to be approver. Campaign argument
    mapping ( uint => address ) public approversMap;    // list of addresses of contributors indexed
    mapping ( address => Investor) public investorsMap;
    Request[] public requests;                        // List of requests created by mananager in this campaign. Dinamic array
    uint private numContributors;                       // contributors count index
                            
                                                            
    constructor (uint _minimumContribution) public {    // Constructor Campaign. MinimumContribution is parameter. Argument must be introduced.
        manager = msg.sender;                           // who deploy is the manager
        minimumContribution = _minimumContribution;     // Init minimumContribution internal varialble
        numContributors = 0 ;                           // Init index of contributors mapping
    }
    
    function contribute (string _name) public payable {             // Payable function
        require ( msg.value >= minimumContribution );       // Require that contribution is equal or major to minimumContribution
        require ( investorsMap[msg.sender].wallet == 0x0);   // Para que no se duplique, aunque seria interesante que pudiera ampliar la aportacion.
        numContributors++;                                  // increase number of contributors and index of array
        approversMap[numContributors] = msg.sender;         // set @ in list of contributors

        Investor memory newInvestor = Investor({
            wallet: msg.sender,
            name: _name
        });    
        investorsMap[msg.sender] = newInvestor;       
       
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
        } //si quitamos el corchete desaparecen todos los warnings¡¡¡¡ pero obviamente el test da error
    
    function ApproveRequest () public {             // Called to aprove
       // require Request not finalize. No podemos votar si esta cerrado el request actual.
       require (requests[requests.length-1].complete == false);
       // requiere not be manager. No le dejamos votar al manager
       require (msg.sender != manager);
        // require be investor. Requiere que la direccion que mapea el contributor sea diferente de 0x0.
        require(investorsMap[msg.sender].wallet != 0x0 );// test ok
       // require not vote previously
        require(requests[requests.length-1].approvalsMap[msg.sender] == false );//test ok
       // Add my @ to approvalsMap in current request structure
        requests[requests.length-1].approvalsMap[msg.sender] = true;
        // añadirmos un approver al approvalCount
        requests[requests.length-1].approvalCount++;

    }                      
    
    function finalizeRequest () public {
        // require only executed by manager
        require(msg.sender == manager);
        // require approvalCount >= numContributors/2. Como mínimo necesitamos el voto afirmativo de la mitad +1 de los contributors.
        require (requests[requests.length-1].approvalCount >= 1+numContributors/2);
        //send money to recipient (vendor). Public transaccion non payable.
        // En Remix la tranferencia la realiza en wei pero nuestra anotación se refiere a ethers 1 ether = 1*10^18 wei
        // requests[requests.length-1].recipient.transfer (requests[requests.length-1].amount*1000000000000000000);
        // En Visual studio utiliza unidad Ether
        requests[requests.length-1].recipient.transfer (requests[requests.length-1].amount);
        // declara Request completado cambiando el estado del variable complete a true 
        requests[requests.length-1].complete = true;
    }
    
    function getBalance() public view returns(uint) {   // retorna la suma de contribuciones al proyecto
        return address(this).balance;                   // retorna el balance del smart contrcat. función this accede a SmartContract
    }
    
    function getMitadNumContributorsmas1 () public view returns (uint) {
        return 1+numContributors/2; // retorna la parte entera el valor mitad
    }
    
}