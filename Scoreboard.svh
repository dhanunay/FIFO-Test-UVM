class Scoreboard extends uvm_scoreboard;

   `uvm_component_utils(Scoreboard)

     uvm_tlm_analysis_fifo#(Transaction) fifo;
   logic [7:0] q[$:255],i;
   int 	       countm=0;
   Transaction tr;

   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      fifo=new("fifo",this);
   endfunction // build_phase

   
   task run();
      forever 
	begin
	   tr=new("tr");
	   fifo.get(tr);
	   if(tr.WREQ)begin
	      pushFull(tr);end	   
	   else if(tr.RREQ) begin
	      $display("+++++++ RREQ - %h ++++++",tr.RD);
	      popEmpt(tr);
	   end
	   
	end 
   endtask // run 

   function void pushFull(Transaction tr); 
      if(tr.full==0)
	begin 
	   q.push_front(tr.WD);   
	   $display("------SCB TRANS REC  %h--------",tr.WD);
	end
     else if((q.size()!=256) && (tr.full))
	begin	  
	   `uvm_error("SCBF",$sformatf("--FIFO FULL ERROR :: fullFifo %b, Qsize : %d :------",tr.full,q.size()));
	   countm++;
	end
      else 
      // overwrite logic
      if((tr.full)&&(tr.WREQ))
	begin
	   q[(q.size())-1]=(tr.WD);
	   `uvm_error("SCBOW",$sformatf("--------OVER WRITE, qdatatoadd =%h ------",tr.WD));
	end
   
   endfunction // pushFull

   function void popEmpt(Transaction tr);
      if((tr.empty)&&(tr.RREQ))
	begin
	   `uvm_error("SCBRWE","--------READ WHILE EMPTY ERROR ------");
	end
      
      i=q.pop_back();
      
     if(tr.RD!=i)
	begin
	   `uvm_error("SCBD",$sformatf("--------Data Mismatch fifo:%h q:%h ------",tr.RD, i));
	   countm++;
	end
      else  if((q.size()!=0)&&(tr.empty))
	begin
	   `uvm_info("SCBE","--------FIFO EMPTY ERROR------",UVM_NONE);
	   countm++;   
	end
      
   endfunction // popEmpt

   
   function void report_phase(uvm_phase phase);
      $display("total mismatches : %d ",countm);
   endfunction // report_phase
   
   
endclass :Scoreboard