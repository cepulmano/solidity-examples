// SPDX-License-Identifier: GPL-3.0 
pragma solidity ^0.8.17 <0.9.0;

/** 
 * @title ConferenceRegistration
 * @dev Implement a simple registration contract for a conference
 */
contract ConferenceRegistration {

    address public organizer; // Address of rganizer of conference

    uint public maxParticipants; // Maximum no of participants
    uint public noRegistrations; // Current number of registrations
    uint public registrationPrice; // Price of registration
    
    enum STATUS { PAID, REFUNDED } // Status of registration
    
    // Store participant details
    struct Participant {
        STATUS status;
        uint payment;
    }
    
    // Mapping of registrant address and details
    mapping(address => Participant) public registrations; 

    /*
     * Check if transaction sender is the organizer
     */
    modifier onlyOrganizer() {
        require(
            msg.sender == organizer,
            "You have no access!"
        );
        _;
    }

    /*
     * Check if maximum number of registrations is already reached
     */
    modifier maxReached() {
        require(
            noRegistrations < maxParticipants,
            "Max number of registrations reached!"
        );
        _;
    }

    /*
     * Check if the person provided enough payment
     */
    modifier enoughPayment() {
        require(
            msg.value >= registrationPrice,
            "Payment is not enough!"
        );
        _;
    }
    
    /*
     * Check if transaction sender is already registered
     */
    modifier registered() {
        require(
            registrations[msg.sender].status == STATUS.PAID 
                && registrations[msg.sender].payment == registrationPrice,
            "You are not yet registered!"
        );
        _;
    }

    /*
     * Constructor function
     * @param _maxParticipants Maximum number of participants for this conference
     * @param _regPrice Registration price set by the organizer
     */
    constructor(uint _maxParticipants, uint _regPrice) {
        /*
         * Assign constructor arguments to state variables
         */
        organizer = msg.sender;
        maxParticipants = _maxParticipants;
        registrationPrice = _regPrice * 1 ether;
    }
    
    /*
     * Register for the conference
     */
    function register() external payable maxReached enoughPayment {
        registrations[msg.sender] = Participant({status: STATUS.PAID, payment: msg.value}); // Create a new participant object then add to registration mapping
        noRegistrations++; // Increment the registrations
    }
    
    /*
     * Refund your payment
     */
    function refund() external registered {
        uint initialBalance = registrations[msg.sender].payment; // Assign current balance to local variable
        
        registrations[msg.sender].status = STATUS.REFUNDED; // Update status from PAID to REFUNDED
        registrations[msg.sender].payment = 0; // Update payment set to 0
        noRegistrations--; // Decrement the registrations
        
        address payable recipient = payable(msg.sender); // Cast the recipeient address to payable
        recipient.transfer(initialBalance); // Transfer the balance to the recipient
    }
    
    /*
     * Get the total collection from registrations
     */
    function getCollection() public view onlyOrganizer returns(uint) {
        return address(this).balance; // Return the balance of the contract
    }

}
