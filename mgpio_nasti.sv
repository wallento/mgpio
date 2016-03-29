// Copyright 2016 by the authors
//
// Copyright and related rights are licensed under the Solderpad
// Hardware License, Version 0.51 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a
// copy of the License at http://solderpad.org/licenses/SHL-0.51.
// Unless required by applicable law or agreed to in writing,
// software, hardware and materials distributed under this License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
// OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the
// License.
//
// Authors:
//    Stefan Wallentowitz <stefan@wallentowitz.de>

module mgpio_nasti
  #(parameter BANKS=1,
    parameter BANKS_WIDTH=(BANKS>1 ? $clog2(BANKS) : 1),
    parameter BANK_AS_BITS=12)
   (
    input                                clk,
    input                                rst,

    input [BANK_AS_BITS+BANKS_WIDTH-1:0] awaddr,
    input [2:0]                          awprot,
    input                                awvalid,
    output                               awready,

    input [7:0]                          wdata,
    input                                wstrb,
    input                                wvalid,
    output                               wready,

    output [1:0]                         bresp,
    output                               bvalid,
    input                                bready,

    input [BANK_AS_BITS+BANKS_WIDTH-1:0] araddr,
    input [2:0]                          arprot,
    input                                arvalid,
    output                               arready,

    output [7:0]                         rdata,
    output [1:0]                         rresp,
    output                               rvalid,
    input                                rready,
    
    input [BANKS*8-1:0]                  gpio_in,
    output [BANKS*8-1:0]                 gpio_out,
    output [BANKS*8-1:0]                 gpio_oe
    );

   logic [BANK_AS_BITS+BANKS_WIDTH-1:0]  bus_addr;
   logic [7:0]                           bus_data_in;
   logic                                 bus_write;
   logic [7:0]                           bus_data_out;
   logic                                 bus_err;
   
   mgpio
     #(.BANKS(BANKS), .BANKS_WIDTH(BANKS_WIDTH),
       .BANK_AS_BITS(BANK_AS_BITS))
   u_mgpio
     (.*);
   
   reg                                   req, req_write, req_error;
   logic                                 nxt_req, nxt_req_write;

   always @(posedge clk) begin
      if (rst) begin
         req <= 0;
      end else begin
         req <= nxt_req;
      end
      req_write <= nxt_req_write;
      req_error <= req ? req_error : bus_err;
   end

   assign bresp = {2{req_error}};
   assign rresp = {2{req_error}};
   assign rdata = bus_data_out;
   assign bus_data_in = wdata;
   
   always @(*) begin
      nxt_req = req;
      nxt_req_write = req_write;

      awready = 0;
      wready = 0;
      arready = 0;
      bvalid = 0;
      rvalid = 0;
      
      bus_addr = {BANK_AS_BITS+BANKS_WIDTH{1'bx}};
      bus_write = 0;
      
      if (!req) begin
         if (awvalid & wvalid) begin
            awready = 1;
            wready = 1;

            bus_write = wstrb;
            bus_addr = awaddr;
            nxt_req = 1;
            nxt_req_write = 1;
         end else if (arvalid) begin
            arready = 1;

            bus_write = 0;
            bus_addr = araddr;
            nxt_req = 1;
            nxt_req_write = 0;
         end
      end else begin // if (!req)
         if (req_write) begin
            bvalid = 1;
            if (bready)
              nxt_req = 0;
         end else begin
            rvalid = 1;
            if (rready)
              nxt_req = 0;
         end // else: !if(req_write)
      end
   end         

endmodule
