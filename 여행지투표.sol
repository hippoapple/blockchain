pragma solidity ^0.4.22;

import "http://www.github.com/ethereum/dapp-bin/library/stringUtils.sol";
import "./GottaGoCoin.sol";

contract Travel {
   
    address admin;
    string[] locations;
    mapping (string => uint) difficulty;
    mapping (uint => address) public idToTraveler;
    mapping (address => Traveler) addressToTraveler;
    event newUser(string name, address wallet);
    
    function Travel() {
        admin = msg.sender;
    }
    
    struct Traveler {
        string name;
        address personalWallet;
        string[] visitedPlaces;
        uint numberVisited;
    }
    
    Traveler[] public travelers;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the administrator can call this.");
        _;
    }
    
    function newTraveler(string _name) public {
        string[] memory empty;
        Traveler memory temp = Traveler(_name, msg.sender, new string[](0), 0);
        uint id = travelers.push(temp) - 1; // memory는 포인터 없나... 자료가 없다... 제발 포인터 없기를.. null도 안됨
        idToTraveler[id] = msg.sender;
        addressToTraveler[msg.sender] = temp; 
        newUser(_name, msg.sender);
    }
    
    function addNewLocation(string _location, uint _difficulty) public onlyAdmin {
        difficulty[_location] = _difficulty;
        uint l = locations.length;
        locations.push(_location);
    }
    
    function checkIn(string _location, address _GGCContract) public payable {
        
        bool validLocation = false;
        for(uint i = 0 ; i < locations.length ; i++) {
            if(StringUtils.equal(_location, locations[i])) validLocation = true;
        }
        require(validLocation, "Currently not a servicing area");
        
        string[] memory places = addressToTraveler[msg.sender].visitedPlaces;
        uint length = places.length;
        
        bool notAlready = true;
        for(uint j = 0 ; j < length ; j++) {
            if (StringUtils.equal(places[j], _location)) {
                notAlready = false;
            }
        }
        require(notAlready, "No Double Check-ins");
        
        GottaGoCoin gottaFunct = GottaGoCoin(_GGCContract);
        gottaFunct.getToken(difficulty[_location]);
        
        addressToTraveler[msg.sender].visitedPlaces.push(_location);
        
    }
    
    function getTraveler(uint number) public returns (string) {
        return travelers[number].name;
    }

    

   
}