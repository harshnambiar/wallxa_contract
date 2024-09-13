// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Wallxa {

    uint genesis = (block.timestamp / (60 * 60 * 24));
    uint last_price = 10000;
    uint base_price = 10000;

    struct Info {
        uint tier;
        bytes url;
        bytes pic;
    }

    mapping (uint => address) owners;
    mapping (uint => Info) data;
    mapping (uint => uint) validity;
    mapping (address => address[]) pings;
    

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function rent(uint num, string memory link, string memory pc) public payable{
        uint tier_val = 0;
        if (num >= 1 && num < 8){
            tier_val = 3;
        }
        else if (num >= 8 && num < 15){
            tier_val = 2;
        }
        else {
            tier_val = 1;
        }
        uint day_now = (block.timestamp / (60*60*24));
        uint filled = 0;
        uint price = 0;
        uint prop_price = tier_val * ((3000 + day_now - genesis)/3) * 10 gwei;
        for (uint k = 1; k < 22; k++){
            if (validity[k] >= day_now){
                filled = filled + 1;
            }
        }
        if (filled > 15){
            price = prop_price;
        }
        else if (filled > 7 && filled <= 15){
            price = last_price;
        }
        else {
            if (last_price * 9 > 10 * base_price){
                price = (last_price * 9)/10 ;
            }
            else {
                price = base_price;
            }
        }
        require (num > 0, "the slots start from 1");
        require (num <= 21, "wallXa has 21 slots only");
        require (msg.value >= price, "not enough gwei attached");
        uint val = validity[num];
        if (val != 0){
            address cur_owner = owners[num];
            require (cur_owner != msg.sender, "you already own this slot");
            require (val < day_now, "this slot is still booked!");
            validity[num] = day_now + 30;
            data[num] = Info({
                tier: tier_val,
                url: bytes(link),
                pic: bytes(pc)
            });
            owners[num] = msg.sender;
        }
        else {
            validity[num] = day_now + 30;
            data[num] = Info({
                tier: tier_val,
                url: bytes(link),
                pic: bytes(pc)
            });
            owners[num] = msg.sender;
        }
        last_price = price;

    }

   
    function retrieve_base_price() public view returns (uint){
        uint day_now = (block.timestamp / (60*60*24));
        uint filled = 0;
        uint price = 0;
        uint prop_price = ((3000 + day_now - genesis)/3) * 10 gwei;
        for (uint k = 1; k < 22; k++){
            if (validity[k] >= day_now){
                filled = filled + 1;
            }
        }
        if (filled > 15){
            price = prop_price;
        }
        else if (filled > 7 && filled <= 15){
            price = last_price;
        }
        else {
            if (last_price * 9 > 10 * base_price){
                price = (last_price * 9)/10 ;
            }
            else {
                price = base_price;
            }
            
        }
        return price;
    }

    function retrieve_active_urls() public view returns (string[21][2] memory){
        uint day_now = (block.timestamp / (60 * 60 *24));
        string[21][2] memory res;
        for (uint i = 1; i < 22; i++){
            uint val = validity[i];
           
            if (day_now <= val){
                Info memory inf = data[i];
                res[i - 1][0] = string(inf.url);
                res[i - 1][1] = string(inf.pic);

            }
            else {
                res[i - 1][0] = "";
                res[i - 1][1] = "";
            }
            
        }
        return res;
    }

    function ping(address recipient) public {
        bool flag1 = false;
        bool flag2 = false;
        uint day_now = (block.timestamp / (60 * 60 * 24));
        for (uint i = 1; i < 22; i++){
            if (msg.sender == owners[i] && validity[i] >= day_now && data[i].tier == 3){
                flag1 = true;
            }
            if (recipient == owners[i] && validity[i] >= day_now && data[i].tier >= 2){
                flag2 = true;
            }
            if (flag1 && flag2){
                break;
            }
        }
        require(flag1, "only owner of a tier 3+ slot can ping");
        require(flag2, "only owner of a tier 2+ slot can be pinged");
        address[] memory pings_cur = pings[recipient];
        require (!exists(msg.sender, pings_cur), "you have already pinged this address");
        pings[recipient].push(msg.sender);  
    }

    function  exists(address add, address[] memory addresses) public pure returns (bool) {
        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == add) {
                return true;
            }
        }

        return false;
    }

    function fetch_pings() public view returns (address[] memory){
        uint day_now = (block.timestamp / (60 * 60 * 24));
        bool flag = false;
        for (uint i = 1; i < 22; i++){
            if (msg.sender == owners[i] && validity[i] >= day_now && data[i].tier >= 2){
                flag = true;
                break;
            }
            
        }
        require (flag, "you no longer have a tier 2+ subscription");
        return pings[msg.sender];
    }
}
