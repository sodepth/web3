// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;



contract BuildAgency {

    struct Build {
        uint buildID;
        address owner;
        string info;
        uint square;
        bool giftSTATE;
        bool saleSTATE;
        bool arestSTATE;
    }

    struct Gift{
        uint giftID;
        uint buildID;
        address _adrFrom;
        address _adrTo;
        uint time;
        giftSTAT status;
    }
    
    struct Sale{
        uint buildID;
        address owner;
        address newOwner;
        uint price;
        address[] buyers;
        uint[] prices;
    }

    enum giftSTAT {
        ACTIVE,
        REFUSE,
        ACCEPT,
        ENDTIME,
        CANCEL
    }

    Build[] public buildings;
    Gift[] public gifts;
    Sale[] public sales;
    address public admin;
    uint public giftTime = 60;

    modifier isAdmin() {
        require(msg.sender == admin, "You are not admin");
        _;
    }
    modifier onlyOwner(uint buildID) {
        require(buildings[buildID].owner == msg.sender, "Is not your build");
        _;
    }
    modifier defaultSTATUS(uint buildID) {
        require(buildings[buildID].giftSTATE == false, "Already in present");
        require(buildings[buildID].saleSTATE == false, "Already in sale");
        require(buildings[buildID].arestSTATE == false, "Build in arest");
        _;
    }

    constructor(address adminADR){

        // admin = msg.sender;

        admin = adminADR;
    }

    //admin

    function createBuild(address _owner, string memory _info, uint _square) public isAdmin {
        require(_owner != address(0), "wrong address");
        require(_square > 0, "wrong square");
        buildings.push(Build(buildings.length, _owner, _info, _square, false, false, false));
    }



    function changeAREST(uint buildID, bool _newarest) public isAdmin{
        require(_newarest != buildings[buildID].arestSTATE,"the same arest");
        buildings[buildID].arestSTATE = _newarest;
    }


    //gift

    function createGift(uint buildID, address _adrTo) public onlyOwner(buildID) defaultSTATUS(buildID){
        require(_adrTo != address(0), "wrong_address");
        require(buildID < buildings.length,"wrong buildID value");
        require(_adrTo != msg.sender, "adr == you adr!");
        gifts.push(Gift(gifts.length, buildID, msg.sender,_adrTo, giftTime+ block.timestamp, giftSTAT.ACTIVE));
        buildings[buildID].giftSTATE = true;
    }



    function cancelGift(uint giftID) public{
        require(giftID < gifts.length);
        require(gifts[giftID].status == giftSTAT.ACTIVE, "Already finished");
        require(gifts[giftID]._adrFrom == msg.sender, "You are not owner");
        uint buildID = gifts[giftID].buildID;
        if (gifts[giftID].time > block.timestamp) {
            gifts[giftID].status = giftSTAT.CANCEL;
        }
        else {
            gifts[giftID].status = giftSTAT.ENDTIME;
        }
        buildings[buildID].giftSTATE = false;
    }

    function acceptGift(uint giftID) public{
        uint buildID = gifts[giftID].buildID;
        require(buildings[buildID].arestSTATE == false, "build is arested");
        require(giftID < gifts.length);
        require(gifts[giftID].status == giftSTAT.ACTIVE, "Already finished");
        require(gifts[giftID]._adrTo == msg.sender, "This is gift not for you");
        if (gifts[giftID].time > block.timestamp) {
            gifts[giftID].status = giftSTAT.ACCEPT;
            buildings[buildID].owner = msg.sender;
        }
        else {
            gifts[giftID].status = giftSTAT.ENDTIME;
        }
        buildings[buildID].giftSTATE = false;
    }
    
    function refuseGift(uint giftID) public {
        uint buildID = gifts[giftID].buildID;
        require(giftID < gifts.length);
        require(gifts[giftID].status == giftSTAT.ACTIVE, "Already finished");
        require(gifts[giftID]._adrTo == msg.sender, "This is gift not for you");
        if (gifts[giftID].time > block.timestamp) {
            gifts[giftID].status = giftSTAT.REFUSE;
        }
        else {
            gifts[giftID].status = giftSTAT.ENDTIME;
        }
        buildings[buildID].giftSTATE = false;
    }

    //trade

    function createSale(uint buildID, uint _price) public onlyOwner(buildID) defaultSTATUS(buildID){
        require(buildID < buildings.length,"wrong buildID value");
        require(_price > 10**9 wei);
        address[] memory _buyers;
        uint[] memory _prices;
        sales.push(Sale(buildID, msg.sender, address(0), _price, _buyers, _prices));
        buildings[buildID].saleSTATE = true;
    }


}