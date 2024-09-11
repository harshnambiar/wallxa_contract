// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Wallxa {

    uint genesis = (block.timestamp / (60 * 60 * 24));


    mapping (uint => address) owners;
    mapping (uint => uint) validity;
    mapping (uint => uint) tiers;

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function rent(uint num) public payable{
        uint tier = 0;
        if (num >= 1 && num < 8){
            tier = 3;
        }
        else if (num >= 8 && num < 15){
            tier = 2;
        }
        else {
            tier = 1;
        }
        uint day_now = (block.timestamp / (60*60*24));
        uint price = tier * ((3000 + day_now - genesis)/3) * 10000 gwei;
        require (num <= 21, "wallXa has 21 slots only");
        require (msg.value >= price, "not enough gwei attached");
        uint val = validity[num];
        if (val != 0){
            address cur_owner = owners[num];
            require (cur_owner != msg.sender, "you already own this slot");
            require (val < day_now, "this slot is still booked!");
            validity[num] = day_now + 30;
            tiers[num] = tier;
            owners[num] = msg.sender;
        }
        else {
            validity[num] = day_now + 30;
            tiers[num] = tier;
            owners[num] = msg.sender;
        }

    }

   
    function retrieve_base_price() public view returns (uint){
        uint day_now = (block.timestamp / (60 * 60 * 24));
        uint bp = ((3000 + day_now - genesis)/3) * 10000;
        return bp;
    }
}
