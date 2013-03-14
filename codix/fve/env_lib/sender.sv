/******************************************************************************
 *         Hardware accelerated Functional Verification of Processor          *
 ******************************************************************************/
/**
 *  \file   sorter.sv
 *  \date   09-03-2013
 *  \brief  Sender merge input signal from SW environment 
 */
  
 /*!
 * This class is responsible for dividing FrameLink transactions to parts
 * and attaching NetCOPE protocol header to each part. Also creates control 
 * transactions (src_rdy information) with NetCOPE protocol header. Transactions
 * are received by 'transMbx'(Mailbox) property.
 *
 */
 class Sender extends ovm_object; 
 
    // Public Class Atributes 
    string    inst;      //! Sender identification
    byte      id;        //! Sender ID number
    tTransMbx transMbx;  //! Transaction mailbox
    tTransMbx inputMbx;  //! Input controller's mailbox
    InputCbs  cbs[$];    //! Sender callback list  

    // registration of component tools
    `ovm_component_utils_begin( sorter )
        `ovm_field_object( OVM_DEFAULT | OVM_NOCOMPARE | OVM_NOPRINT | OVM_NORECORD | OVM_NOPACK )
    `ovm_component_utils_end

    // Constructor - creates new instance of this class
    // \param inst     - driver instance name
    // \param transMbx - transaction mailbox   
    function new( string name, ovm_component parent, string inst, byte id, tTransMbx transMbx, tTransMbx inputMbx );
        super.new( name, parent );

        // Create mailbox
        this.inst        = inst;      //! Store sender identifier
        this.id          = id;        //! Sender ID number
        this.transMbx    = transMbx;  //! Store pointer to mailbox
        this.inputMbx    = inputMbx;  //! Store pointer to mailbox 

    endfunction : new

    // build - instantiates child components
    function void build;
        super.build();
    endfunction: build

   /*! 
    * Set Sender Callback - callback object into List 
    */
    virtual function void setCallbacks(InputCbs cbs);
      this.cbs.push_back(cbs);
    endfunction : setCallbacks 
    
   /*! 
    * Sends start control transaction to HW.    
    */ 
    virtual task sendStart();
      NetCOPETransaction controlTrans = new();
      
      controlTrans.data    = new[8];
      
      // NetCOPE header
      controlTrans.data[0] = id;  // endpointID
      controlTrans.data[1] = 0;   // endpointProtocol
      controlTrans.data[2] = 0; 
      controlTrans.data[3] = 0;
      controlTrans.data[4] = 1;   // transType
      controlTrans.data[5] = 0;
      controlTrans.data[6] = 0;   // ifcProtocol
      controlTrans.data[7] = 0;   // ifcInfo
      
      controlTrans.endpointID  = id;
      controlTrans.transType   = 1;  // control start transaction
      controlTrans.ifcProtocol = 0;  // no protocol
      controlTrans.ifcInfo     = 0;  // no info
      
      //controlTrans.display("START CONTROL");
      inputMbx.put(controlTrans);    // put transaction to mailbox  
    endtask : sendStart
    
   /*! 
    * Sends stop control transaction to HW.    
    */ 
    task sendStop();
      NetCOPETransaction controlTrans = new();
      
      controlTrans.data    = new[8];
      
      // NetCOPE header
      controlTrans.data[0] = id;  // endpointID
      controlTrans.data[1] = 0;   // endpointProtocol
      controlTrans.data[2] = 0; 
      controlTrans.data[3] = 0;
      controlTrans.data[4] = 4;   // transType
      controlTrans.data[5] = 0;
      controlTrans.data[6] = 0;   // ifcProtocol
      controlTrans.data[7] = 0;   // ifcInfo
      
      controlTrans.endpointID  = id;
      controlTrans.endpointID  = 0;  // identifies driver protocol
      controlTrans.transType   = 4;  // control stop transaction
      controlTrans.ifcProtocol = 0;  // no protocol
      controlTrans.ifcInfo     = 0;  // no info
      
      //controlTrans.display("STOP CONTROL");
      inputMbx.put(controlTrans);    // put transaction to mailbox  
    endtask : sendStop
    
   /*! 
    * Sends waitfor control transaction to HW.    
    */ 
    task sendWait(int clocks);
      NetCOPETransaction controlTrans = new();
      logic [63:0] data = clocks;
      
      controlTrans.data = new[16];
      
      // NetCOPE header
      controlTrans.data[0] = id;  // endpointID
      controlTrans.data[1] = 0;   // endpointProtocol
      controlTrans.data[2] = 0; 
      controlTrans.data[3] = 0;
      controlTrans.data[4] = 2;   // transType
      controlTrans.data[5] = 0;
      controlTrans.data[6] = 0;   // ifcProtocol
      controlTrans.data[7] = 0;   // ifcInfo
      
      controlTrans.endpointID  = id;
      controlTrans.transType   = 2;  // control wait transaction
      controlTrans.ifcProtocol = 0;  // no protocol
      controlTrans.ifcInfo     = 0;  // no info
      
      for(int i=0; i<8; i++)
        for(int j=0; j<8; j++)
          controlTrans.data[i+8][j] = data[i*8+j];
      
      //controlTrans.display("WAIT FOR CONTROL");
      inputMbx.put(controlTrans);    // put transaction to mailbox  
    endtask : sendWait
    
   /*! 
    * Sends waitforever control transaction to HW.    
    */
    task sendWaitForever();
      NetCOPETransaction controlTrans = new();
      
      controlTrans.data = new[8];
      
      // NetCOPE header
      controlTrans.data[0] = id;  // endpointID
      controlTrans.data[1] = 0;   // endpointProtocol
      controlTrans.data[2] = 0; 
      controlTrans.data[3] = 0;
      controlTrans.data[4] = 3;   // transType
      controlTrans.data[5] = 0;
      controlTrans.data[6] = 0;   // ifcProtocol
      controlTrans.data[7] = 0;   // ifcInfo
      
      controlTrans.endpointID  = id;
      controlTrans.transType   = 3;  // control wait transaction
      controlTrans.ifcProtocol = 0;  // no protocol
      controlTrans.ifcInfo     = 0;  // no info
      
      //controlTrans.display("WAIT FOREVER CONTROL");
      inputMbx.put(controlTrans);    // put transaction to mailbox
    endtask : sendWaitForever
 endclass : Sender  
