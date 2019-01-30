pragma solidity ^0.4.25;

// ----------------------------------------------------------------------------
// 'VOTE KICKSTART' token contract
//
// direccion de deploy en account  1 de Ropsten
// Deployed to : 0xc1f0A5c6CFA9eDDa352336e9E8202BC097E72C68  // importante especificar direccion de token owner
//
// direccion de deploy en Remix JavaScript VM account1
//Depoyed to: 0xca35b7d915458ef540ade6068dfe2f44e8fa733c
//
// Symbol      : VOTEKS
// Name        : VoteKickstart
// Total supply: 100000000
// Decimals    : 18
//
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
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


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
//
// ----------------------------------------------------------------------------
//¡¡¡ línea de edición nombre del contrato de nuestro token
contract VoteKickstart is ERC20Interface, Owned, SafeMath {         
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

//  variable del Constructor que indican en que direccion se reciben los tokens.
    address managerTokens;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(address _managerTokens) public { // en teoría el manuel indica introducir el nobre del contrato ?
        symbol = "VOTEKS";                          //Puede pasarse como parámetro puesto que hay que crear un token  por campaña
        name = "VoteKickstart";                     //Puede pasarse como parámetro puesto que hay que crear un token  por campaña
        decimals = 0;                               // nos facilita el control no utilizar decimales
        _totalSupply = 100000000000000000000000000; // total suplay número de unidades indivisibles ( "0's"= número de tokens + decimales)
        managerTokens = _managerTokens;

//      Como mejora pasamos la @ del account que debe recibir el total de totalSupply tokens como argumento del constructor del token.
//      En nuestro caso es el manager de la campaña a desplegar.
//      Introducir dirección de wallet que reciben el total tokens en el despliegue
        balances[managerTokens] = _totalSupply; 
        emit Transfer(address(0), managerTokens, _totalSupply);

//      direccion cuando desplegamos sobre red Ropsten. 
//        balances[0xc1f0A5c6CFA9eDDa352336e9E8202BC097E72C68] = _totalSupply;
//        emit Transfer(address(0), 0xc1f0A5c6CFA9eDDa352336e9E8202BC097E72C68, _totalSupply);

//      direccion cuando desplegamos sobre red Remix. 
//        balances[0xca35b7d915458ef540ade6068dfe2f44e8fa733c] = _totalSupply; 
//        emit Transfer(address(0), 0xca35b7d915458ef540ade6068dfe2f44e8fa733c, _totalSupply);

    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    /*
    Transfer
    The Transfer function, along with the TransferFrom function defined below, are the heart & soul of any ERC20 token; 
    these two functions are responsible for every transaction into an ERC20-based platform & within it’s ERC20 token transactions. 
    The Transfer function is for explicitly sending the ERC20 token from a single wallet owned by the user to another peer wallet address. 
    Since it’s the actual wallet owners themselves that call this function, only the the following inputs are required: 
    the receiver address & the token amount. 
    The return value is another boolean that confirms whether the receiver (the “to” address) received the tokens sent.
     */
    // ------------------------------------------------------------------------
    
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    /*
    TransferFrom
    The TransferFrom function allows for a smart contract to execute a transfer on behalf of the wallet owner. 
    Notice the difference: the Transfer is called by the wallet owner him or herself to directly send tokens to another address. 
    This time, the TransferFrom function allows for a smart contract to send tokens on the wallet owner’s behalf, 
    such as filling an order on an exchange, releasing funds in a timely manner, or paying our winnings in aa game of luck.
    */
   // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account. The spender contract function
    // receiveApproval(...) is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}
