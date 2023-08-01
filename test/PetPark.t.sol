// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PetPark.sol";


contract PetParkTest is Test, PetPark {
    PetPark petPark;
    
    address testOwnerAccount;

    address testPrimaryAccount;
    address testSecondaryAccount;

    function setUp() public {
        petPark = new PetPark();

        testOwnerAccount = msg.sender;
        testPrimaryAccount = address(0xABCD);
        testSecondaryAccount = address(0xABDC);
    }

    function testOwnerCanAddAnimal() public {
        petPark.add(AnimalType.Fish, 5);
    }

    function testCannotAddAnimalWhenNonOwner() public {
        // 1. Complete this test and remove the assert line below
        petPark.add(AnimalType.Fish, 5);

        vm.expectRevert("Only the owner can perform this action");
        vm.prank(testPrimaryAccount);
        petPark.add(AnimalType.Fish, 5);
    }

    function testCannotAddInvalidAnimal() public {
        vm.expectRevert("Invalid animal");
        petPark.add(AnimalType.None, 5);
    }

    function testExpectEmitAddEvent() public {
        vm.expectEmit(false, false, false, true);

        emit Added(AnimalType.Fish, 5);
        petPark.add(AnimalType.Fish, 5);
    }

    function testCannotBorrowWhenAgeZero() public {
        vm.expectRevert("Invalid Age");
        petPark.borrow(0, Gender.Male, AnimalType.Fish); 
    }

    function testCannotBorrowUnavailableAnimal() public {
        vm.expectRevert("Selected animal not available");

        petPark.borrow(24, Gender.Male, AnimalType.Fish);
    }

    function testCannotBorrowInvalidAnimal() public {
        vm.expectRevert("Invalid animal type");

        petPark.borrow(24, Gender.Male, AnimalType.None);
    }

    function testCannotBorrowCatForMen() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, Gender.Male, AnimalType.Cat);
    }

    function testCannotBorrowRabbitForMen() public {
        petPark.add(AnimalType.Rabbit, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, Gender.Male, AnimalType.Rabbit);
    }

    function testCannotBorrowParrotForMen() public {
        petPark.add(AnimalType.Parrot, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, Gender.Male, AnimalType.Parrot);
    }

    function testCannotBorrowForWomenUnder40() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Invalid animal for women under 40");
        petPark.borrow(24, Gender.Female, AnimalType.Cat);
    }

    function testCannotBorrowTwiceAtSameTime() public {
        petPark.add(AnimalType.Fish, 5);
        petPark.add(AnimalType.Cat, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

		vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

        vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Cat);
    }

    function testCannotBorrowWhenAddressDetailsAreDifferent() public {
        petPark.add(AnimalType.Fish, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

		vm.expectRevert("Invalid Age");
        vm.prank(testPrimaryAccount);
        petPark.borrow(23, Gender.Male, AnimalType.Fish);

		vm.expectRevert("Invalid Gender");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Female, AnimalType.Fish);
    }

    function testExpectEmitOnBorrow() public {
        petPark.add(AnimalType.Fish, 5);
        vm.expectEmit(false, false, false, true);

        emit Borrowed(AnimalType.Fish);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);
    }

    function testBorrowCountDecrement() public {
        // 3. Complete this test and remove the assert line below
        // Add some animals to the park for testing purposes
        petPark.add(AnimalType.Fish, 5);

        // Get the current count of Fish animals in the park
        uint initialFishCount = petPark.animalCounts(AnimalType.Fish);

        // Borrow a Fish animal
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

        // Get the updated count of Fish animals in the park
        uint updatedFishCount = petPark.animalCounts(AnimalType.Fish);

        // Assert that the count of Fish animals has decremented by 1
        assertEq(updatedFishCount, initialFishCount - 1);
       
    }

    function testCannotGiveBack() public {
        vm.expectRevert("No borrowed pets");
        petPark.giveBackAnimal();
    }

    function testPetCountIncrement() public {
        petPark.add(AnimalType.Fish, 5);

        petPark.borrow(24, Gender.Male, AnimalType.Fish);
        uint reducedPetCount = petPark.animalCounts(AnimalType.Fish);

        petPark.giveBackAnimal();
        uint currentPetCount = petPark.animalCounts(AnimalType.Fish);

		assertEq(reducedPetCount, currentPetCount - 1);
    }
}