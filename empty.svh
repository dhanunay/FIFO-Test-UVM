class emptySeq extends uvm_sequence#(Transaction);
   `uvm_object_utils(emptySeq);
   Transaction tr;
   int num=258;

   function new(string name="");
      super.new(name);
   endfunction // new

   task body();
      repeat(num)
	begin
	   tr=new("tr");
	   start_item(tr);
	   assert(tr.randomize() with {tr.RREQ==1;
				       tr.WREQ==0;})
		     else `uvm_fatal("FE","Fatal Error During Randomization");
	   finish_item(tr);
	end
   endtask // body
endclass // emptySeq
