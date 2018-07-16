pragma solidity ^0.4.18;

/**
 * @title SchedulerInterface
 * @dev The base contract that the higher contracts: BaseScheduler, BlockScheduler and TimestampScheduler all inherit from.
 */
contract SchedulerInterface {
    function schedule(address _toAddress, bytes _callData, uint[8] _uintArgs)
        public payable returns (address);
    function computeEndowment(uint _bounty, uint _fee, uint _callGas, uint _callValue, uint _gasPrice)
        public view returns (uint);
}

contract DelayedGuess {

    SchedulerInterface public scheduler;
    
    uint lockedUntil;
    address public predictFutureHash;
    address public scheduledTransaction;
    address public owner;
    
    
    constructor(
        address _scheduler,
        uint    _numBlocks,
        address _predictFutureHash
    )  public payable {
        scheduler = SchedulerInterface(_scheduler);
        lockedUntil = block.number + _numBlocks;
        predictFutureHash = _predictFutureHash;
        owner = msg.sender;
        
        
        GuessNumberInterface(predictFutureHash).lockInGuess.value(1 ether)(0x0);
        
        scheduledTransaction = scheduler.schedule.value(0.1 ether)( // 0.1 ether is to pay for gas, bounty and fee
            this,                   // send to self
            "",                     // and trigger fallback function
            [
                200000,             // The amount of gas to be sent with the transaction.
                0,                  // The amount of wei to be sent.
                255,                // The size of the execution window.
                lockedUntil,        // The start of the execution window.
                20000000000 wei,    // The gasprice for the transaction (aka 20 gwei)
                20000000000 wei,    // The fee included in the transaction.
                20000000000 wei,         // The bounty that awards the executor of the transaction.
                30000000000 wei     // The required amount of wei the claimer must send as deposit.
            ]
        );
    }

    function () public payable {
        if (msg.value > 0) { //this handles recieving remaining funds sent while scheduling (0.1 ether)
            return;
        } else if (address(this).balance > 0) {
            guessNumber();
        } else {
            revert();
        }
    }

    function guessNumber()
        public returns (bool)
    {
        require(block.number >= lockedUntil);
        
        GuessNumberInterface(predictFutureHash).settle();
        
        
        return true;
    }
    
    function claim() public {
        owner.transfer(address(this).balance);
    }
    
    
}


contract GuessNumberInterface {
    function lockInGuess(bytes32 hash) public payable;
    function settle() public;
}


