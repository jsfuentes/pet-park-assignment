//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
enum AnimalType {
    None,
    Fish,
    Cat,
    Dog,
    Rabbit,
    Parrot
}

enum Gender {
    None,
    Male,
    Female
}

struct Identity {
    uint age;
    Gender gender;
    bool is_valid;
}

contract PetPark {
    address public contractAddress;
    address public owner;

    mapping(AnimalType => uint) public animals;
    mapping(address => AnimalType) public addressIsBorrowing;
    mapping(address => Identity) public addressToIdentity;

    modifier onlyOwner() {
        require(msg.sender == owner, "caller must be owner");
        _;
    }

    constructor() {
        contractAddress = address(this);
        owner = msg.sender;
        //comments can be like this
    }

    event Added(AnimalType animal_type, uint animal_count);

    function add(AnimalType animal_type, uint count) public onlyOwner {
        require(
            1 <= uint(animal_type) && animal_type <= type(AnimalType).max,
            "Invalid animal"
        );
        animals[animal_type] += count;
        emit Added(animal_type, count);
    }

    event Borrowed(AnimalType animal_type);

    function borrow(uint age, Gender gender, AnimalType animal_type) public {
        require(
            1 <= uint(animal_type) && animal_type <= type(AnimalType).max,
            "Invalid animal type"
        );
        require(age > 0, "age must be greater than 0");
        require(animals[animal_type] > 0, "Selected animal not available");
        require(
            !addressToIdentity[msg.sender].is_valid ||
                (addressToIdentity[msg.sender].is_valid &&
                    addressToIdentity[msg.sender].gender == gender),
            "Invalid Gender"
        );
        require(
            !addressToIdentity[msg.sender].is_valid ||
                (addressToIdentity[msg.sender].is_valid &&
                    addressToIdentity[msg.sender].age == age),
            "Invalid Age"
        );
        require(
            addressIsBorrowing[msg.sender] == AnimalType.None,
            "Already adopted a pet"
        );
        require(
            gender == Gender.Female ||
                (gender == Gender.Male &&
                    (animal_type == AnimalType.Dog ||
                        animal_type == AnimalType.Fish)),
            "Invalid animal for men"
        );
        require(
            gender == Gender.Male ||
                (gender == Gender.Female &&
                    age < 40 &&
                    animal_type != AnimalType.Cat),
            "Invalid animal for women under 40"
        );

        addressToIdentity[msg.sender] = Identity(age, gender, true);
        addressIsBorrowing[msg.sender] = animal_type;
        animals[animal_type] -= 1;
        emit Borrowed(animal_type);
    }

    event Returned(AnimalType animal_type);

    function giveBackAnimal() public {
        require(
            addressIsBorrowing[msg.sender] != AnimalType.None,
            "No borrowed pets"
        );
        animals[addressIsBorrowing[msg.sender]] += 1;
        addressIsBorrowing[msg.sender] = AnimalType.None;
        emit Returned(addressIsBorrowing[msg.sender]);
    }

    function animalCounts(AnimalType animal_type) public view returns (uint) {
        return animals[animal_type];
    }
}
