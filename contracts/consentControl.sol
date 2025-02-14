// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RelationshipHistory.sol"; // Import RelationshipHistory contract
import "./DataAccess.sol";
contract ConsentControl {
    RelationshipHistory public relationshipHistoryContract;
    DataAccess public dataAccessContract;

    struct Consent {
        address patient;
        address doctor;
        RelationshipHistory.ConsentStatus status;
    }

    mapping(address => uint256) public patientRequestsCount;
    mapping(address => uint256) public doctorRequestsCount;

    mapping(bytes32 => Consent) public consents;

    event ConsentUpdated(address indexed patient, address indexed doctor, RelationshipHistory.ConsentStatus status);
    event RequestsCountUpdated(address indexed patient, address indexed doctor, uint256 count);

    constructor(address _relationshipHistoryContractAddress, address _dataAccessContractAddress) {
        relationshipHistoryContract = RelationshipHistory(_relationshipHistoryContractAddress);
        dataAccessContract = DataAccess(_dataAccessContractAddress);
    }

    function giveConsent(address _patient, address _doctor, bool consent) public returns (bool) {
        require(_patient != address(0), "Invalid patient address");
        require(_doctor != address(0), "Invalid doctor address");

        if(consent){
             // Update consent in RelationshipHistory contract
             relationshipHistoryContract.updateStatus(_doctor, _patient, RelationshipHistory.ConsentStatus.Granted);
            emit ConsentUpdated(_patient, _doctor, RelationshipHistory.ConsentStatus.Granted);
        }else{
            // Update consent in RelationshipHistory contract
             relationshipHistoryContract.updateStatus(_doctor, _patient, RelationshipHistory.ConsentStatus.Rejected);
                emit ConsentUpdated(_patient, _doctor, RelationshipHistory.ConsentStatus.Rejected);
        }

        // Update requests count
        updateRequestsCount(_patient, _doctor);

        return consent;
    }

    function revokeConsent(address _patient, address _doctor) public returns (bool) {
        require(_patient != address(0), "Invalid patient address");
        require(_doctor != address(0), "Invalid doctor address");

        // Update consent in RelationshipHistory contract
        relationshipHistoryContract.updateStatus(_doctor, _patient, RelationshipHistory.ConsentStatus.Revoked);
        dataAccessContract.revokeData(_doctor, _patient);
        emit ConsentUpdated(_patient, _doctor, RelationshipHistory.ConsentStatus.Revoked);

        // Update requests count
        updateRequestsCount(_patient, _doctor);

        return true;
    }


    function updateRequestsCount(address _patient, address _doctor) internal {
        patientRequestsCount[_patient]++;
        doctorRequestsCount[_doctor]++;

        emit RequestsCountUpdated(_patient, _doctor, patientRequestsCount[_patient]);
        emit RequestsCountUpdated(_doctor, _patient, doctorRequestsCount[_doctor]);
    }
}