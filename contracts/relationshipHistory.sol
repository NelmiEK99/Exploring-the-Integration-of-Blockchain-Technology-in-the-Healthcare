// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RelationshipHistory {
    enum ConsentStatus { Granted, Requested, Authorized, Rejected, Revoked, Expired, Invalid }

    struct Relationship {
        address doctor;
        address patient;
        ConsentStatus status;
        uint256 timestamp;
        ConsentStatus[] consentHistory; // Array to store consent history
    }

    mapping(bytes32 => Relationship) public relationships;

    event RelationshipCreated(address indexed doctor, address indexed patient, ConsentStatus status, uint256 timestamp);
    event RelationshipStatusUpdated(address indexed doctor, address indexed patient, ConsentStatus status);

    // Internal function to check and update the expiration status of a relationship
    function _checkAndUpdateExpiration(address _doctor, address _patient) internal {
        bytes32 key = keccak256(abi.encodePacked(_doctor, _patient));
        if (relationships[key].doctor != address(0) && block.timestamp > relationships[key].timestamp + 24 hours) {
            relationships[key].status = ConsentStatus.Expired;
            relationships[key].timestamp = block.timestamp;
            emit RelationshipStatusUpdated(_doctor, _patient, ConsentStatus.Expired);
        }
    }

    // Function to create a new relationship
    function createRelationship(address _doctor, address _patient) public {
        _checkAndUpdateExpiration(_doctor, _patient);
        
        bytes32 key = keccak256(abi.encodePacked(_doctor, _patient));
        relationships[key] = Relationship(_doctor, _patient, ConsentStatus.Requested, block.timestamp,new ConsentStatus[](0));
        emit RelationshipCreated(_doctor, _patient, ConsentStatus.Requested, block.timestamp);
    }

    // Function to update the status of an existing relationship
    function updateStatus(address _doctor, address _patient, ConsentStatus _status) public {
        _checkAndUpdateExpiration(_doctor, _patient);

        bytes32 key = keccak256(abi.encodePacked(_doctor, _patient));
        require(relationships[key].doctor != address(0), "Relationship does not exist");

          // Update consent history before updating status
        relationships[key].consentHistory.push(relationships[key].status);

        relationships[key].status = _status;
        emit RelationshipStatusUpdated(_doctor, _patient, _status);
    }

    // Function to get the status and timestamp of a relationship
    function getRelationship(address _doctor, address _patient) public view returns (ConsentStatus, uint256) {
        bytes32 key = keccak256(abi.encodePacked(_doctor, _patient));
        require(relationships[key].doctor != address(0), "Relationship does not exist");

        return (relationships[key].status, relationships[key].timestamp);
    }

     // Function to get consent history
    function getConsentHistory(address _doctor, address _patient) public view returns (ConsentStatus[] memory) {
        bytes32 key = keccak256(abi.encodePacked(_doctor, _patient));
        require(relationships[key].doctor != address(0), "Relationship does not exist");

        return relationships[key].consentHistory;
    }
}
