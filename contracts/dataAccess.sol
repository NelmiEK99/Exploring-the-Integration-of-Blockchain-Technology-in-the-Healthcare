// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataAccess {
    struct DataEntry {
        string queryLink;
        address patient;
    }

    mapping(address => mapping(address => DataEntry)) private doctorPatientData; // doctor -> patient -> DataEntry

    event DataAdded(address indexed doctor, address indexed patient, string queryLink);
    event DataRevoked(address indexed doctor, address indexed patient);

    // Function to add data for a specific doctor and patient
    function addData(address doctor, address patient, string memory queryLink) public returns (bool) {
        doctorPatientData[doctor][patient] = DataEntry(queryLink, patient);
        emit DataAdded(doctor, patient, queryLink);
        return true;
    }

    // Function to get data for a specific doctor and patient
    function getData(address doctor, address patient) public view returns (string memory) {
        DataEntry storage entry = doctorPatientData[doctor][patient];
        require(bytes(entry.queryLink).length != 0, "No data found for this doctor and patient.");
        return entry.queryLink;
    }

    // Function to revoke data for a specific doctor and patient
    function revokeData(address doctor, address patient) public {
        require(bytes(doctorPatientData[doctor][patient].queryLink).length != 0, "No data to revoke.");
        delete doctorPatientData[doctor][patient];
        emit DataRevoked(doctor, patient);
    }
}





// contract DataAccess {
//     struct DataEntry {
//         string queryLink;
//     }

//     mapping(address => DataEntry) private doctorData;

//     event DataAdded(address doctor, string queryLink);
//     event DataRevoked(address doctor);

//     function addData(address doctor, string memory queryLink) public {
//         doctorData[doctor] = DataEntry(queryLink);
//         emit DataAdded(doctor, queryLink);
//     }

//     function getData(address doctor) public view returns (string memory) {
//         DataEntry storage entry = doctorData[doctor];
//         return (entry.queryLink);
//     }

//     function revokeData(address doctor) public {
//         delete doctorData[doctor];
//         emit DataRevoked(doctor);
//     }

// }