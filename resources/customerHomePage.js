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

//  account to make all transactions
var current_privkey;
var current_address;
var current_username;
var current_bankName;
var current_usernameBank;

var starsTotal = 5;

var element = [
    "name",
    "nik",
    "occupation",
    "income",
    "dob",
    "gender",
    "residence",
    "country",
    "phone1",
    "phone2"
];


window.onload = function() { 
    current_privkey = localStorage.getItem("accountPrivKey");
    current_address = localStorage.getItem("accountAddress");
    current_username = localStorage.getItem("username");
    current_bankName = localStorage.getItem("bankName");
    current_usernameBank = current_username + "!@#" + current_bankName;

    fillForm();
}


//  function to fill customer data in form

async function fillForm() {
    try {
        let viewCust = await contractInstance.methods.viewCustomer(current_usernameBank).call();
        let viewBankRating = await contractInstance.methods.getBankRating(viewCust[3]).call();
        
        document.getElementById("kyc_status").innerHTML = viewCust[5];

        const toStar = parseFloat(viewCust[4])/100;
        // Get percentage
        const starPercentage = (toStar/starsTotal) * 100;
        // Round to nearest 2
        const starPercentageRounded = `${Math.round(starPercentage/2) * 2}%`;
        // Set width of stars-inner to percentage
        document.querySelector(".stars-inner-cust").style.width = starPercentageRounded;
        // Add number rating
        document.querySelector(".customer_rating").innerHTML = toStar;

        document.getElementById("customer_address").innerHTML = viewCust[0];
        document.getElementById("email").innerHTML = viewCust[1];
        document.getElementById("username").innerHTML = viewCust[6];
        document.getElementById("bank_name").innerHTML = viewCust[3];

        const toStarBank = parseFloat(viewBankRating)/100;
        console.log(viewBankRating)
        // Get percentage
        const starPercentageBank = (toStarBank/starsTotal) * 100;
        // Round to nearest 2
        const starPercentageRoundedBank = `${Math.round(starPercentageBank/2) * 2}%`;
        // Set width of stars-inner to percentage
        document.querySelector(".stars-inner").style.width = starPercentageRoundedBank;
        // Add number rating
        document.querySelector(".bank_rating").innerHTML = toStarBank;
        
        var dataProfile = viewCust[2];
        var fill = "";
        var index = 0;
        var check = Math.min(dataProfile.length);
        for(var i=0; i<check; i++) {
            if (dataProfile.charAt(i) == '!' && dataProfile.charAt(i+1) == '@' && dataProfile.charAt(i+2) == '#') {
                for (var j=i+3; j<check; j++) {
                    fill = fill + dataProfile.charAt(j);
                    if (dataProfile.charAt(j) == '!') {
                        var editFill = fill.slice(0,-1);
                        document.getElementById(element[index++]).innerHTML = editFill;
                        fill = "";
                        editFill = "";
                        break;
                    }
                }
            }
        }
    } catch (err) {
        console.log("Customer data doesn't exist", err.name + ": " + err.message);
    }
    
}


function logout(){
    //window.localStorage.clear();
    window.localStorage.removeItem("accountPrivKey");
    window.localStorage.removeItem("accountAddress");
    window.localStorage.removeItem("username");
    window.localStorage.removeItem("bankName");
    window.location.assign("../index.html");
}
