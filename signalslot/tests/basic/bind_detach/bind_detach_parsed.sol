pragma solidity ^0.6.9;

contract Emitter {
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // GENERATED BY SIGNALSLOT PARSER
    
    // Original Code:
    // signal Alert;

    // TODO: Arguments should not be limited to one 32 byte value

    // Generated variables that represent the signal
	bytes32 private Alert_data;
	bytes32 private Alert_dataslot;
	uint private Alert_status;
    bytes32 private Alert_key;

    // Set the data to be emitted
	function set_Alert_data(bytes32  dataSet) private {
       Alert_data = dataSet;
    }

    // Get the argument count
	function get_Alert_argc() public pure returns (uint argc) {
       return 1;
    }

    // Get the signal key
	function get_Alert_key() public view returns (bytes32 key) {
       return Alert_key;
    }

    // Get the data slot
    function get_Alert_dataslot() public view returns (bytes32 dataslot) {
       return Alert_dataslot;
    }

    // signal Alert construction
    // This should be called once in the contract construction.
    // This parser should automatically call it.
    function Alert() private {
        Alert_key = keccak256("Alert()");
		assembly {
			sstore(Alert_status_slot, createsig(1, sload(Alert_key_slot)))
			sstore(Alert_dataslot_slot, Alert_data_slot)
		}
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////


    function send_alert(bytes32 value) public {
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER
        
        // Original Code:
        // emitsig Alert(value).delay(0)

        // Set the data field in the signal
        set_Alert_data(value);
        // Get the argument count
        uint this_emitsig_Alert_argc = get_Alert_argc();
        // Get the data slot
		bytes32 this_emitsig_Alert_dataslot = get_Alert_dataslot();
        // Get the signal key
		bytes32 this_emitsig_Alert_key = get_Alert_key();
        // Use assembly to emit the signal and queue up slot transactions
		assembly {
			mstore(0x40, emitsig(this_emitsig_Alert_key, 0, this_emitsig_Alert_dataslot, this_emitsig_Alert_argc))
	    }
        //////////////////////////////////////////////////////////////////////////////////////////////////

    }
constructor() public {
   Alert();
}
}

contract Receiver {
    Emitter source;
    bytes32 private data;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    // GENERATED BY SIGNALSLOT PARSER

    // Original Code:
    // slot HandleAlert {...}

    // Generated variables that represent the slot
    uint private HandleAlert_status;
    bytes32 private HandleAlert_key;

    // Get the signal key
	function get_HandleAlert_key() public view returns (bytes32 key) {
       return HandleAlert_key;
    }

    // HandleAlert construction
    // Should be called once in the contract construction
    function HandleAlert() private {
        HandleAlert_key = keccak256("HandleAlert_func(bytes32)");
        assembly {
            sstore(HandleAlert_status_slot, createslot(1, 10, 30000, sload(HandleAlert_key_slot)))
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // HandleAlert code to be executed
    // The slot is converted to a function that will be called in slot transactions.
    function HandleAlert_func(bytes32 value) public {
        data = value;
    }

    function get_data() public view returns (bytes32 ret) {
        ret = data;
    }

    function bind_to_alert() public view {
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER

        // Original Code:
        // HandleAlert.bind(source.Alert)

        // Convert to address
		address source_bindslot_address = address(source);
        // Get signal key from emitter contract
		bytes32 source_bindslot_Alert_key = keccak256("Alert()");
        // Get slot key from receiver contract
        bytes32 this_source_bindslot_HandleAlert_key = get_HandleAlert_key();
        // Use assembly to bind slot to signal
		assembly {
			mstore(0x40, bindslot(source_bindslot_address, source_bindslot_Alert_key, this_source_bindslot_HandleAlert_key))
	    }
        //////////////////////////////////////////////////////////////////////////////////////////////////

    }

    function detach_from_alert() public view {
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER

        // Original Code:
        // this.HandleAlert.detach(source.Alert)

        // Get the signal key
		bytes32 source_detach_Alert_key = keccak256("Alert()");
        // Get the address
		address source_detach_address = address(source);
        //Get the slot key
        bytes32 this_source_bindslot_HandleAlert_key = get_HandleAlert_key();
        // Use assembly to detach the slot
		assembly{
			mstore(0x40, detachslot(source_detach_address, source_detach_Alert_key, this_source_bindslot_HandleAlert_key))
		}
        //////////////////////////////////////////////////////////////////////////////////////////////////

    }

    constructor(Emitter addr) public {
   HandleAlert();
        source = addr;
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER

        // Original Code:
        // HandleAlert.bind(source.Alert)

        // Convert to address
		address source_bindslot_address = address(source);
        // Get signal key from emitter contract
		bytes32 source_bindslot_Alert_key = keccak256("Alert()");
        // Get slot key from receiver contract
        bytes32 this_source_bindslot_HandleAlert_key = get_HandleAlert_key();
        // Use assembly to bind slot to signal
		assembly {
			mstore(0x40, bindslot(source_bindslot_address, source_bindslot_Alert_key, this_source_bindslot_HandleAlert_key))
	    }
        //////////////////////////////////////////////////////////////////////////////////////////////////

    }
}