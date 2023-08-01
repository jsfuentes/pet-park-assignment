//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
enum AnimalType {
    Invalid,
    Fish,
    Cat,
    Dog,
    Rabbit,
    Parrot
}

struct Identity {
    uint age;
    bool is_male_gender;
    bool is_valid;
}

contract PetPark {
    address public contractAddress;
    address public owner;

    mapping(AnimalType => uint) public animals;
    mapping(address => AnimalType) public addressIsBorrowing;
    mapping(address => Identity) public addressToIdentity;

    //could be unneccessary
    modifier validAnimalType(AnimalType animal_type) {
        require(
            1 <= uint(animal_type) && animal_type <= type(AnimalType).max,
            "Invalid animal type"
        );
        _;
    }

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

    function add(
        AnimalType animal_type,
        uint count
    ) public onlyOwner validAnimalType(animal_type) {
        animals[animal_type] += count;
        emit Added(animal_type, count);
    }

    error InvalidIdentity();

    event Borrowed(AnimalType animal_type);

    function borrow(
        uint age,
        bool is_male_gender,
        AnimalType animal_type
    ) public validAnimalType(animal_type) {
        require(
            is_male_gender &&
                (animal_type == AnimalType.Dog ||
                    animal_type == AnimalType.Fish),
            "Males can only borrow Dogs and Fish"
        );
        require(
            !is_male_gender && age < 40 && animal_type != AnimalType.Cat,
            "Women under 40 cant borrow Cat"
        );
        require(
            addressIsBorrowing[msg.sender] != AnimalType.Invalid,
            "Address is already borrowing"
        );
        require(animals[animal_type] > 0, "No animals of this type left");
        if (
            addressToIdentity[msg.sender].is_valid &&
            (addressToIdentity[msg.sender].age != age ||
                addressToIdentity[msg.sender].is_male_gender != is_male_gender)
        ) {
            revert InvalidIdentity();
        }

        addressToIdentity[msg.sender] = Identity(age, is_male_gender, true);
        addressIsBorrowing[msg.sender] = animal_type;
        animals[animal_type] -= 1;
        emit Borrowed(animal_type);
    }

    event Returned(AnimalType animal_type);

    function giveBackAnimal() public {
        require(
            addressIsBorrowing[msg.sender] != AnimalType.Invalid,
            "Address is not borrowing"
        );
        addressIsBorrowing[msg.sender] = AnimalType.Invalid;
        animals[addressIsBorrowing[msg.sender]] += 1;
        emit Returned(addressIsBorrowing[msg.sender]);
    }
}
