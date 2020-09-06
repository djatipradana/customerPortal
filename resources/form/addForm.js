//  Web3 intializer
//  ABI definition, Binary Data and contract Address in contractDetails.js
//const Web3 = require('web3');

const web3 = new Web3(new Web3.providers.HttpProvider("https://ropsten.infura.io/v3/6a68c430ab2e43adb0762c4cfa9bbb42"));
/*var kycContract = web3.eth.contract(abi);
var deployedContract = kycContract.new({
    data: binaryData,
    from: web3.eth.accounts[0],
    gas: 4700000
});
var contractInstance = kycContract.at(contractAddress); */

const contractInstance = new web3.eth.Contract(abi, contractAddress);

//  account to make all transactions
var current_privkey = localStorage.getItem("accountPrivKey");
var current_address = localStorage.getItem("accountAddress");
var current_username = localStorage.getItem("username");
var current_bankName = localStorage.getItem("bankName");

window.onload = function() {
    //document.getElementById("uname").innerHTML = current_username;
    //document.getElementById("bank_name").innerHTML = current_bankName;
}

//var current_account = localStorage.bank_eth_account.toString();


web3.eth.defaultAccount = current_address;
let privateKey1 = new ethereumjs.Buffer.Buffer(ownerPrivateKey, 'hex');

function sendSign(myData,gasLimit){
    web3.eth.getTransactionCount(ownerAccountAddress, (err, txCount) => {
    // Build the transaction
    const txObject = {
        nonce:    web3.utils.toHex(txCount),
        to:       contractAddress,
        value:    web3.utils.toHex(web3.utils.toWei('0', 'ether')),
        gasLimit: web3.utils.toHex(gasLimit),
        gasPrice: web3.utils.toHex(web3.utils.toWei('12', 'gwei')),
        data: myData  
    }
    // Sign the transaction
    //const tx = new Tx(txObject);
    const tx = new ethereumjs.Tx(txObject);
    tx.sign(privateKey1);

    const serializedTx = tx.serialize();
    const raw = '0x' + serializedTx.toString('hex');

    // Broadcast the transaction
     /*const transaction = web3.eth.sendSignedTransaction(raw, (err, tx) => {
        console.log(tx)
    }); */

    const transaction = web3.eth.sendSignedTransaction(raw)
        .on('transactionHash', hash => {
            console.log('TX Hash', hash)
            alert('Transaction was send, please wait ... ')
            console.log("https://ropsten.etherscan.io/tx/"+ hash);
        })
        .then(receipt => {
            console.log('Mined', receipt)
            console.log("Your transaction was mined...")
            //setTimeout(function () { location.reload(1); }, 1000);
            console.log(receipt.status)
            if(receipt.status == true ) {
                console.log('Transaction Success')
                alert("Customer profile successfully created or updated. \nCheck the customer details from the KYC Details tab.");
                document.location.assign('../../customerHomePage.html');
                return false;
                //alert('Transaction Success')
            }
            else if(receipt.status == false) {
                console.log('Transaction Failed')
                alert("Customer profile hasn't been successfully created or updated. \nPlease try again.");
                setTimeout(function () { location.reload(1); }, 500);
                return false;
            }
        })
        .catch( err => {
            console.log('Error', err)
            //alert('Transaction Failed')
        })
        .finally(() => {
            console.log('Extra Code After Everything')
        })
    });
    
    
}


//  function to create a new KYC profile

function onClickSend() {
    //document.getElementById("uname").innerHTML = current_username;
    //document.getElementById("bank_name").innerHTML = current_bankName;
    //var username = document.getElementById("uname").value;
    
    var data = getInfo();
    console.log(data)
    addCust(current_address, current_username, data, current_bankName);

}

async function addCust(current_address, current_username, data, current_bankName) {
    /*let addCust = await contractInstance.methods.addCustomer(current_address, current_username, data, current_bankName).send({
        from: current_address,
        gas: 4700000
    }); */

    let addCust = await contractInstance.methods.addCustomer(current_address, current_username, data, current_bankName).encodeABI();
    sendSign(addCust,500000);

    /*let addCust2 = await contractInstance.methods.addCustomer2(current_username, username, occupation, income, dob, gender, residence).send({
        from: current_address,
        gas: 4700000
    });
    let addCust3 = await contractInstance.methods.addCustomer3(current_username, username, country, phone1, phone2, email, current_bankName).send({
        from: current_address,
        gas: 4700000
    }); */
    
    /*if (addCust == 0 ) {
        alert("Customer profile successfully created or updated. \nCheck the customer details from the KYC Details tab.");
        document.location.assign('../../customerHomePage.html');
        return false;
    } else {
        alert("Customer profile hasn't been successfully created or updated. \nPlease try again.");
        return false;
    }   */
}


//  function to extract data from the form

function getInfo() {
    var first_name = document.getElementById("first_name").value;
    var middle_name = document.getElementById("middle_name").value;
    var last_name = document.getElementById("last_name").value;
    var nik = document.getElementById("nik").value;
    var occupation = document.getElementById("occupation").value;
    var income = document.getElementById("income").value;
    var dob = document.getElementById("dob").value;
    if (document.getElementById("gender_m").checked) {
        var gender = "Male";
    } else {
        gender = "Female";
    }
     
    var residence = document.getElementById("residence").value;
    var country = document.getElementById("country").value;
    var phone1 = document.getElementById("phone1").value;
    var phone2 = document.getElementById("phone2").value;
    var email = document.getElementById("email").value;

    var data = "!@#" + first_name + "!@#" + middle_name + "!@#" + last_name + "!@#" + nik + "!@#" + occupation + "!@#" + income.toString() + "!@#";
    data =  dob.toString() + "!@#" + gender + "!@#" + residence + "!@#" + country + "!@#" + phone1 + "!@#" + phone2 + "!@#" + email + "!@#";

    return data;
}


//window.onload=onClickSend();
//window.onload=onClickDelete();