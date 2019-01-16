const assert = require("assert");
const ganache = require ("ganache-cli");
const Web3 = require ("web3");
const web3 = new Web3(ganache.provider());
const {interface, bytecode} = require ("../compile");

let accounts;
let kickstartjr; // kickstartjr, nombre del fichero .sol en lugar de inbox. Es una declaración de variable.

before( async () => {
    // get list of all accounts
    accounts = await web3.eth.getAccounts();

    // use one of these accounts to deploy the contract
    kickstartjr = await new web3.eth.Contract(JSON.parse(interface))
    .deploy ({
        data: bytecode,
        arguments: [1]                  //argumento necesario en el deploy del contrato
    })
    // la transacción tiene parámetros extra
    .send ({ from: accounts[0], gas: "5000000"}); //.send cuando es una transacción

});


describe ("Kickstart", ()=> {           
    it ("deploy a contract", () => {            //testeamos si podemos hecer deploy del contrato "Nombredelcontrato"
    assert.ok (kickstartjr.options.address);    // si tenemos un address valido del contrato consideraremos que el deploy se ha realizado
});

    it("MinimumContribution", async () => {     //  contribución mínima
        const minima = await kickstartjr.methods.minimumContribution().call();
        assert.equal( minima, 1);   
    })    
    
    it("Investor Balance", async () => {
        await kickstartjr.methods.contribute('Marc').send({from: accounts[1], gas: '5000000', value: '2' });
        const balance = await kickstartjr.methods.getBalance().call();
        assert.equal( balance, 2);
        const name = await kickstartjr.methods.getBalance().call();
        assert.equal( balance, 2);
    })
    
    it("Investor approversMap", async () => {
        await kickstartjr.methods.contribute('Joan').send({from: accounts[2], gas: '5000000', value: '2' });
        //const balance = await kickstartjr.methods.getBalance().call();
        //assert.equal( balance, 2);
        const investorAddress = await kickstartjr.methods.approversMap(2).call();
        assert.notEqual( investorAddress, 0x0);  // hay un @ en el segundo approverMap
    })
    
    it("createRequest", async () => {
        await kickstartjr.methods.createRequest('Request 0', 2, accounts[4]).send({from: accounts[0], gas: '5000000'});
        const requestsin0 = await kickstartjr.methods.requests(0).call();
        console.log ( "amount in request is ",requestsin0.amount);
        assert.equal( requestsin0.amount, 2); 
        assert.notEqual (requestsin0.amount,1);  
      })

    it ("Aprove Request", async () => {
        await kickstartjr.methods.ApproveRequest().send ({from: accounts[1], gas: "5000000" });
        await kickstartjr.methods.ApproveRequest().send ({from: accounts[2], gas: "5000000" });
        const requestsin0 = await kickstartjr.methods.requests(0).call();
        console.log ("number of approvals is ",requestsin0.approvalCount);
        assert.equal (requestsin0.approvalCount, 2);
    });

    it ("Finalize Request", async () => {
        const requestsin0 = await kickstartjr.methods.requests(0).call();
        console.log ("number of approvals is ",requestsin0.approvalCount);
        console.log ("Is request complete? ", requestsin0.complete);
        const mitadcontributorsmas1 = await kickstartjr.methods.getMitadNumContributorsmas1().call();
        const balance = await kickstartjr.methods.getBalance().call();
        console.log ("Balance to transfer is", balance);
        console.log ("contributors/2+1 is ", mitadcontributorsmas1);
        // Finalizamos el request una vez vemos que cumple con los requisitos
        await kickstartjr.methods.finalizeRequest().send ({from: accounts[0], gas: "5000000" });
        const requestsin01 = await kickstartjr.methods.requests(0).call();
        console.log ("Is request complete after finalize? ", requestsin01.complete);
        assert.equal (requestsin01.complete, true);
    });


    /*
    it ("contribute investor OK", async() => {
        await kickstartjr.methods.contribute("Marc").send ({ from: accounts[1], gas: "1000000", value :"20000000000000000000"}); //faltan los Ethers¡¡
        const name = kickstartjr.investorsMap[accounts[1]].name ;
        assert.equal (name,"Marc");
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