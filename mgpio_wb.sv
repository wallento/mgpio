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

module mgpio_wb
  #(parameter BANKS=1,
    parameter BANKS_WIDTH=(BANKS>1 ? $clog2(BANKS) : 1),
    parameter BANK_AS_BITS=12)
   (
    input                                clk,
    input                                rst,

    input [BANK_AS_BITS+BANKS_WIDTH-1:0] adr_i,
    input [7:0]                          dat_i,
    input                                cyc_i,
    input                                stb_i,
    input                                we_i,
    input                                sel_i,
    output                               ack_o,
    output                               rty_o,
    output                               err_o,
    output [7:0]                         dat_o,
    
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

   reg                                   ack, err;

   assign bus_addr = adr_i;
   assign bus_data_in = dat_i;
   assign bus_write = cyc_i & stb_i & we_i & sel_i;
   assign rty_o = 0;
   assign dat_o = bus_data_out;
   assign ack_o = ack;
   assign err_o = err;

   always @(posedge clk) begin
      if (rst) begin
         ack <= 0;
         err <= 0;
      end else begin
         if (cyc_i & stb_i & !(ack | err)) begin
            ack <= !bus_err;
            err <= bus_err;
         end else begin
            ack <= 0;
            err <= 0;
         end
      end
   end
   
endmodule
