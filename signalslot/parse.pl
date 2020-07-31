#!/usr/bin/perl
use strict;
use warnings;


my $defaultfile = $ARGV[0];
my $mainfile = $ARGV[1];

open( my $default_fh, "<", $defaultfile ) or die $!;
open( my $main_fh,    ">", "$mainfile\.firststage" ) or die $!;


while ( my $line = <$default_fh> ) {
    #remove all comments
    if($line =~ /\/\//){
        my ($line_wo_comments) = $line =~ /(.+)\/\//;
        if(defined $line_wo_comments){
            $line = "$line_wo_comments\n";
        }else{
            $line = "";
        }
    }

    if($line =~ /signal\s/){
        my $flag = 0;
        my @line_arr = split(/(\;)/,$line);
        foreach (@line_arr){
            my $line_arr_ele = $_;
            if($line_arr_ele =~ /signal\s/){
                $flag = 1;
                my ($func) = $line_arr_ele =~ /signal(.+)\(/;
                $func =~ s/^\s+|\s+$//g;
                my ($arg_arr) = $line_arr_ele =~ /\((.+)\)/;
                my $message;
                if(defined $arg_arr){
                    my @arg = split /\s/, $arg_arr;
                    my $argc = 0;
                    if($arg[0] =~ /\[\]/){#now it can accept fix and dynamic
                        $argc = 0;
                    }elsif($arg[0] eq "bytes"){
                        $argc = 0;
                    }else{
                        $argc = 1;
                    }
                    my $location_declare;
                    if($argc == 1){
                        $location_declare = "";
                    }else{
                        $location_declare = "memory";
                    }
                    $message = <<"END_MESSAGE";
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // GENERATED BY SIGNALSLOT PARSER
    
    // Original Code:
    // signal $func;

    // TODO: Arguments should not be limited to one 32 byte value

    // Generated variables that represent the signal
	$arg[0] private $func\_data;
	bytes32 private $func\_dataslot;
	uint private $func\_status;
    bytes32 private $func\_key;

    // Set the data to be emitted
	function set\_$func\_data\($arg[0] $location_declare dataSet) private {
       $func\_data = dataSet;
    }

    // Get the argument count
	function get\_$func\_argc\(\) public pure returns (uint argc) {
       return $argc;
    }

    // Get the signal key
	function get\_$func\_key\() public view returns (bytes32 key) {
       return $func\_key;
    }

    // Get the data slot
    function get\_$func\_dataslot\() public view returns (bytes32 dataslot) {
       return $func\_dataslot;
    }

    // signal $func construction
    // This should be called once in the contract construction.
    // This parser should automatically call it.
    function $func\() private {
        $func\_key = keccak256(\"$func\(\)\");
		assembly {
			sstore($func\_status\_slot, createsig($argc, sload($func\_key_slot)))
			sstore($func\_dataslot_slot, $func\_data_slot)
		}
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////
END_MESSAGE
                }else{#if there is no emit data defined
                    $message = <<"END_MESSAGE";
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // GENERATED BY SIGNALSLOT PARSER

    // Original code:
    // signal $func

    // Generated variables that represent the signal
	bytes32 private $func\_dataslot;\/\/the data pointer is NULL
	uint private $func\_status;
    bytes32 private $func\_key;

    // Get the signal key
	function get\_$func\_key\() public view returns (bytes32 key) {
       return $func\_key;
    }

    // Get the data slot
    function get\_$func\_dataslot\() private view returns (bytes32 dataslot) {
       return $func\_dataslot;
    }

    // signal $func construction
    // This should be called once in the contract construction.
    // This parser should automatically call it.
    function $func\() private {
        $func\_key = keccak256(\"$func\(\)\");
		assembly {
			sstore($func\_status\_slot, createsig(0, sload($func\_key_slot)))
			sstore($func\_dataslot_slot, 0x0)
		}
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////
END_MESSAGE
                }
                print {$main_fh} $message;
            }else{
                if($flag == 1){#the flag is used for avoid printing additional ";"
                    $flag = 0;
                }else{
                    print {$main_fh} $line_arr_ele;
                }
            }
        }
    }elsif($line =~ /\.bind\(/){
        my $flag = 0;
        my @line_arr = split(/(\;)/,$line);
        foreach (@line_arr){
            my $line_arr_ele = $_;
            if($line_arr_ele =~ /\.bind\(/){
                $flag = 1;
                $line_arr_ele = "$line_arr_ele\;";
                my ($slot_obj) = $line_arr_ele =~ /(\w+)\.bind/;
                my ($sig_obj) = $line_arr_ele =~ /\.bind\((.+)\)\;/;
                if($sig_obj =~ /\./){}else{$sig_obj = "this\.$sig_obj";}
                my ($sig_obj_func) = "$sig_obj\)" =~ /\.(\w+)\)/;
                my ($emiter) = $sig_obj =~ /(.+)\.$sig_obj_func/;
                my $emiter_tr = $emiter;
                $emiter_tr =~ tr/\./\_/;
                my $emiter_func_call;
                if($emiter eq "this"){
                    $emiter_func_call = "";
                }else{
                    $emiter_func_call = "$emiter\.";
                }

                my $slot_obj_origin = $slot_obj;
                if($slot_obj =~ /\./){}else{$slot_obj = "this\.$slot_obj";}
                my ($slot_obj_func) = "$slot_obj\)" =~ /\.(\w+)\)/;
                my ($receiver) = $slot_obj =~ /(.+)\.$slot_obj_func/;
                my $receiver_tr = $receiver;
                $receiver_tr =~ tr/\./\_/;
                my $receiver_func_call;
                if($receiver eq "this"){
                    $receiver_func_call = "";
                }else{
                    $receiver_func_call = "$receiver\.";
                }
                my $message = <<"END_MESSAGE";
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER

        // Original Code:
        // $slot_obj_origin.bind($emiter.$sig_obj_func)

        // Convert to address
		address $emiter_tr\_bindslot\_address = address($emiter\);
        // Get signal key from emitter contract
		bytes32 $emiter_tr\_bindslot\_$sig_obj_func\_key = keccak256("$sig_obj_func\()");
        // Get slot key from receiver contract
        bytes32 $receiver_tr\_$emiter_tr\_bindslot\_$slot_obj_func\_key = ${receiver_func_call}get\_$slot_obj_func\_key\();
        // Use assembly to bind slot to signal
		assembly {
			mstore(0x40, bindslot($emiter_tr\_bindslot\_address, $emiter_tr\_bindslot\_$sig_obj_func\_key, $receiver_tr\_$emiter_tr\_bindslot\_$slot_obj_func\_key))
	    }
        //////////////////////////////////////////////////////////////////////////////////////////////////
END_MESSAGE
                print {$main_fh} $message;
            }else{
                if($flag == 1){
                    $flag = 0;
                }else{
                    print {$main_fh} $line_arr_ele;
                }
            }
        }
    }elsif($line =~ /slot\s/){ #ignore xxx;slot {}xxxx
        # my $slot_end_counter = 0;
        # $slot_end_counter = $slot_end_counter + ($line =~ /\{/g) - ($line =~ /\}/g);
        my ($slot_name) = $line =~ /([\w,\_]+)\(/;
        my ($slot_obj) = $line =~ /\((.+)\)/;
        my ($slot_title) = $line =~ /$slot_name(.+)\)/;
        $slot_title = "$slot_name\_func$slot_title\)";
        my $argc = 0;
        my @arg;
        my $hash_slot_title;
        if(defined $slot_obj){
            @arg = split /\s/, $slot_obj;#argment format must be "blalba[] blabla"
            if($arg[0] =~ /\[\]/){#now it can accept fix and dynamic
                $argc = 0;
            }elsif($arg[0] eq "bytes"){
                $argc = 0;
            }else{
                $argc = 1;
            }
            $hash_slot_title = "$slot_name\_func\($arg[0]\)";
        }else{
            $hash_slot_title = "$slot_name\_func\(\)";
        }
        my $message = <<"END_MESSAGE";
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // GENERATED BY SIGNALSLOT PARSER

    // Original Code:
    // slot $slot_name {...}

    // Generated variables that represent the slot
    uint private $slot_name\_status;
    bytes32 private $slot_name\_key;

    // Get the signal key
	function get\_$slot_name\_key\() public view returns (bytes32 key) {
       return $slot_name\_key;
    }

    // $slot_name construction
    // Should be called once in the contract construction
    function $slot_name\() private {
        $slot_name\_key = keccak256(\"$hash_slot_title");
        assembly {
            sstore($slot_name\_status_slot, createslot($argc, 10, 30000, sload($slot_name\_key_slot)))
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // $slot_name code to be executed
    // The slot is converted to a function that will be called in slot transactions.
    function $slot_title public {
END_MESSAGE
        print {$main_fh} $message;
        # while ($slot_end_counter != 0){
        #     $line = <$default_fh>;
        #     $slot_end_counter = $slot_end_counter + ($line =~ /\{/g) - ($line =~ /\}/g);
        #     # if($slot_end_counter == 0){
        #     #     print {$main_fh} "\}\n";
        #     # }
        #     print {$main_fh} $line;
        # }
    }elsif($line =~ /emitsig\s/){
        my $flag = 0;
        my @line_arr = split(/(\;)/,$line);
        foreach (@line_arr){
            my $line_arr_ele = $_;
            if($line_arr_ele =~ /emitsig\s/){
                $flag = 1;
                $line_arr_ele = "$line_arr_ele\;";
                my ($signal_type) = $line_arr_ele =~ /^(.*?)\(/s;
                my @arg = split /\s+/, $signal_type;
                if($arg[0] eq "emitsig"){
                    $signal_type = $arg[1];
                }else{
                    $signal_type = $arg[2];
                }
                if ($signal_type =~ /\./){
                    #do nothing
                }else{
                    $signal_type = "this.$signal_type";
                }
                my ($sig_obj_func) = "$signal_type\;" =~ /\.(\w+)\;/;
                my ($emiter) = $signal_type =~ /(.+)\.$sig_obj_func/;
                my ($delay_obj) = $line_arr_ele =~ /\.delay\((.+)\)\;/;
                my ($emit_obj) = $line_arr_ele =~ /\((.+)\)\.delay\(/;
                my $emiter_tr = $emiter;
                $emiter_tr =~ tr/\./\_/;
                my $emiter_func_call;
                if($emiter eq "this"){
                    $emiter_func_call = "";
                }else{
                    $emiter_func_call = "$emiter\.";
                }
                my $message;
                if(defined $emit_obj){
                $message = <<"END_MESSAGE";
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER
        
        // Original Code:
        // emitsig $sig_obj_func($emit_obj).delay($delay_obj)

        // Set the data field in the signal
        set_$sig_obj_func\_data\($emit_obj\);
        // Get the argument count
        uint $emiter_tr\_emitsig\_$sig_obj_func\_argc = ${emiter_func_call}get\_$sig_obj_func\_argc();
        // Get the data slot
		bytes32 $emiter_tr\_emitsig\_$sig_obj_func\_dataslot = ${emiter_func_call}get\_$sig_obj_func\_dataslot();
        // Get the signal key
		bytes32 $emiter_tr\_emitsig\_$sig_obj_func\_key = ${emiter_func_call}get\_$sig_obj_func\_key();
        // Use assembly to emit the signal and queue up slot transactions
		assembly {
			mstore(0x40, emitsig($emiter_tr\_emitsig\_$sig_obj_func\_key, $delay_obj, $emiter_tr\_emitsig\_$sig_obj_func\_dataslot, $emiter_tr\_emitsig\_$sig_obj_func\_argc))
	    }
        //////////////////////////////////////////////////////////////////////////////////////////////////
END_MESSAGE
                }else{#if no data emitted defined
                $message = <<"END_MESSAGE";
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER

        // Original Code:
        // emitsig $sig_obj_func().delay($delay_obj)

        // Get the data slot
		bytes32 $emiter_tr\_emitsig\_$sig_obj_func\_dataslot = ${emiter_func_call}get\_$sig_obj_func\_dataslot();
        // Get the signal key
		bytes32 $emiter_tr\_emitsig\_$sig_obj_func\_key = ${emiter_func_call}get\_$sig_obj_func\_key();
        // Use assembly to emit the signal and queue up slot transactions
		assembly {
			mstore(0x40, emitsig($emiter_tr\_emitsig\_$sig_obj_func\_key, $delay_obj, $emiter_tr\_emitsig\_$sig_obj_func\_dataslot, 2))
	    }
        //////////////////////////////////////////////////////////////////////////////////////////////////
END_MESSAGE
                }
                print {$main_fh} $message;
            }else{
                if($flag == 1){
                    $flag = 0;
                }else{
                    print {$main_fh} $line_arr_ele;
                }
            }
        }
    }elsif($line =~ /\.detach\(/){
        my $flag = 0;
        my @line_arr = split(/(\;)/,$line);
        foreach (@line_arr){
            my $line_arr_ele = $_;
            if($line_arr_ele =~ /\.detach\(/){
                $flag = 1;
                $line_arr_ele = "$line_arr_ele\;";
                my ($slot_obj) = $line_arr_ele =~ /(\w+)\.detach/;
                my ($sig_obj) = $line_arr_ele =~ /\.detach\((.+)\)\;/;
                if($sig_obj =~ /\./){}else{$sig_obj = "this\.$sig_obj";}
                my ($sig_obj_func) = "$sig_obj\)" =~ /\.(\w+)\)/;
                my ($emiter) = $sig_obj =~ /(.+)\.$sig_obj_func/;
                my $emiter_tr = $emiter;
                $emiter_tr =~ tr/\./\_/;
                my $emiter_func_call;
                if($emiter eq "this"){
                    $emiter_func_call = "";
                }else{
                    $emiter_func_call = "$emiter\.";
                }

                my $slot_obj_origin = $slot_obj;
                if($slot_obj =~ /\./){}else{$slot_obj = "this\.$slot_obj";}
                my ($slot_obj_func) = "$slot_obj\)" =~ /\.(\w+)\)/;
                my ($receiver) = $slot_obj =~ /(.+)\.$slot_obj_func/;
                my $receiver_tr = $receiver;
                $receiver_tr =~ tr/\./\_/;
                my $receiver_func_call;
                if($receiver eq "this"){
                    $receiver_func_call = "";
                }else{
                    $receiver_func_call = "$receiver\.";
                }
                my $message = <<"END_MESSAGE";
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER

        // Original Code:
        // $slot_obj.detach($emiter.$sig_obj_func)

        // Get the signal key
		bytes32 $emiter_tr\_detach\_$sig_obj_func\_key = keccak256("$sig_obj_func\()");
        // Get the address
		address $emiter_tr\_detach\_address = address($emiter\);
        //Get the slot key
        bytes32 $receiver_tr\_$emiter_tr\_bindslot\_$slot_obj_func\_key = ${receiver_func_call}get\_$slot_obj_func\_key\();
        // Use assembly to detach the slot
		assembly{
			mstore(0x40, detachslot($emiter_tr\_detach\_address, $emiter_tr\_detach\_$sig_obj_func\_key, $receiver_tr\_$emiter_tr\_bindslot\_$slot_obj_func\_key))
		}
        //////////////////////////////////////////////////////////////////////////////////////////////////
END_MESSAGE
                print {$main_fh} $message;
            }else{
                if($flag == 1){
                    $flag = 0;
                }else{
                    print {$main_fh} $line_arr_ele;
                }
            }
        }
    }else{
        print {$main_fh} $line;
    }
}
close $default_fh;
close $main_fh;
open( $default_fh,    "<", "$mainfile\.firststage" )    or die $!;
open( $main_fh,       ">",  $mainfile )                 or die $!;

#contructor handling: if building constructor, it must be placed under slot/signal declaration
#contract cannot be written into the same line
#if building a contructor, it cannot be written into the same line
#TODO: The indentation doesn't look that good, but who cares anyways :))
my @sigslot_funcinit_arr = ();
my $end_counter = 0;
my $in_contract = 0;
my $found_constuct = 0;
while ( my $line = <$default_fh> ) {
    my $inc = ($line =~ /\{/g);
    my $sub = ($line =~ /\}/g);
    $end_counter = $end_counter + $inc - $sub;
    if($line =~ /contract\s/){
        $in_contract = 1;
        if($inc > 0 && $sub > 0 && $end_counter == 0)
        {
            print("contract cannot be written into the same line, exit now ...\n");
            exit;
        }
        print {$main_fh} $line;
    }elsif($end_counter == 0){#contract finished or not enter
        if($in_contract == 1 && $found_constuct == 0){#add default construct
            print {$main_fh} "constructor() public {\n";
            if(@sigslot_funcinit_arr){
                foreach ( @sigslot_funcinit_arr ) {
                    print {$main_fh} $_;
                }
            }
            print {$main_fh} "}\n";
        }
        @sigslot_funcinit_arr = ();
        $in_contract = 0;
        print {$main_fh} $line;
    }elsif($line =~ /constructor/){
        $found_constuct = 1;
        print {$main_fh} $line;
        if(@sigslot_funcinit_arr){
            foreach ( @sigslot_funcinit_arr ) {
                print {$main_fh} $_;
            }
        }
    }else{
        if($line =~ /createsig\(/){
            my ($funcTmp) = $line =~ /sload\((.+)\_key_slot\)\)\)/;
            push(@sigslot_funcinit_arr, "   $funcTmp\();\n");
        }
        elsif($line =~ /createslot\(/){
            my ($funcTmp) = $line =~ /sload\((.+)\_key_slot\)\)\)/;
            push(@sigslot_funcinit_arr, "   $funcTmp\();\n");
        }
        print {$main_fh} $line;
    }
}

close $default_fh;
close $main_fh;
system("rm -rf $mainfile\.firststage");