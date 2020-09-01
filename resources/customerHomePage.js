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

var starsTotal = 5;

var element = [
    "first_name",
    "middle_name",
    "last_name",
    "nik",
    "occupation",
    "income",
    "dob",
    "gender_m",
    "gender_f",
    "residence",
    "phone1",
    "phone2",
    "email",
    "country"
];


window.onload = function() { 
    current_privkey = localStorage.getItem("accountPrivKey");
    current_address = localStorage.getItem("accountAddress");
    current_username = localStorage.getItem("username");
    current_bankName = localStorage.getItem("bankName");

    fillForm();
}

/*var current_account = web3.eth.accounts[0];
var user_name = localStorage.username_c; */

//  function to fill customer data in form

async function fillForm() {
    let viewCust = await contractInstance.methods.viewCustomer(current_username).call();
    let viewBankRating = await contractInstance.methods.getBankRating(viewCust[3]).call();
    /*
    let viewCust2 = await contractInstance.methods.viewCustomer2(current_username).call();
    let viewCust3 = await contractInstance.methods.viewCustomer3(current_username).call();
    */
    document.getElementById("kyc_status").innerHTML = viewCust[5];

    const toStar = parseFloat(viewCust[4])/100;
    // Get percentage
    const starPercentage = (toStar/starsTotal) * 100;
    // Round to nearest 2
    const starPercentageRounded = `${Math.round(starPercentage/2) * 2}%`;
    // Set width of stars-inner to percentage
    document.querySelector(".stars-inner").style.width = starPercentageRounded;
    // Add number rating
    document.querySelector(".customer_rating").innerHTML = toStar;

    //document.getElementById("customer_rating").innerHTML = viewCust[4];
    
    document.getElementById("customer_address").innerHTML = viewCust[0];
    document.getElementById("username").innerHTML = viewCust[1];
    document.getElementById("bank_name").innerHTML = viewCust[3];

    const toStarBank = parseFloat(viewBankRating[0])/100;
    // Get percentage
    const starPercentageBank = (toStarBank/starsTotal) * 100;
    // Round to nearest 2
    const starPercentageRoundedBank = `${Math.round(starPercentageBank/2) * 2}%`;
    // Set width of stars-inner to percentage
    document.querySelector(".stars-inner").style.width = starPercentageRoundedBank;
    // Add number rating
    document.querySelector(".bank_rating").innerHTML = toStarBank;

    //document.getElementById("bank_rating").innerHTML = viewBankRating[0];
    
    var dataProfile = viewCust[2];
    var fill = "";
    var check = Math.min(dataProfile.length);
    for(var i=0; i<check; i++) {
        if (dataProfile.charAt(i) == '!' && dataProfile.charAt(i+1) == '@' && dataProfile.charAt(i+2) == '#') {
            for (var j=i+3; j<check; j++) {
                fill = fill + dataProfile.charAt(j);
                if (dataProfile.charAt(j) == '!') {
                    document.getElementById(element[i]).innerHTML = fill;
                    fill = ""
                    break;
                }
            }
        }
    }
    /*
    document.getElementById("first_name").innerHTML = viewCust1[1];
    document.getElementById("middle_name").innerHTML = viewCust1[2];
    document.getElementById("middle_name").innerHTML = viewCust1[3];
    document.getElementById("nik").innerHTML = viewCust1[4];
    document.getElementById("occupation").innerHTML = viewCust2[0];
    document.getElementById("income").innerHTML = viewCust2[1];
    document.getElementById("dob").innerHTML = viewCust2[2];
    document.getElementById("gender").innerHTML = viewCust2[3];
    document.getElementById("residence").innerHTML = viewCust2[4];
    document.getElementById("country").innerHTML = viewCust3[0];
    document.getElementById("phone1").innerHTML = viewCust3[1];
    document.getElementById("phone2").innerHTML = viewCust3[2];
    document.getElementById("email").innerHTML = viewCust3[3];
    document.getElementById("bank_rating").innerHTML = ;
    */
}


function logout(){
    localStorage.removeItem("accountPrivKey");
    localStorage.removeItem("accountAddress");
    localStorage.removeItem("username");
    localStorage.removeItem("bankName");
    document.location.assign("../index.html");
}
