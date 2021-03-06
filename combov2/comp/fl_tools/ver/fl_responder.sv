/*
 * fl_responder_pkg.sv: FrameLink Responder
 * Copyright (C) 2008 CESNET
 * Author(s): Marek Santa <xsanta06@stud.fit.vutbr.cz>
 *            Martin Kosek <kosek@liberouter.org>
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
 * $Id: fl_responder.sv 8930 2009-06-22 18:18:52Z xsanta06 $
 *
 * TODO:
 *
 */
 
  // --------------------------------------------------------------------------
  // -- Frame Link Responder Class
  // --------------------------------------------------------------------------
  /* This class is responsible for random intra- and intertransaction's dealys. 
   * It's used by class monitor. Unit must be enabled by "setEnable()" function
   * call. Random delaying can be stoped by "setDisable()" function call.
   */
  class FrameLinkResponder #(int pDataWidth=32, int pDremWidth=2);
    
    // -- Private Class Atributes --
    string  inst;                            // Monitor identification
    bit     enabled;                         // Monitor is enabled
    virtual iFrameLinkTx.tb #(pDataWidth,pDremWidth) fl;
    
    // ----
    rand bit enRxDelay;   // Enable/Disable delays between transactions
      // Enable/Disable delays between transaction (weights)
      int rxDelayEn_wt             = 1; 
      int rxDelayDisable_wt        = 3;
    rand integer rxDelay; // Delay between transactions
      // Delay between transactions limits
      int rxDelayLow               = 0;
      int rxDelayHigh              = 3;
    // ----


    // ----
    rand bit enInsideRxDelay;   // Enable/Disable delays inside transaction
      // Enable/Disable delays inside transaction weights
      int insideRxDelayEn_wt       = 1; 
      int insideRxDelayDisable_wt  = 3;
    rand integer insideRxDelay; // Delay inside transaction 
      // Minimal/Maximal delay between transaction words
      int insideRxDelayLow         = 0;
      int insideRxDelayHigh        = 3;
    // ----

    // -- Constrains --
    constraint cDelays {
      enRxDelay dist { 1'b1 := rxDelayEn_wt,
                       1'b0 := rxDelayDisable_wt
                     };

      rxDelay inside {
                      [rxDelayLow:rxDelayHigh]
                     };

      enInsideRxDelay dist { 1'b1 := insideRxDelayEn_wt,
                             1'b0 := insideRxDelayDisable_wt
                           };
                     
      insideRxDelay inside {
                            [insideRxDelayLow:insideRxDelayHigh]
                           };               
      }

    
    // -- Public Class Methods --

    // -- Constructor ---------------------------------------------------------
    function new ( string inst,
                   virtual iFrameLinkTx.tb #(pDataWidth,pDremWidth) fl
                   );
      this.enabled     = 0;           // Monitor is disabled by default   
      this.fl          = fl;          // Store pointer interface 
      this.inst        = inst;        // Store driver identifier
      
      // Setting default values for Frame Link interface
      fl.cb.DST_RDY_N <= 1;           // Ready ONLY IF enabled
    endfunction
    
    // -- Enable Responder ----------------------------------------------------
    // Enable responder and runs responder process
    task setEnabled();
      enabled = 1; // Responder Enabling
      fork         
        run();     // Creating responder subprocess
      join_none;   // Don't wait for ending
    endtask : setEnabled
        
    // -- Disable responder ---------------------------------------------------
    // Disable responder
    task setDisabled();
      enabled = 0; // Disable responder, after receiving last transaction
    endtask : setDisabled 
    
    // -- Run Responder -------------------------------------------------------
    // 
    task run();
      
      // Repeat while enabled
      while (enabled) begin
        
        // destination ready active for one cycle
        fl.cb.DST_RDY_N <= 0;
        @(fl.cb);
        
        // randomize waits
        assert(randomize());

        if (fl.cb.EOF_N == 0 && fl.cb.SRC_RDY_N == 0)   // delay between frames
          waitRxDelay();
        else                                            // delay inside frame
          waitInsideRxDelay();
      end

      fl.cb.DST_RDY_N <= 1;
    endtask : run
    
    // -- Not ready between transactions --------------------------------------
    // Random wait between sending transactions (Set DST_RDY_N to 1)
    task waitRxDelay();
      
      if (enRxDelay)
        repeat (rxDelay) begin
          fl.cb.DST_RDY_N <= 1;
          @(fl.cb);
        end
    endtask : waitRxDelay
        
    // -- Random wait ---------------------------------------------------------
    // Random wait during sending transaction (Set DST_RDY_N to 1)
    task waitInsideRxDelay();

      if (enInsideRxDelay)
        repeat (insideRxDelay) begin
          fl.cb.DST_RDY_N <= 1;
          @(fl.cb);
        end
    endtask : waitInsideRxDelay
    
  endclass: FrameLinkResponder
