// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./RelationshipHistory.sol";
import "./AuthorizationContract.sol";

contract Registration {
    RelationshipHistory public relationshipHistoryContract;
    AuthorizationContract public authorizationContract;
  

    mapping(address => bool) public registeredDoctors;

    event DoctorRegistered(address indexed doctor);
    event RelationshipCreated(address indexed doctor, address indexed patient);

    constructor(address _authorizationContractAddress, address _relationshipHistoryContractAddress) {
      
        authorizationContract = AuthorizationContract(_authorizationContractAddress);
        relationshipHistoryContract = RelationshipHistory(_relationshipHistoryContractAddress);
    }

    // Function to register a doctor and create a relationship with the patient
    function registerDoctor(address _doctor, address _patient) public returns (bool) {

        require(!registeredDoctors[_doctor], "Doctor is already registered");    

        // Doctor is not registered, proceed with registration
        registeredDoctors[_doctor] = true;
        emit DoctorRegistered(_doctor);

        // Create a relationship with the default status of "Requested"
        relationshipHistoryContract.createRelationship(_doctor, _patient);
        emit RelationshipCreated(_doctor, _patient);

        //getAuthorized results from authorization contract
        bool isAuthorized =  authorizationContract.checkPermission(_doctor, _patient, AuthorizationContract.PermissionType.READ);

        // Use the result in an if-else statement
        if (isAuthorized) {
            // Permission granted-consent updated as authorized
            return true;
        } else {
            // Permission denied-consent updated as invalid
            return false;
        }
      
    }

    // Function to check if a doctor is registered
    function isDoctorRegistered(address _doctor) public view returns (bool) {
        return registeredDoctors[_doctor];
    }
}
