const assert = require("assert");
const ganache = require ("ganache-cli");
const Web3 = require ("web3");
const web3 = new Web3(ganache.provider());
const {interface, bytecode} = require ("../compile");

let accounts;
let kickstartjr; // kickstartjr, nombre del fichero .sol en lugar de inbox. Es una declaración de variable.

beforeEach( async () => {
    // get list of all accounts
    accounts = await web3.eth.getAccounts();

    // use one of these accounts to deploy the contract
    kickstartjr = await new web3.eth.Contract(JSON.parse(interface))
    .deploy ({
        data: bytecode,
        arguments: [1]                  //argumento necesario en el deploy del contrato
    })
    // la transacción tiene parámetros extra
    .send ({ from: accounts[0], gas: "1000000"}); //.send cuando es una transacción

});

describe ("Kickstart", ()=> {           //testeamos si podemos hecer deploy del contrato "Nombredelcontrato"
    it ("deploy a contract", () => {
    assert.ok (kickstartjr.options.address);  // si tenemos un address valido del contrato consideraremos que el deploy se ha realizado
});

/*
    it ("has a default message", async() => {
     const message = await inbox.methods.getMessage().call(); // el call no necesita parámetros
     assert.equal (message, "Hi there");    
    });
    
    it ("can change the message", async() => {
    await inbox.methods.setMessage("bye").send({from: accounts[0]}); // enviamos una transacción
    const message = await inbox.methods.getMessage().call();
    assert.equal (message, "bye"); 
    });

*/

});