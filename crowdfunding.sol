// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Crowdfunding {
    enum StateOfProject {
        Open, Cloused
    }
    struct Contribution {
        address contributor;
        uint256 donative;
    }
    struct Project {
        string id;
        string name;
        string description;
        uint256 funds;
        StateOfProject state;
        address payable author;
        address owner;
        uint256 goal;
    }
    Project[] public projects;
    mapping(string => Contribution[]) public contributions;

    event ProjectCreated(string id, string name, string description, uint256 goal);
    event stateOfProject(string id, StateOfProject state);
    event benefactor(string id, address author, uint256 amount);

    modifier onlyOwner(uint indexProject) {
        require(
            projects[indexProject].owner == msg.sender,
            "Only owner can change this project"
        );
        _;
    }

    modifier benefactors(uint indexProject) {
        require(
            msg.sender != projects[indexProject].owner,
            "the project owner cannot send funds"
        );
        _;
    }

    function createProject (
        string calldata id, 
        string calldata name,
        string calldata description,
        uint256 goal
        ) public {
       require(goal > 0, "Goal must be greater than 0");
       Project memory project = Project(
           id,
           name,
           description,
           0,
           StateOfProject.Open,
           payable(msg.sender),
           msg.sender,
           goal
       );
       projects.push(project);
       emit ProjectCreated(id, name, description, goal);
    }
    
    function fundProject (uint indexProject) public payable benefactors(indexProject) {
        require(msg.value > 0, "the contribution must be greater than 0");
        require(projects[indexProject].state == StateOfProject.Open, "the project is closed");
        projects[indexProject].author.transfer(msg.value);
        projects[indexProject].funds += msg.value;
        contributions[projects[indexProject].id].push(Contribution(msg.sender, msg.value));
        emit benefactor(projects[indexProject].id, msg.sender, msg.value);
    }

    function changeState (uint indexProject, StateOfProject newState) public onlyOwner(indexProject) {
        require(newState != projects[indexProject].state, 'the state must be different from the current one');
        projects[indexProject].state = newState;
        emit stateOfProject(projects[indexProject].id, newState);
    }
}