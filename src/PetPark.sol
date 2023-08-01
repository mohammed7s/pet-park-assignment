// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    // Animal types enumeration
    enum AnimalType { None, Fish, Cat, Dog, Rabbit, Parrot }

    // Gender enumeration
    enum Gender { Male, Female }

    // Struct to represent an animal
    struct Animal {
        AnimalType animalType;
        uint8 age;
        Gender gender;
    }

    // Mapping to keep track of available animal counts
    mapping(AnimalType => uint) public animalCounts;

    // Mapping to keep track of borrowed animals
    mapping(address => Animal) public borrowedAnimals;

    // Event emitted when an animal is added to the park
    event Added(AnimalType indexed animalType, uint8 age);

    // Event emitted when an animal is borrowed from the park
    event Borrowed(AnimalType indexed animalType);

    // Event emitted when a borrowed animal is returned to the park
    event Returned(AnimalType indexed animalType);

    // Modifier to ensure that the caller is the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Modifier to ensure that the caller is not currently borrowing an animal
    modifier notBorrowed() {
        require(borrowedAnimals[msg.sender].animalType == AnimalType.None, "Already adopted a pet");
        _;
    }

    // Modifier to ensure that the caller is eligible to borrow a certain animal type
    modifier eligibleForAnimal(AnimalType _animalType, Gender _gender, uint8 _age) {
        require(_age > 0, "Invalid Age");

        if (_gender == Gender.Male){
            require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
        } else if (_animalType == AnimalType.Cat && _gender == Gender.Female) {
            require(_age > 40, "Invalid animal for women under 40");
        }
        _;
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Function to add an animal to the park
    function add(AnimalType _animalType, uint8 _age) external onlyOwner {
        require(_age > 0, "Invalid Age");
        require(_animalType != AnimalType.None, "Invalid animal");

        animalCounts[_animalType] += _age;

        emit Added(_animalType, _age);
    }

    // Function to borrow an animal from the park
    function borrow(uint8 _age, Gender _gender, AnimalType _animalType)
        external
        notBorrowed
        eligibleForAnimal(_animalType, _gender, _age)
    {
        // Check if the animal type is valid
        require(_animalType != AnimalType.None, "Invalid animal type");

        require(animalCounts[_animalType] > 0, "Selected animal not available");

        borrowedAnimals[msg.sender] = Animal(_animalType, _age, _gender);
        animalCounts[_animalType]--;

        emit Borrowed(_animalType);
    }

    // Function to give back the borrowed animal
    function giveBackAnimal() external {
        require(borrowedAnimals[msg.sender].animalType != AnimalType.None, "No borrowed pets");

        AnimalType borrowedAnimalType = borrowedAnimals[msg.sender].animalType;
        delete borrowedAnimals[msg.sender];
        animalCounts[borrowedAnimalType]++;

        emit Returned(borrowedAnimalType);
    }
}
