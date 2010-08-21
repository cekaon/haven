/*
 * command_coverage: nFifo2fifo Coverage class - transaction coverage
 * Copyright (C) 2008 CESNET
 * Author(s): Marcela Simkov� <xsimko03@stud.fit.vutbr.cz>
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
 * $Id: command_coverage.sv 2805 2008-06-19 21:41:41Z xsimko03 $
 *
 * TODO:
 *
 */

  import math_pkg::*;       // log2()
  
  // --------------------------------------------------------------------------
  // -- Fifo Command Coverage for Interface iGeneral.nfifo_write_cb
  // --------------------------------------------------------------------------
  // This class measures exercised combinations of interface signals
    
  class CommandsCoverageWrite #(int pDataWidth=64,int pFlows=8,int pBlSize=512,int pLutMem=0, pGlobSt=0);
  
    // Interface on witch is covering measured
    virtual iNFifoRx.nfifo_write_tb #(pDataWidth,pFlows,pBlSize,pLutMem,pGlobSt) f_w;
    string  instanceName;

    // Sampling is enabled
    bit enabled;

    // Sampled values from interface
    logic write;
    logic full;
    
    //-- Covering transactions ----------------------------------------------
    covergroup CommandsCovergroup;
           
      // write coverpoint
      write: coverpoint write {
        bins write0 = {0};
        bins write1 = {1};
      }
      
      // full coverpoint
      full: coverpoint full{
        bins full0 = {0};
        bins full1 = {1};
      } 
      
      cross write, full;  
    
      option.per_instance=1; // Also per instance statistics
     endgroup

    // ------------------------------------------------------------------------
    // Constructor
    
    function new (virtual iNFifoRx.nfifo_write_tb #(pDataWidth,pFlows,pBlSize,pLutMem,pGlobSt) f_w,
                  string instanceName);
      this.f_w = f_w;                 // Store interface
      CommandsCovergroup = new;       // Create covergroup
      enabled=0;                      // Disable interface sampling
      this.instanceName = instanceName;
    endfunction

    // -- Enable command coverage measures ------------------------------------
    // Enable commands coverage measures
    task setEnabled();
      enabled = 1; // Coverage Enabling
      fork         
         run();    // Creating coverage subprocess
      join_none;   // Don't wait for ending
    endtask : setEnabled
         
    // -- Disable command coverage measures -----------------------------------
    // Disable generator
    task setDisabled();
      enabled = 0; // Disable measures
    endtask : setDisabled
   
    // -- Run command coverage measures ---------------------------------------
    // Take transactions from mailbox and generate them to interface
    task run();
       while (enabled) begin            // Repeat while enabled
         @(f_w.nfifo_write_cb);          // Wait for clock
         // Sample signals values
         write      = f_w.nfifo_write_cb.WRITE;
         full       = f_w.nfifo_write_cb.FULL;
         
         CommandsCovergroup.sample();
      end
    endtask : run
  
    // ------------------------------------------------------------------------
    // Display coverage statistic
    task display();
       $write("Commands coverage for %s: %d percent\n",
               instanceName, CommandsCovergroup.get_inst_coverage());
    endtask : display

  endclass: CommandsCoverageWrite

  // --------------------------------------------------------------------------
  // -- Fifo Command Coverage for Interface iGeneral.fifo_monitor_cb
  // --------------------------------------------------------------------------
  // This class measures exercised combinations of interface signals
  
  class CommandsCoverageMonitor #(int pDataWidth=64,int pFlows=8,int pBlSize=512,int pLutMem=0, pGlobSt=0);
  
    // Interface on witch is covering measured
    virtual iNFifoRx.fifo_monitor #(pDataWidth,pFlows,pBlSize,pLutMem,pGlobSt) f_m;
    string  instanceName;

    // Sampling is enabled
    bit enabled;

    // Sampled values from interface
    logic data_vld;
    logic read;
    logic [log2(pFlows)-1:0] block_addr;
    logic [pFlows-1:0] empty;
    
    
    //-- Covering transactions ----------------------------------------------
    covergroup CommandsCovergroup;
      // data_vld coverpoint
      data_vld: coverpoint data_vld {
        bins data_vld0 = {0};
        bins data_vld1 = {1};
      } 
           
      // read coverpoint
      read: coverpoint read {
        bins read0 = {0};
        bins read1 = {1};
      } 
      
      // block_addr coverpoint
      block_addr: coverpoint block_addr;
      
          
      // empty coverpoint
      empty: coverpoint empty{
        option.auto_bin_max = pFlows;
      }
      
        
      option.per_instance=1; // Also per instance statistics
     endgroup

    // ------------------------------------------------------------------------
    // Constructor
    
    function new (virtual iNFifoRx.fifo_monitor #(pDataWidth,pFlows,pBlSize,pLutMem,pGlobSt) f_m,
                  string instanceName);
      this.f_m = f_m;                 // Store interface
      CommandsCovergroup = new;       // Create covergroup
      enabled=0;                      // Disable interface sampling
      this.instanceName = instanceName;
    endfunction

    // -- Enable command coverage measures ------------------------------------
    // Enable commands coverage measures
    task setEnabled();
      enabled = 1; // Coverage Enabling
      fork         
         run();    // Creating coverage subprocess
      join_none;   // Don't wait for ending
    endtask : setEnabled
         
    // -- Disable command coverage measures -----------------------------------
    // Disable generator
    task setDisabled();
      enabled = 0; // Disable measures
    endtask : setDisabled
   
    // -- Run command coverage measures ---------------------------------------
    // Take transactions from mailbox and generate them to interface
    task run();
       while (enabled) begin            // Repeat while enabled
         @(f_m.fifo_monitor_cb);        // Wait for clock
         // Sample signals values
         data_vld   = f_m.fifo_monitor_cb.DATA_VLD;
         read       = f_m.fifo_monitor_cb.READ;
         block_addr = f_m.fifo_monitor_cb.BLOCK_ADDR;
         empty      = f_m.fifo_monitor_cb.EMPTY;
        
         
         CommandsCovergroup.sample();
      end
    endtask : run
  
    // ------------------------------------------------------------------------
    // Display coverage statistic
    task display();
       $write("Commands coverage for %s: %d percent\n",
               instanceName, CommandsCovergroup.get_inst_coverage());
    endtask : display

  endclass: CommandsCoverageMonitor

  // --------------------------------------------------------------------------
  // -- nFifo2Fifo Coverage
  // --------------------------------------------------------------------------
  // This class measure coverage of commands
  class Coverage #(int pDataWidth=64,int pFlows=8,int pBlSize=512,int pLutMem=0, pGlobSt=0);
    // Commands coverage lists
    CommandsCoverageWrite   #(pDataWidth,pFlows,pBlSize,pLutMem,pGlobSt) cmdListWrite[$];    
    CommandsCoverageMonitor #(pDataWidth,pFlows,pBlSize,pLutMem,pGlobSt) cmdListMonitor[$];
        
    // -- Add interface Write for command coverage ----------------------------------
    task addGeneralInterfaceWrite (virtual iNFifoRx.nfifo_write_tb #(pDataWidth,pFlows,pBlSize,pLutMem,pGlobSt) port,
                                   string name);
      // Create commands coverage class
      CommandsCoverageWrite #(pDataWidth,pFlows,pBlSize,pLutMem,pGlobSt) cmdCoverageWrite = new(port, name);  
      // Insert class into list
      cmdListWrite.push_back(cmdCoverageWrite);
    endtask : addGeneralInterfaceWrite
    
    // -- Add interface Tx for command coverage ----------------------------------
    task addGeneralInterfaceMonitor (virtual iNFifoRx.fifo_monitor #(pDataWidth,pFlows,pBlSize,pLutMem,pGlobSt) port,
                                     string name);
      // Create commands coverage class
      CommandsCoverageMonitor #(pDataWidth,pFlows,pBlSize,pLutMem,pGlobSt) cmdCoverageMonitor = new(port, name);  
      // Insert class into list
      cmdListMonitor.push_back(cmdCoverageMonitor);
    endtask : addGeneralInterfaceMonitor

    // -- Enable coverage measures --------------------------------------------
    // Enable coverage measres
    task setEnabled();
      foreach (cmdListWrite[i])   cmdListWrite[i].setEnabled();     // Enable for commands
      foreach (cmdListMonitor[i]) cmdListMonitor[i].setEnabled();   // Enable for commands
    endtask : setEnabled
         
    // -- Disable coverage measures -------------------------------------------
    // Disable coverage measures
    task setDisabled();
      foreach (cmdListWrite[i])   cmdListWrite[i].setDisabled();     // Disable for commands
      foreach (cmdListMonitor[i]) cmdListMonitor[i].setDisabled();   // Disable for commands
    endtask : setDisabled

    // ------------------------------------------------------------------------
    // Display coverage statistic
    virtual task display();
      $write("----------------------------------------------------------------\n");
      $write("-- COVERAGE STATISTICS:\n");
      $write("----------------------------------------------------------------\n");
      foreach (cmdListWrite[i])   cmdListWrite[i].display();
      foreach (cmdListMonitor[i]) cmdListMonitor[i].display();
      $write("----------------------------------------------------------------\n");
    endtask
  endclass : Coverage


