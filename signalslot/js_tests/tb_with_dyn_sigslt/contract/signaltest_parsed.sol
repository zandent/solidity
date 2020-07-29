pragma solidity ^0.6.9;

contract A {
	uint data;
    uint public constant ONE_HOUR = 180;
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // GENERATED BY SIGNALSLOT PARSER
    
    // Original Code:
    // signal priceFeedUpdate;

    // TODO: Arguments should not be limited to one 32 byte value

    // Generated variables that represent the signal
	bytes private priceFeedUpdate_data;
	bytes32 private priceFeedUpdate_dataslot;
	uint private priceFeedUpdate_status;
    bytes32 private priceFeedUpdate_key;

    // Set the data to be emitted
	function set_priceFeedUpdate_data(bytes memory dataSet) private {
       priceFeedUpdate_data = dataSet;
    }

    // Get the argument count
	function get_priceFeedUpdate_argc() public pure returns (uint argc) {
       return 0;
    }

    // Get the signal key
	function get_priceFeedUpdate_key() public view returns (bytes32 key) {
       return priceFeedUpdate_key;
    }

    // Get the data slot
    function get_priceFeedUpdate_dataslot() public view returns (bytes32 dataslot) {
       return priceFeedUpdate_dataslot;
    }

    // signal priceFeedUpdate construction
    // This should be called once in the contract construction.
    // This parser should automatically call it.
    function priceFeedUpdate() private {
        priceFeedUpdate_key = keccak256("priceFeedUpdate()");
		assembly {
			sstore(priceFeedUpdate_status_slot, createsig(0, sload(priceFeedUpdate_key_slot)))
			sstore(priceFeedUpdate_dataslot_slot, priceFeedUpdate_data_slot)
		}
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////

    function emitfunc(bytes memory DataSent) public {
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER
        
        // Original Code:
        // emitsig priceFeedUpdate(DataSent).delay(0)

        // Set the data field in the signal
        set_priceFeedUpdate_data(DataSent);
        // Get the argument count
        uint this_emitsig_priceFeedUpdate_argc = get_priceFeedUpdate_argc();
        // Get the data slot
		bytes32 this_emitsig_priceFeedUpdate_dataslot = get_priceFeedUpdate_dataslot();
        // Get the signal key
		bytes32 this_emitsig_priceFeedUpdate_key = get_priceFeedUpdate_key();
        // Use assembly to emit the signal and queue up slot transactions
		assembly {
			mstore(0x40, emitsig(this_emitsig_priceFeedUpdate_key, 0, this_emitsig_priceFeedUpdate_dataslot, this_emitsig_priceFeedUpdate_argc))
	    }
        //////////////////////////////////////////////////////////////////////////////////////////////////

    }
constructor() public {
   priceFeedUpdate();
}
}

contract B {
	A dut;
	bytes public LocalPriceSum;
    uint public constant ONE_HOUR = 180;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    // GENERATED BY SIGNALSLOT PARSER

    // Original Code:
    // slot priceReceive {...}

    // Generated variables that represent the slot
    uint private priceReceive_status;
    bytes32 private priceReceive_key;

    // Get the signal key
	function get_priceReceive_key() public view returns (bytes32 key) {
       return priceReceive_key;
    }

    // priceReceive construction
    // Should be called once in the contract construction
    function priceReceive() private {
        priceReceive_key = keccak256("priceReceive_func(bytes)");
        assembly {
            sstore(priceReceive_status_slot, createslot(0, 10, 30000, sload(priceReceive_key_slot)))
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // priceReceive code to be executed
    // The slot is converted to a function that will be called in slot transactions.
    function priceReceive_func(bytes memory obj) public {
        LocalPriceSum = obj;
    }

	function bindfunc(address addrA) public {
		dut = A(addrA);
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER

        // Original Code:
        // priceReceive.bind(dut.priceFeedUpdate)

        // Convert to address
		address dut_bindslot_address = address(dut);
        // Get signal key from emitter contract
		bytes32 dut_bindslot_priceFeedUpdate_key = keccak256("priceFeedUpdate()");
        // Get slot key from receiver contract
        bytes32 this_dut_bindslot_priceReceive_key = get_priceReceive_key();
        // Use assembly to bind slot to signal
		assembly {
			mstore(0x40, bindslot(dut_bindslot_address, dut_bindslot_priceFeedUpdate_key, this_dut_bindslot_priceReceive_key))
	    }
        //////////////////////////////////////////////////////////////////////////////////////////////////

	}

    function detachfunc() public {
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER

        // Original Code:
        // this.priceReceive.detach(dut.priceFeedUpdate)

        // Get the signal key
		bytes32 dut_detach_priceFeedUpdate_key = keccak256("priceFeedUpdate()");
        // Get the address
		address dut_detach_address = address(dut);
        //Get the slot key
        bytes32 this_dut_bindslot_priceReceive_key = get_priceReceive_key();
        // Use assembly to detach the slot
		assembly{
			mstore(0x40, detachslot(dut_detach_address, dut_detach_priceFeedUpdate_key, this_dut_bindslot_priceReceive_key))
		}
        //////////////////////////////////////////////////////////////////////////////////////////////////

    }

	function getLocalPriceSum() public returns (bytes memory){
		return LocalPriceSum;
	}
constructor() public {
   priceReceive();
}
}


