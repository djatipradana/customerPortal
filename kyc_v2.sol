pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;


contract Kyc {
    
    address contractOwner;
    
    constructor() public {
        contractOwner = msg.sender;
    }
    
    struct Customer {
        address custAddress;
        string kycStatus;
        string username;
        string email;
        string data;
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
        string email;
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
    mapping (string => string) checkEmail;
    
    
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
    
    modifier accExist (string memory username, string memory email) { 
        require(!isAcc[username] && !(stringsEqual(checkEmail[email], email)), "Account Already Exist");
        _;
    }


    modifier accNotExist (string memory username){ 
        require(isAcc[username], "Account Not Exist");
        _;
    }
    
    modifier custExist (string memory username) { 
        require(!isCust[username], "Customer Already Exist");
        _;
    }


    modifier custNotExist (string memory username){ 
        require(isCust[username], "Customer Not Exist");
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
    modifier isPartOfCust(string memory username) {
        require(!(stringsEqual(cust[username].username, username)), "Customer can't register");
        _;
    }
    */
    
    function getOwner() public view returns(address) {
        return contractOwner;
    }
    

    
    function addBank(string memory bankName, string memory password, address bankAddress, string memory regNumber) public userExist(bankAddress) isPartOfOrg(bankAddress, bankName, regNumber) returns(uint8){
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
        return 3;
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
            return 3;
        }
        return 1;
    }
    
    function checkBank(string memory bankName, address bankAddress, string memory password) public view userNotExist(bankAddress) returns(uint8) {
        if (stringsEqual(org[bankAddress].name, bankName) && org[bankAddress].ethAddress == bankAddress && stringsEqual(org[bankAddress].password, password)) {
            return 3;
        }
        return 1;
    }
    
    
    function getBankKYC(string memory bankName) public view  returns(uint256) {
        return checkBankName[bankName].kycCount; 
    }
    
    function getBankRating(string memory bankName) public view returns(uint256) {
        return checkBankName[bankName].bankRating; 
    }

    
    
    function addAccountCust(string memory username, string memory uname, string memory email, string memory password, address ethAddress, string memory bankName) public accExist(username, email) isPartOfAcc(username) returns(uint8){
        acc[username].username = uname;
        acc[username].email = email;
        acc[username].password = password;
        acc[username].ethAddress = ethAddress;
        acc[username].bankName = bankName;
        isAcc[username] = true;
        checkEmail[email] = email;
        return 3;
    }
    
    function forgotAccountCust(string memory username, string memory uname, string memory password, address ethAddress) public accNotExist(username) returns(uint8){
        if (isAcc[username] == true) {
            //removeAccountCust(username);
            acc[username].username = uname;
            acc[username].password = password;
            acc[username].ethAddress = ethAddress;
            isAcc[username] = true;
            return 3;
        }
        return 1;
    }
    
    /*
    function removeAccountCust(string memory username) public accNotExist(username) returns (uint8){
        isAcc[username] = false;
        if (!isAcc[username]) {
            delete acc[username];
            delete isAcc[username];
            return 3;
        }
        return 1;
    }
    */
    
    function checkAccountCust(string memory username, string memory uname, address ethAddress, string memory password, string memory bankName) public view accNotExist(username) returns(uint8) {
        if (stringsEqual(acc[username].username, uname) && acc[username].ethAddress == ethAddress && stringsEqual(acc[username].password, password) && stringsEqual(acc[username].bankName, bankName)) {
            return 3;
        }
        return 1;
    }

    
    
    function addCustomer(address custAddress, string memory username, string memory uname, string memory data, string memory bankName) public returns(uint8) {
        cust[username].custAddress = custAddress;
        cust[username].username = uname; 
        cust[username].email = acc[username].email;
        cust[username].data = data;
        cust[username].bankName = bankName;
        cust[username].kycStatus = "Not Verified";
        if (!isCust[username]) {
            req[bankName].userReq.push(uname);
            cust[username].rating = 100;
            cust[username].upvotes = 0;
            isCust[username] = true;
            updateRatingBank(bankName, true);
        }
        return 3;
    }
    
    function fillTable(string memory bankName) public view returns(string[] memory) {
        return req[bankName].userReq;
    }
    
    
    
    function removeCust(string memory username, string memory bankName, string[] memory filling) public custNotExist(username) returns (uint8){
        isCust[username] = false;
        if (!isCust[username]) {
            updateRatingBank(cust[username].bankName, false);
            delete checkEmail[cust[username].email];
            delete acc[username];
            delete isAcc[username];
            delete cust[username];
            delete isCust[username];
            req[bankName].userReq = filling;
            return 3;
        }
        return 1;
    }
    
    
    function viewCustomer(string memory username) public custNotExist(username) view returns(address, string memory, string memory, string memory, uint256, string memory, string memory) {
        return (
            cust[username].custAddress,
            cust[username].email,
            cust[username].data,
            cust[username].bankName,
            cust[username].rating,
            cust[username].kycStatus,
            cust[username].username
        );
    }
    
    
    function getCustForVerify(string memory username, string memory uname, string memory bankName) public custNotExist(username) view returns(uint8) {
        if (stringsEqual(cust[username].username, uname) && stringsEqual(cust[username].bankName, bankName)) {
            if (stringsEqual(cust[username].kycStatus, "Not Verified") || stringsEqual(cust[username].kycStatus, "Rejected")) {
                return 3;
            }
            else if (stringsEqual(cust[username].kycStatus, "Verified")) {
                return 2;
            }
        }
        return 1;
    }
    
    
    function getCustForDelete(string memory username, string memory uname, string memory bankName) public custNotExist(username) view returns(uint8) {
        if (stringsEqual(cust[username].username, uname) && stringsEqual(cust[username].bankName, bankName)) {
            return 3;
        }
        return 1;
    }
    
    
    function setCustVerified(string memory username) public custNotExist(username) returns(uint8){
        cust[username].kycStatus = "Verified";
        return 3;
    }
    
    function setCustRejected(string memory username) public custNotExist(username) returns(uint8){
        cust[username].kycStatus = "Rejected";
        return 3;
    }
    
    /*
    function getCustStatus(string memory username) public view custNotExist(username) returns(string memory){
        return cust[username].kycStatus;
    }
    
    function checkCustName(string memory username) public view custNotExist(username) returns(string memory) {
        return cust[username].username;   
    }
    */
    
    function updateRatingCustomer(string memory username, bool ifIncrease) public custNotExist(username) returns(uint8){
        if (ifIncrease) {
            cust[username].upvotes++;
            cust[username].rating = (cust[username].rating + 100);
            if (cust[username].rating > 500) {
                cust[username].rating = 500;
            }
            return 3;
        } else {
            cust[username].upvotes--;
            cust[username].rating = (cust[username].rating - 100);
            if (cust[username].rating < 0) {
                cust[username].rating = 0;
            }
            if (cust[username].upvotes < 0) {
                cust[username].upvotes = 0;
            }
            return 1;
        }
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