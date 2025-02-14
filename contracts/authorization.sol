// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the interface of Relationship History Contract
import "./RelationshipHistory.sol";

contract AuthorizationContract {
    // Address of the Relationship History Contract
    address public relationshipHistoryContract;

    // Enum to define different permission types
    enum PermissionType { NONE, READ, WRITE, UPDATE, DELETE }

    // Mapping to store doctor permissions for each patient
    mapping(address => mapping(address => PermissionType)) public doctorPermissions;

    // Event to log permission changes
    event PermissionSet(address indexed doctor, address indexed patient, PermissionType permission);

    // Constructor to set the Relationship History Contract address
    constructor(address _relationshipHistoryContract) {
        relationshipHistoryContract = _relationshipHistoryContract;
    }

    // Function to set permission for a doctor to access a patient's data
    function setPermission(address doctor, address patient, PermissionType permission) external {
        //require(msg.sender == doctor || msg.sender == relationshipHistoryContract, "Permission denied");

        doctorPermissions[patient][doctor] = permission;

        emit PermissionSet(doctor, patient, permission);
    }

    // Function to get the permission type a doctor has for a patient's data
    function getPermission(address doctor, address patient) external view returns (PermissionType) {
        return doctorPermissions[patient][doctor];
    }

    function permissionValid(address doctor, address patient, PermissionType permission) external view returns (bool){
         PermissionType grantedPermission = doctorPermissions[patient][doctor];
           if (grantedPermission == permission) {
                    return true;
           }else{
                  return  false;
           }
    }

    // Function to check if a doctor has a specific permission for a patient's data
    function checkPermission(address doctor, address patient, PermissionType requiredPermission) external returns (bool) {
      //  PermissionType grantedPermission = doctorPermissions[patient][doctor];
      PermissionType grantedPermission = PermissionType.READ;
        if (grantedPermission == requiredPermission) {
            // Update RelationshipHistoryContract with consent status as "permissioned"
            RelationshipHistory relationshipContract = RelationshipHistory(relationshipHistoryContract);
            relationshipContract.updateStatus(doctor, patient, RelationshipHistory.ConsentStatus.Authorized);
            return true;
        } else {
            // Update RelationshipHistoryContract with consent status as "invalid"
            RelationshipHistory relationshipContract = RelationshipHistory(relationshipHistoryContract);
            relationshipContract.updateStatus(doctor, patient, RelationshipHistory.ConsentStatus.Invalid);
            return false;
        }
    }

}
