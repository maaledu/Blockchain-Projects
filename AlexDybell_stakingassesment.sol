// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract staking {

    // a variable to hold the balance of this contract
    uint256 private balance; 

    // a variable to calculate interest
    uint256 private interestTime; 

    //arrays to collate a ledger of who has owned and staked in the contract
    address[] public stakers; 
    address[] public previousOwners;
    mapping (string => string) nameofStakers; 
    mapping (string => string) nameofOwners; 

    // address for the owner
    address payable owner;
    string public NameofCurrentOwner; 

    // a bool to open and close the contract
    bool public contractOpen = false; 

    // ensures that only the owner can use the contract
    modifier onlyOwner {
        require(msg.sender == owner, "Only the Owner of this contract can use this function");
        _; 
    }
    // stops functions from being called before 5 minutes has passed between each one(this is for interest)
    modifier timed {
        require(block.timestamp - interestTime > 5 minutes, "Please wait 5 minutes between each function");
        _; 

    }
    // a modifier to keep functions locked when the contract isn't open
    modifier requireOpen {
        require(contractOpen == true, "You must Open the contract before continuing");
        _;
    }

    // a function to start this contracts functionality and assign an owner
    function startContract (address payable startingOwner, string memory ownerName) public {
        owner = startingOwner; 
        nameofOwners[ownerName] = ownerName;
        NameofCurrentOwner = ownerName;  
        interestTime = block.timestamp; 
        contractOpen = true; 
        emit contractOpened(owner, balance);
    }

    // a function to close the contract (Interest is not gained while the contract is closed)
    function closeContract () public onlyOwner requireOpen timed {
        gainInterest();
        contractOpen = false;
        emit contractClosed(owner, balance); 
    }

    // a function to open the contract (Restarts interest gaining process)
    function openContract () public onlyOwner {
        interestTime = block.timestamp;
        contractOpen = true; 
        emit contractOpened(owner, balance);
    }

    //A function to maintain how interest is gained in the contract. As solidity does not have a way of recurring a function every 5 minutes, instead this function calculates how much time has passed between functions and calculates how much interest is missing from the balance. It divides the time into 5 minute sections and adds interest based on how many sections there are in a for loop. The idea is this function pretends like its been gaining interest every 5 minutes like its supposed to, but is actually just finding the difference in time and catching up.  
    function gainInterest () internal {
        require(balance > 0, "You cannot gain interest on nothing");
        if(block.timestamp - interestTime > 5 minutes) {
            uint256 loopStart;
            for( loopStart = ((block.timestamp - interestTime)/60); loopStart < 5; loopStart - 5) {
                uint256 interestAmount;
                interestAmount = balance/10;
                balance += interestAmount;
            }
            interestTime = block.timestamp + loopStart; 
        } else if (block.timestamp - interestTime == 5 minutes) {
                uint256 interestAmount;
                interestAmount = balance/10;
                balance += interestAmount;
                interestTime = block.timestamp;
                
            } else {
            }
            
    }

    
    // a function to stake, this also records who staked and how much individually as well as how much is in the balance is after this particular stake
    function stake(uint256 stakeamount, address payable staker, string memory stakerName) public payable requireOpen timed {
        require(stakeamount > 0, "You cannot stake nothing");
         if (balance > 0 ){
            gainInterest();
        } 
        stakers.push(staker); 
        nameofStakers[stakerName] = stakerName; 
        uint256 newbalance; 
        newbalance = balance + stakeamount;
        balance = newbalance; 
        emit amountStaked(staker, stakeamount, newbalance);
    }

    // a function to withdraw funds from the contract. This does the interest trick before intereacting with the balance so the balance you withdraw from does have all of its interest. 
    function withdraw(uint256 withdrawAmount) public payable onlyOwner requireOpen timed {
        require(withdrawAmount > 0, "You cannot withdraw nothing");
        require(balance > 0, "There are no funds to withdraw");
        gainInterest();
        require(balance > withdrawAmount, "You do not have the funds to complete this transaction");
        payable(owner).transfer(withdrawAmount);  
        uint256 updatedBalance; 
        updatedBalance = balance - withdrawAmount; 
        balance = updatedBalance;
        emit amountWithdrawn(owner, withdrawAmount, updatedBalance);

    }

    // a function to show balance, this will also calculate the interest. 
    function showBalance() public onlyOwner timed requireOpen returns (uint256) {
        require(balance > 0, "There are no funds in the balance");
        gainInterest();
        return address(this).balance;
    }
    // a function to view a list of stakers
    function getStakers() public view onlyOwner requireOpen returns (address[] memory) {
        return stakers; 
    }
    // a function to view a list of owners
    function viewOwnerHistory() public view onlyOwner requireOpen returns (address[] memory) {
        return previousOwners; 
    }
    // a function to change hands of this contract
    function transferOwnership(address payable newOwner, string memory newOwnerName) public onlyOwner requireOpen {
        emit ownershipTransferred(owner, newOwner, newOwnerName);
        nameofOwners[newOwnerName] = newOwnerName; 
        NameofCurrentOwner = newOwnerName; 
        previousOwners.push(owner); 
        owner = newOwner; 
    }
    // events
    event amountStaked(address indexed staker, uint256 _amountStaked, uint256 balanceAfterStaking);
    event amountWithdrawn(address indexed withdrawnby, uint256 _amountWithdrawn, uint256 balanceAfterWithdrawal); 
    event ownershipTransferred(address indexed adddressTransferedfrom, address indexed addressTransferredto, string indexed Name);
    event contractOpened(address indexed Openedby, uint256 balanceonOpen);
    event contractClosed(address indexed Closedby, uint256 balanceonClose); 
}