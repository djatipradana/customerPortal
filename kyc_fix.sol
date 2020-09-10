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
    
    modifier accExist (string memory email) { 
        require(!isAcc[email], "Account Already Exist");
        _;
    }


    modifier accNotExist (string memory email){ 
        require(isAcc[email], "Account Not Exist");
        _;
    }
    
    modifier custExist (string memory email) { 
        require(!isCust[email], "Customer Already Exist");
        _;
    }


    modifier custNotExist (string memory email){ 
        require(isCust[email], "Customer Not Exist");
        _;
    }

    modifier isPartOfOrg(address bankAddress, string memory bankName, string memory regNumber) {
        require(org[bankAddress].ethAddress != bankAddress && !(stringsEqual(checkBankName[bankName].bankName, bankName)) && !(stringsEqual(checkRegNumber[regNumber], regNumber)), "Bank can't register");
        _;
    }

    modifier isPartOfAcc(string memory email) {
        require(!(stringsEqual(acc[email].email, email)), "Customer account can't register");
        _;
    }
    
    /*
    modifier isPartOfCust(string memory email) {
        require(!(stringsEqual(cust[email].email, email)), "Customer can't register");
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

    
    
    function addAccountCust(string memory email, string memory password, address ethAddress, string memory bankName) public accExist(email) isPartOfAcc(email) returns(uint8){
        acc[email].email = email;
        acc[email].password = password;
        acc[email].ethAddress = ethAddress;
        acc[email].bankName = bankName;
        isAcc[email] = true;
        return 3;
    }
    
    function forgotAccountCust(string memory email, string memory password, address ethAddress) public accNotExist(email) returns(uint8){
        if (isAcc[email] == true) {
            //removeAccountCust(email);
            acc[email].email = email;
            acc[email].password = password;
            acc[email].ethAddress = ethAddress;
            isAcc[email] = true;
            return 3;
        }
        return 1;
    }
    
    function removeAccountCust(string memory email) public accNotExist(email) returns (uint8){
        isAcc[email] = false;
        if (!isAcc[email]) {
            delete acc[email];
            delete isAcc[email];
            return 3;
        }
        return 1;
    }
    
    function checkAccountCust(string memory email, address ethAddress, string memory password, string memory bankName) public view accNotExist(email) returns(uint8) {
        if (stringsEqual(acc[email].email, email) && acc[email].ethAddress == ethAddress && stringsEqual(acc[email].password, password) && stringsEqual(acc[email].bankName, bankName)) {
            return 3;
        }
        return 1;
    }

    
    
    function addCustomer(address custAddress,string memory email, string memory data, string memory bankName) public returns(uint8) {
        cust[email].custAddress = custAddress; 
        cust[email].email = email;
        cust[email].data = data;
        cust[email].bankName = bankName;
        cust[email].kycStatus = "Not Verified";
        if (!isCust[email]) {
            req[bankName].userReq.push(email);
            cust[email].rating = 100;
            cust[email].upvotes = 0;
            isCust[email] = true;
            updateRatingBank(bankName, true);
        }
        return 3;
    }
    
    function fillTable(string memory bankName) public view returns(string[] memory) {
        return req[bankName].userReq;
    }
    
    
    
    function removeCust(string memory email, string memory bankName, string[] memory filling) public custNotExist(email) returns (uint8){
        isCust[email] = false;
        if (!isCust[email]) {
            updateRatingBank(cust[email].bankName, false);
            delete acc[email];
            delete cust[email];
            delete isCust[email];
            delete isAcc[email];
            req[bankName].userReq = filling;
            return 3;
        }
        return 1;
    }
    
    
    function viewCustomer(string memory email) public custNotExist(email) view returns(address, string memory, string memory, string memory, uint256, string memory) {
        return (
            cust[email].custAddress,
            cust[email].email,
            cust[email].data,
            cust[email].bankName,
            cust[email].rating,
            cust[email].kycStatus
        );
    }
    
    
    function getCustForVerify(string memory email, string memory bankName) public custNotExist(email) view returns(uint8) {
        if (stringsEqual(cust[email].email, email) && stringsEqual(cust[email].bankName, bankName)) {
            if (stringsEqual(cust[email].kycStatus, "Not Verified") || stringsEqual(cust[email].kycStatus, "Rejected")) {
                return 3;
            }
            else if (stringsEqual(cust[email].kycStatus, "Verified")) {
                return 2;
            }
        }
        return 1;
    }
    
    
    function getCustForDelete(string memory email, string memory bankName) public custNotExist(email) view returns(uint8) {
        if (stringsEqual(cust[email].email, email) && stringsEqual(cust[email].bankName, bankName)) {
            return 3;
        }
        return 1;
    }
    
    
    function setCustVerified(string memory email) public custNotExist(email) returns(uint8){
        cust[email].kycStatus = "Verified";
        return 3;
    }
    
    function setCustRejected(string memory email) public custNotExist(email) returns(uint8){
        cust[email].kycStatus = "Rejected";
        return 3;
    }
    
    function getCustStatus(string memory email) public view custNotExist(email) returns(string memory){
        return cust[email].kycStatus;
    }
    
    function checkCustName(string memory email) public view custNotExist(email) returns(string memory) {
        return cust[email].email;   
    }
    
    function updateRatingCustomer(string memory email, bool ifIncrease) public custNotExist(email) returns(uint8){
        if (ifIncrease) {
            cust[email].upvotes++;
            cust[email].rating = (cust[email].rating + 100);
            if (cust[email].rating > 500) {
                cust[email].rating = 500;
            }
            return 3;
        } else {
            cust[email].upvotes--;
            cust[email].rating = (cust[email].rating - 100);
            if (cust[email].rating < 0) {
                cust[email].rating = 0;
            }
            if (cust[email].upvotes < 0) {
                cust[email].upvotes = 0;
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