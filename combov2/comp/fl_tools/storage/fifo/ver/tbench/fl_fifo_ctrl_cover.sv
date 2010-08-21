/*
 * fl_fifo_cmnd_cover: Frame Link FIFO Coverage class - transaction coverage
 * Copyright (C) 2008 CESNET
 * Author(s): Marek Santa <xsanta06@stud.fit.vutbr.cz>
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
 * $Id: fl_fifo_ctrl_cover.sv 6008 2008-10-20 17:07:36Z xsanta06 $
 *
 * TODO:
 *
 */

  // --------------------------------------------------------------------------
  // -- Frame Link FIFO Command Coverage for Interface FrameLinkFifo
  // --------------------------------------------------------------------------
  // This class measures exercised combinations of interface signals
  
  class CommandsCoverageFifo #(int pStatusWidth=10);
  
    // Interface on witch is covering measured
    virtual iFrameLinkFifo.ctrl_tb #(pStatusWidth) ctrl;
    string  instanceName;

    // Sampling is enabled
    bit enabled;

    // Sampled values from interface
    logic lstblk                    ;   // Last block detection
    logic [pStatusWidth-2:0] status ;   // MSBs of exact number of free items in the FIFO
    logic empty                     ;   // FIFO is empty
    logic full                      ;   // FIFO is full
    logic frameRdy                  ;   // At least one whole frame is in the FIFO

     
    //-- Covering transactions ----------------------------------------------
    covergroup CommandsCovergroup;
      // Last block coverpoint
      lstblk: coverpoint lstblk {
        bins lstblk0 = {0};        
        bins lstblk1 = {1};
        }
      // Empty coverpoint
      empty: coverpoint empty {
        bins empty0 = {0};
        bins empty1 = {1};
        }
      // Full coverpoint
      full: coverpoint full {
        bins full0 = {0};
        bins full1 = {1};
        }
      // Frame Ready coverpoint
      frameRdy: coverpoint frameRdy {
        bins frameRdy0 = {0};
        bins frameRdy1 = {1};
        }
      // Drem coverpoint
      status: coverpoint status;

        option.per_instance=1; // Also per instance statistics
     endgroup

    // ------------------------------------------------------------------------
    // Constructor
    
    function new (virtual iFrameLinkFifo.ctrl_tb #(pStatusWidth) ctrl,
                  string instanceName);
      this.ctrl = ctrl;               // Store interface
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
         @(ctrl.ctrl_cb);               // Wait for clock
         // Sample signals values
         lstblk   = ctrl.ctrl_cb.LSTBLK;
         status   = ctrl.ctrl_cb.STATUS;
         empty    = ctrl.ctrl_cb.EMPTY;
         full     = ctrl.ctrl_cb.FULL;
         frameRdy = ctrl.ctrl_cb.FRAME_RDY;
         CommandsCovergroup.sample();
      end
    endtask : run
  
    // ------------------------------------------------------------------------
    // Display coverage statistic
    task display();
       $write("Commands coverage for %s: %d percent\n",
               instanceName, CommandsCovergroup.get_inst_coverage());
    endtask : display

  endclass: CommandsCoverageFifo

  // --------------------------------------------------------------------------
  // -- Frame Link FIFO Coverage
  // --------------------------------------------------------------------------
  // This class measure coverage of commands
  class FifoCoverage #(int pStatusWidth=10) ;
    CommandsCoverageFifo #(pStatusWidth)   cmdListFifo[$];  // Commands coverage list
        
    // -- Add interface Fifo ctrl for command coverage ------------------------
    task addFrameLinkInterfaceFifo ( virtual iFrameLinkFifo.ctrl_tb #(pStatusWidth)port,
                                   string name);
      // Create commands coverage class
      CommandsCoverageFifo #(pStatusWidth) cmdCoverageFifo = new(port, name);  
      // Insert class into list
      cmdListFifo.push_back(cmdCoverageFifo);
    endtask : addFrameLinkInterfaceFifo
    
    // -- Enable coverage measures --------------------------------------------
    // Enable coverage measres
    task setEnabled();
      foreach (cmdListFifo[i]) cmdListFifo[i].setEnabled();   // Enable for commands
    endtask : setEnabled
         
    // -- Disable coverage measures -------------------------------------------
    // Disable coverage measures
    task setDisabled();
      foreach (cmdListFifo[i]) cmdListFifo[i].setDisabled();     // Disable for commands
    endtask : setDisabled

    // ------------------------------------------------------------------------
    // Display coverage statistic
    virtual task display();
      foreach (cmdListFifo[i]) cmdListFifo[i].display();
      $write("----------------------------------------------------------------\n");
    endtask
  endclass : FifoCoverage


