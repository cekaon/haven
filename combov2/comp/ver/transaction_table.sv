/*
 * transaction_table.sv: Transaction Table
 * Copyright (C) 2007 CESNET
 * Author(s): Marcela Simkova <xsimko03@stud.fit.vutbr.cz>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 * 3. Neither the name of the Company nor the names of its contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * This software is provided ``as is'', and any express or implied
 * warranties, including, but not limited to, the implied warranties of
 * merchantability and fitness for a particular purpose are disclaimed.
 * In no event shall the company or contributors be liable for any
 * direct, indirect, incidental, special, exemplary, or consequential
 * damages (including, but not limited to, procurement of substitute
 * goods or services; loss of use, data, or profits; or business
 * interruption) however caused and on any theory of liability, whether
 * in contract, strict liability, or tort (including negligence or
 * otherwise) arising in any way out of the use of this software, even
 * if advised of the possibility of such damage.
 *
 *
 *
 * TODO:
 *
 *
 */

  // Transaction table behaviour
  typedef enum {TR_TABLE_FIFO, TR_TABLE_FIRST_ONLY} tTrTableBehav;

  // --------------------------------------------------------------------------
  // -- Transaction Table
  // --------------------------------------------------------------------------
  class TransactionTable #(int behav = TR_TABLE_FIFO, 
                           type TransType = Transaction);
     // ---------------------
     // -- Class Variables --
     // ---------------------
     TransType tr_table[$];         // tr_table of transactions
     semaphore sem;                 // Semaphore solve problems with 
                                       // concurent acces to TransactionTable        
     integer added;                 // Items added to TransactionTable
     integer removed;               // Items removed from TransactionTable
    
    // -- Constructor ---------------------------------------------------------
    // Create a class 
    function new ();
      sem = new(1);
      added = 0;
      removed = 0;
    endfunction
    
    // ------------------------------------------------------------------------
    // Add item to the table
    task add(TransType transaction);
      lock();
      this.tr_table.push_back(transaction);
      added++;
      unlock();
    endtask: add
    
   // ------------------------------------------------------------------------
   //Remove item from the table
   task remove(TransType transaction, ref bit status, input int kind = -1);
      string diff;
      status=0;
      lock();

      if (behav==TR_TABLE_FIFO)begin  
      for(integer i=0; i < this.tr_table.size; i++) begin 
        if (this.tr_table[i].compare(transaction,diff, kind)==1) begin
           this.tr_table.delete(i);
           status=1;
           removed++;
           break;
           end
        end
      end
      if (behav==TR_TABLE_FIRST_ONLY && tr_table.size > 0) begin
          if (this.tr_table[0].compare(transaction,diff, kind)==1) begin
          this.tr_table.delete(0);
          status=1;
          removed++;
          end
      end 
        
      unlock();     
   endtask: remove 
 
    
    // ------------------------------------------------------------------------
    // Lock scoreboard 
    task lock();
       sem.get(1);                     // Semaphore is set to lock 
    endtask: lock

    // ------------------------------------------------------------------------
    // Unlock scoreboard
    task unlock();
       sem.put(1);                     // Semaphore is set to unlock
    endtask: unlock
    
    // ------------------------------------------------------------------------
    // Display the actual state of transaction table
    task display(integer full=1, string inst = "");
       lock();
       $write("------------------------------------------------------------\n");
       $write("-- %s TRANSACTION TABLE\n", inst);
       $write("------------------------------------------------------------\n");
       $write("Size: %d\n", tr_table.size);
       $write("Items added: %d\n", added);
       $write("Items removed: %d\n", removed);
       if (full)
          foreach(tr_table[i]) tr_table[i].display();
       $write("------------------------------------------------------------\n");
       unlock();
    endtask: display
endclass : TransactionTable

