pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;
//pragma solidity >=0.6.3;


// ----------------------------------------------------------------------
// Know Your Customer
// ----------------------------------------------------------------------
contract Kyc {
    
    address contractOwner;
    
    constructor() public {
        contractOwner = msg.sender;
    }
    
    struct Customer {
        address custAddress;
        string kycStatus;
        string uname;
        string data;
        /*string firstName;
        string middleName;
        string lastName;
        string nik;
        string occupation;
        uint256 income;
        string dob;
        string gender;
        string residence;
        string country;
        string phone1;
        string phone2;
        string email;   */
        string bankName;
        uint256 rating;
        uint256 upvotes;
    }

    
    struct Organisation {
        string name;
        string password;
        address ethAddress;
        uint256 rating;
        uint256 kycCount;
        string regNumber;
    }

    struct Request {
        //string bankReq;
        string[] userReq;
    }
    
    struct AccountCust {
        string username;
        string password;
        address ethAddress;
        string bankName;
    }

    struct Bank {
        string bankName;
        uint256 bankRating;
        uint256 kycCount;
        address bankAddress;
    }

    mapping (string => Customer) cust;
    mapping (address => Organisation) org;
    mapping (string => Request) req;
    mapping (string => AccountCust) acc;
    mapping (address => bool) isUser;
    mapping (string => bool) isAcc;
    mapping (string => bool) isCust;
    mapping (string => Bank) checkBankName;
    mapping (string => string) checkRegNumber;
    
    //  list of all customer
    //Customer[] allCustomers;

    //  list of all Banks/Organisations
    //Organisation[] allOrgs;


    //Request[] allRequests;
    
    modifier onlyOwner(){ 
        require(contractOwner == msg.sender, "Error!! Only-owner");
        _;
    }

    modifier userExist (address bankAddress) { 
        require(!isUser[bankAddress], "Bank Already Exist");
        _;
    }


    modifier userNotExist (address bankAddress){ 
        require(isUser[bankAddress], "Bank Not Exist");
        _;
    }
    
    modifier accExist (string memory username) { 
        require(!isAcc[username], "Account Already Exist");
        _;
    }


    modifier accNotExist (string memory username){ 
        require(isAcc[username], "Account Not Exist");
        _;
    }
    
    modifier custExist (string memory uname) { 
        require(!isCust[uname], "Customer Already Exist");
        _;
    }


    modifier custNotExist (string memory uname){ 
        require(isCust[uname], "Customer Not Exist");
        _;
    }

    modifier isPartOfOrg(address bankAddress, string memory bankName, string memory regNumber) {
        require(org[bankAddress].ethAddress != bankAddress && !(stringsEqual(checkBankName[bankName].bankName, bankName)) && !(stringsEqual(checkRegNumber[regNumber], regNumber)), "Bank can't register");
        _;
    }

    modifier isPartOfAcc(string memory username) {
        require(!(stringsEqual(acc[username].username, username)), "Customer account can't register");
        _;
    }
    
    /*
    modifier isPartOfCust(string memory uname) {
        require(!(stringsEqual(cust[uname].uname, uname)), "Customer can't register");
        _;
    }
    */
    
    function getOwner() public view returns(address) {
        return contractOwner;
    }
    

    /*function isPartOfOrg(address bankAddress, string memory bankName, string memory regNumber) public view returns(uint) {
        if (org[bankAddress].ethAddress == bankAddress || stringsEqual(checkBankName[bankName].bankName, bankName) ||  stringsEqual(checkRegNumber[regNumber], regNumber)) {
            return 1;
        }
        return 0;
    }*/
    
    /*function isPartOfAcc(string memory username) public view returns(uint) {
        if (stringsEqual(acc[username].username, username)) {
            return 1;
        }
        return 0;
    }*/
    
    /*function isPartOfCust(string memory uname, string memory nik) public view returns(uint) {
        if (stringsEqual(cust[uname].uname, uname) || stringsEqual(checkNIK[nik], nik)) {
            return 1;
        }
        return 0;
    }*/
    
    
    function addBank(string memory bankName, string memory password, address bankAddress, string memory regNumber) public userExist(bankAddress) isPartOfOrg(bankAddress, bankName, regNumber) returns(uint8){
        //if (isPartOfOrg(bankAddress, bankName, regNumber) == 0) {
            //removeBank(bankAddress, bankName, regNumber);
            org[bankAddress].name = bankName;
            org[bankAddress].ethAddress = bankAddress;
            org[bankAddress].password = password;
            org[bankAddress].regNumber = regNumber;
            org[bankAddress].rating = 100;
            org[bankAddress].kycCount = 0;
            checkBankName[bankName].bankName = bankName;
            checkBankName[bankName].bankRating = 100;
            checkBankName[bankName].kycCount = 0;
            checkBankName[bankName].bankAddress = bankAddress;
            checkRegNumber[regNumber] = regNumber;
            isUser[bankAddress] = true;
            return 0;
        //}
        //return 1;
    }
    
    function viewBank(address bankAddress) public view userNotExist(bankAddress) returns(address, string memory, string memory, uint256, uint256) {
        return (
            org[bankAddress].ethAddress,
            org[bankAddress].name,
            org[bankAddress].regNumber,
            org[bankAddress].kycCount,
            //checkBankName[org[bankAddress].name].kycCount,
            org[bankAddress].rating
            //checkBankName[org[bankAddress].name].bankRating
        );
    }
    
    function removeBank(address bankAddress, string memory bankName, string memory regNumber) public userNotExist(bankAddress) returns(uint8){
        isUser[bankAddress] = false;
        if (!isUser[bankAddress]) {
            delete org[bankAddress];
            delete checkBankName[bankName];
            delete checkRegNumber[regNumber];
            delete isUser[bankAddress];
            return 0;
        }
        return 1;
    }
    
    function checkBank(string memory bankName, address bankAddress, string memory password) public view userNotExist(bankAddress) returns(bool) {
        if (stringsEqual(org[bankAddress].name, bankName) && org[bankAddress].ethAddress == bankAddress && stringsEqual(org[bankAddress].password, password)) {
            return true;
        }
        return false;
    }
    
    /*
    function getBankAddress(address bankAddress) public view userNotExist(bankAddress) returns(address) {
        return org[bankAddress].ethAddress; 
    }
    
    function getBankName(address bankAddress) public view userNotExist(bankAddress) returns(string memory) {
        return org[bankAddress].name; 
    }
    
    function getBankReg(address bankAddress) public view userNotExist(bankAddress) returns(string memory) {
        return org[bankAddress].regNumber; 
    }
    */
    
    function getBankKYC(string memory bankName) public view  returns(uint256) {
        return checkBankName[bankName].kycCount; 
    }
    
    function getBankRating(string memory bankName) public view returns(uint256) {
        return checkBankName[bankName].bankRating; 
    }

    
    
    function addAccountCust(string memory username, string memory password, address ethAddress, string memory bankName) public accExist(username) isPartOfAcc(username) returns(uint8){
        //if (isPartOfAcc(username) == 0) {
            //removeAccountCust(username);
            acc[username].username = username;
            acc[username].password = password;
            acc[username].ethAddress = ethAddress;
            acc[username].bankName = bankName;
            isAcc[username] = true;
            return 0;
        //}
        //return 1;
    }
    
    function forgotAccountCust(string memory username, string memory password, address ethAddress) public accNotExist(username) returns(uint8){
        if (isAcc[username] == true) {
            //removeAccountCust(username);
            acc[username].username = username;
            acc[username].password = password;
            acc[username].ethAddress = ethAddress;
            isAcc[username] = true;
            return 0;
        }
        return 1;
    }
    
    function removeAccountCust(string memory username) public accNotExist(username) returns (uint8){
        isAcc[username] = false;
        if (!isAcc[username]) {
            delete acc[username];
            delete isAcc[username];
            return 0;
        }
        return 1;
    }
    
    function checkAccountCust(string memory username, address ethAddress, string memory password, string memory bankName) public view accNotExist(username) returns(bool) {
        if (stringsEqual(acc[username].username, username) && acc[username].ethAddress == ethAddress && stringsEqual(acc[username].password, password) && stringsEqual(acc[username].bankName, bankName)) {
            return true;
        }
        return false;
    }

    
    /*function addCustomer(string memory uname, string memory firstName, string memory middleName, string memory lastName, string memory nik, string memory occupation, uint256 income, string memory dob, string memory gender, string memory residence, string memory country, string memory phone1, string memory phone2, string memory email, string memory bankName) public returns(uint) {
        addCustomer1(uname, firstName, middleName, lastName, nik);
        addCustomer2(uname, occupation, income, dob, gender, residence);
        addCustomer3(uname, country, phone1, phone2, email, bankName);
    }*/
    
    function addCustomer(address custAddress,string memory uname, string memory data, string memory bankName) public returns(uint8) {
        //if (stringsEqual(cust[uname].uname, username)) {
            //if (isPartOfCust(uname) == 0) { 
                cust[uname].custAddress = custAddress; 
                cust[uname].uname = uname;
                cust[uname].data = data;
                cust[uname].bankName = bankName;
                cust[uname].kycStatus = "Not Verified";
                if (!isCust[uname]) {
                    req[bankName].userReq.push(uname);
                    cust[uname].rating = 100;
                    cust[uname].upvotes = 0;
                    isCust[uname] = true;
                }
                updateRatingBank(bankName, true);
                return 0;
            //}
        //} else {
            /*acc[username].username = username;
            acc[username].password = acc[uname].password;
            acc[username].ethAddress = acc[uname].ethAddress;
            acc[username].bankName = bankName;
            cust[username].custAddress = custAddress; 
            cust[username].uname = uname;
            cust[username].data = data;
            cust[username].bankName = bankName;
            cust[username].rating = cust[uname].rating;
            cust[username].upvotes = cust[uname].upvotes;
            cust[username].kycStatus = "Not Verified";
            isCust[username] = true;
            return 2;*/
        //}
        //return 1;
        /*
        for (uint i = 0; i < allRequests.length; ++i) {
            if (stringsEqual(allRequests[i].bankReq, bankName)) {
                return 2;
            }
        }
        
        if (allRequests.length < 1) {
            return 1;
        }
        */
    
        //allRequests.length++;
        //allRequests[allRequests.length-1] = Request(bankName, uname);
        
    }
    
    function fillTable(string memory bankName) public view returns(string[] memory) {
        return req[bankName].userReq;
        
        /*for (uint i = 0; i < allRequests.length; ++i) {
            if (stringsEqual(allRequests[i].bankReq, bankName)) {
                 userBankTable[i] = allRequests[i].userReq;
            }
        }*/
        /*if (userBankTable.length < 1) {
            return "null";
        }*/
        //return (userBankTable[userBankTable.length]);
    }
    
    /*
    function addCustomer2(string memory uname, string memory username, string memory occupation, uint256 income, string memory dob, string memory gender, string memory residence) public custExist(uname) isPartOfCust(uname) returns(uint) {
        if (stringsEqual(cust[uname].uname, username)) {
            //if (isPartOfCust(uname) == 0) {
                cust[uname].kycStatus = "Not Verified";
                cust[uname].occupation = occupation;
                cust[uname].income = income;
                cust[uname].dob = dob;
                cust[uname].gender = gender;
                cust[uname].residence = residence;
                return 0;
            //}
        } else {
            cust[username].kycStatus = "Not Verified";
            cust[username].occupation = occupation;
            cust[username].income = income;
            cust[username].dob = dob;
            cust[username].gender = gender;
            cust[username].residence = residence;
            return 2;
        }
        return 1;
    }

    function addCustomer3(string memory uname, string memory username, string memory country, string memory phone1, string memory phone2, string memory email, string memory bankName) public custExist(uname) isPartOfCust(uname) returns(uint) {
        if (stringsEqual(cust[uname].uname, username)) {
            //if (isPartOfCust(uname) == 0) {
                cust[uname].country = country;
                cust[uname].phone1 = phone1;
                cust[uname].phone2 = phone2;
                cust[uname].email = email;
                cust[uname].bankName = bankName;
                return 0;
            //}
        } else {
            acc[username].bankName = bankName;
            cust[username].country = country;
            cust[username].phone1 = phone1;
            cust[username].phone2 = phone2;
            cust[username].email = email;
            cust[username].bankName = bankName;
            cust[username].rating = cust[uname].rating;
            cust[username].upvotes = cust[uname].upvotes;
            removeAccountCust(uname);
            removeCust(uname);
            return 2;
        }
        return 1;
    }
    */
    
    function removeCust(string memory uname) public custNotExist(uname) returns (uint8){
        isCust[uname] = false;
        if (!isCust[uname]) {
            updateRatingBank(cust[uname].bankName, false);
            delete cust[uname];
            delete isCust[uname];
            return 0;
        }
        return 1;
    }
    
    
    function viewCustomer(string memory uname) public custNotExist(uname) view returns(address, string memory, string memory, string memory, uint256, string memory) {
        return (
            cust[uname].custAddress,
            cust[uname].uname,
            cust[uname].data,
            cust[uname].bankName,
            cust[uname].rating,
            cust[uname].kycStatus
        );
    }
    
    /*
    function viewCustomer2(string memory uname) public custNotExist(uname) view returns(string memory, uint256, string memory, string memory, string memory, string memory) {
        return (
            cust[uname].occupation,
            cust[uname].income,
            cust[uname].dob,
            cust[uname].gender,
            cust[uname].residence,
            cust[uname].kycStatus
        );
    }
    
    function viewCustomer3(string memory uname) public custNotExist(uname) view returns(string memory, string memory, string memory, string memory, string memory, uint256, uint256) {
        return (
            cust[uname].country,
            cust[uname].phone1,
            cust[uname].phone2,
            cust[uname].email,
            cust[uname].bankName,
            cust[uname].rating,
            cust[uname].upvotes
        );
    }
    */
    
    function getCustForVerify(string memory uname, string memory bankName) public custNotExist(uname) view returns(uint8) {
        if (stringsEqual(cust[uname].uname, uname) && stringsEqual(cust[uname].bankName, bankName)) {
            if (stringsEqual(cust[uname].uname, "Not Verified") || stringsEqual(cust[uname].uname, "Rejected")) {
                return 0;
            }
            else if (stringsEqual(cust[uname].uname, "Verified")) {
                return 2;
            }
        }
        return 1;
    }
    
    
    function getCustForDelete(string memory uname, string memory bankName) public custNotExist(uname) view returns(uint8) {
        if (stringsEqual(cust[uname].uname, uname) && stringsEqual(cust[uname].bankName, bankName)) {
            return 0;
        }
        return 1;
    }
    
    
    function setCustVerified(string memory uname) public custNotExist(uname) returns(uint8){
        cust[uname].kycStatus = "Verified";
        return 0;
    }
    
    function setCustRejected(string memory uname) public custNotExist(uname) returns(uint8){
        cust[uname].kycStatus = "Rejected";
        return 0;
    }
    
    function getCustStatus(string memory uname) public view custNotExist(uname) returns(string memory){
        return cust[uname].kycStatus;
    }
    
    function checkCustName(string memory uname) public view custNotExist(uname) returns(string memory) {
        return cust[uname].uname;   
    }
    
    function updateRatingCustomer(string memory uname, bool ifIncrease) public custNotExist(uname) returns(uint8){
        if (ifIncrease) {
            cust[uname].upvotes++;
            cust[uname].rating = (cust[uname].rating + 100);
            if (cust[uname].rating > 500) {
                cust[uname].rating = 500;
            }
            return 0;
        } else {
            cust[uname].upvotes--;
            cust[uname].rating = (cust[uname].rating - 100);
            if (cust[uname].rating < 0) {
                cust[uname].rating = 0;
            }
            if (cust[uname].upvotes < 0) {
                cust[uname].upvotes = 0;
            }
            return 1;
        }
        //return 2;    
    }
    
    function updateRatingBank(string memory bankName, bool ifAdded) public {
        if (ifAdded) {
            checkBankName[bankName].kycCount++;
            org[checkBankName[bankName].bankAddress].kycCount++;
            checkBankName[bankName].bankRating = (checkBankName[bankName].bankRating + 100);
            org[checkBankName[bankName].bankAddress].rating = (org[checkBankName[bankName].bankAddress].rating + 100);
            if (checkBankName[bankName].bankRating > 500) {
                checkBankName[bankName].bankRating = 500;
                org[checkBankName[bankName].bankAddress].rating = 500;
            }
        } else {
            checkBankName[bankName].bankRating = (checkBankName[bankName].bankRating - 100);
            org[checkBankName[bankName].bankAddress].rating = (org[checkBankName[bankName].bankAddress].rating - 100);
            if (checkBankName[bankName].bankRating < 0) {
                checkBankName[bankName].bankRating = 0;
                org[checkBankName[bankName].bankAddress].rating = 0;
            }
        }
        //return 0;
    }
    

    
    //   internal function to compare strings
    function stringsEqual(string memory _a, string memory _b) public pure returns (bool) {
        bytes32 hashA = keccak256(abi.encodePacked(_a));
        bytes32 hashB = keccak256(abi.encodePacked(_b)); 
        if (hashA != hashB) {
            return false;
        }
        return true;
    }
}