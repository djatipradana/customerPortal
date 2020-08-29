//  Web3 intializer
//  ABI definition, Binary Data and contract Address in contractDetails.js
//const Web3 = require('web3');
//const Tx = require('ethereumjs-tx'); 

const web3 = new Web3(new Web3.providers.HttpProvider("https://ropsten.infura.io/v3/6a68c430ab2e43adb0762c4cfa9bbb42"));
/*var kycContract = web3.eth.contract(abi);
var deployedContract = kycContract.new({
    data: binaryData,
    from: web3.eth.accounts[0],
    gas: 4700000
});
var contractInstance = kycContract.at(contractAddress); */
const contractInstance = new web3.eth.Contract(abi, contractAddress);
var keyStoreEnc;

function sendSign(bankAddress,privateKey1,myData,gasLimit){
    web3.eth.getTransactionCount(bankAddress, (err, txCount) => {
    // Build the transaction
      const txObject = {
        nonce:    web3.utils.toHex(txCount),
        to:       contractAddress,
        value:    web3.utils.toHex(web3.utils.toWei('0', 'ether')),
        gasLimit: web3.utils.toHex(gasLimit),
        gasPrice: web3.utils.toHex(web3.utils.toWei('6', 'gwei')),
        data: myData  
      }
        // Sign the transaction
        //const tx = new Tx(txObject);
        const tx = new ethereumjs.Tx(txObject);
        tx.sign(privateKey1);

        const serializedTx = tx.serialize();
        const raw = '0x' + serializedTx.toString('hex');

        // Broadcast the transaction
        const transaction = web3.eth.sendSignedTransaction(raw, (err, tx) => {
            console.log(tx)
        });
    });
}


function onClickLogin() {
    var username = document.getElementById("username").value;
    var password = document.getElementById("password").value;
    var bankName = document.getElementById("bankName").value;
    /*if (contractInstance.checkCustomer.call(username_c, password_c) == false) {
        alert("Sorry! Invalid username or password. Sign up first if you haven't!");
        return false;
    }*/
    //  alert("Welcome "+username_c+" !");
    if (username == "" || password == "") {
        alert("Invalid bank name or password");
        return false;
    } else {
        connection(username, password, bankName);
    }
    /*
    localStorage.username_c = username_c;
    localStorage.password_c = password_c;
    alert("Welcome " + localStorage.username_c + " !");
    window.location = './customerHomePage.html';
    return false;
    */
}

async function connection(username, password, bankName) {
    let objKeyStore = JSON.parse(keyStoreEnc);
    let decryptData=web3.eth.accounts.decrypt(objKeyStore, password)
    let privateKey=decryptData.privateKey.substring(2);

    localStorage.setItem("username",username);
    localStorage.setItem("bankName",bankName);
    localStorage.setItem("accountPrivKey",privateKey);
    let hexKey="0x"+privateKey;
    let acc= web3.eth.accounts.privateKeyToAccount(hexKey);
    let current_account= acc.address;
    localStorage.setItem("accountAddress",current_account);

    /*if (contractInstance.checkBank.call(bank_name_l, current_account, {
            from: ,
            gas: 4700000
        ) == bank_name_l) */ 
    //let checkCustomer = await contractInstance.checkAccountCust.call(username, current_account, password, bankName);
    let checkCustomer = await contractInstance.methods.checkAccountCust(username, current_account, password, bankName).call(); 
    if (checkCustomer == true) {
        alert("Welcome " + username);
        window.location = './resources/customerHomePage.html';
        return false;
    } else { 
        alert("Invalid username or password. \nAccount hasn't been registered yet . \nSign up before proceeding further.");
        return false;
    }
}

function readFile(input) {
    let file = input.files[0];
    let reader = new FileReader();
    reader.readAsText(file);
    reader.onload = function() {
        console.log(reader.result);
        keyStoreEnc=reader.result
    };
    reader.onerror = function() {
        console.log(reader.error);
    };
}


function onClickSignUp() {
    var username_c = document.getElementById("usernamesignup").value;
    var password_c = document.getElementById("passwordsignup").value;
    var c_password_c = document.getElementById("passwordsignup_confirm").value;
    var bankNameSignup = document.getElementById("bankNameSignup").value;
    if (password_c != c_password_c) {
        alert("Confirm your password correctly!");
        return false;
    }
    if (username_c == "" || password_c == "") {
        alert("Invalid username or password");
        return false;
    }
    if (bankNameSignup == "") {
        alert("Invalid bank name");
        return false;
    }
    if (confirm("I accept that the details provided are correct.") == true) {
        generate(username_c, password_c, bankNameSignup);
        //window.location.href = './index.html';
        return false;
    }
}

async function generate(username_c, password_c, bankNameSignup) {
    let dataAcc= web3.eth.accounts.create();
    
    /*let addAccountCust = await contractInstance.methods.addAccountCust(username_c, password_c, dataAcc.address, bankNameSignup).send({
        //from: web3.eth.accounts[0],
        from: dataAcc.Address,
        gas: 4700000
    });
    */

    web3.eth.defaultAccount = dataAcc.address;
    let privateKey1 = new ethereumjs.Buffer.Buffer(dataAcc.privateKey, 'hex');
    let addAccountCust = await contractInstance.methods.addAccountCust(username_c, password_c, dataAcc.address, bankNameSignup).encodeABI();
    sendSign(dataAcc.address,privateKey1,addAccountCust,150000);

    if (addAccountCust == 0) {
        alert("Account successfully registered. \nGo to the login area to proceed.");
        return false;
    } else {
        alert("Account hasn't been successfully registered. \nPlease try again.");
        return false;
    }
    encryptPrivateKey(dataAcc.privateKey,dataAcc.address,password_c);
}

function encryptPrivateKey(privateKey,address,pass) {
    let encryptData=web3.eth.accounts.encrypt(privateKey,pass)
    console.log("encryptData",encryptData)
    let ts = Math.round((new Date()).getTime() / 1000);
    let fileName = 'keystore_'+address+'_'+convert(ts)+'.json';
    console.log(fileName)

    let fileToSave = new Blob([JSON.stringify(encryptData)], {
        type: 'text/json',
        name: fileName
    });

    saveAs(fileToSave, fileName);
}

function convert(inputTs){
    var unixtimestamp = inputTs;
    var months_arr = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var date = new Date(unixtimestamp*1000);
    var year = date.getFullYear();
    var month = months_arr[date.getMonth()];
    var day = date.getDate();
    var hours = date.getHours();
    // Minutes
    var minutes = "0" + date.getMinutes();
    // Seconds
    var seconds = "0" + date.getSeconds();
    // Display date time in dd-MM-yyyy (h;m;s) format
    return  day + '-' + month + '-' + year +' ('+ hours + ';' + minutes.substr(-2) + ';' + seconds.substr(-2) + ')';
}


function onClickForgot() {
    var usernameForgot = document.getElementById("usernameforgot").value;
    var passwordForgot = document.getElementById("passwordforgot").value;
    var passwordForgot_confirm = document.getElementById("passwordforgot_confirm").value;

    if (passwordForgot != passwordForgot_confirm) {
        alert("Confirm your password correctly!");
        return false;
    }
    if (usernameForgot== "" || passwordForgot == "") {
        alert("Invalid username or password");
        return false;
    }
    if (confirm("I accept that the details provided are correct.") == true) {
        generateForgot(usernameForgot, passwordForgot);
        //window.location.href = './index.html';
        return false;
    }

}

async function generateForgot(usernameForgot, passwordForgot) {
    let dataAcc= web3.eth.accounts.create();
    /*let removeAccountCust = await contractInstance.methods.removeAccountCust(usernameForgot).send({
        //from: web3.eth.accounts[0],
        from: dataAcc.Address,
        gas: 4700000
    }); */

    //if (removeAccountCust == 0) {
        /*let forgotAccountCust = await contractInstance.methods.forgotAccountCust(usernameForgot, passwordForgot, dataAcc.address).send({
            //from: web3.eth.accounts[0],
            from: dataAcc.Address,
            gas: 4700000
        }); */

        web3.eth.defaultAccount = dataAcc.address;
        let privateKey1 = new ethereumjs.Buffer.Buffer(dataAcc.privateKey, 'hex');
        let forgotAccountCust = await contractInstance.methods.forgotAccountCust(usernameForgot, passwordForgot, dataAcc.address).encodeABI();
        sendSign(dataAcc.address,privateKey1,forgotAccountCust,50000);

        if (forgotAccountCust == 0) {
            alert(usernameForgot + " account successfully updated. \nGo to the login area to proceed.");
            return false;
        } else {
            alert(usernameForgot + " account hasn't been successfully updated. \nPlease try again.");
            return false;
        }
        encryptPrivateKey(dataAcc.privateKey,dataAcc.address,passwordForgot);
    //} else {
        //alert(usernameForgot + " hasn't been registered yet");
    //}
}