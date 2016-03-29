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

module mgpio
  #(parameter BANKS=1,
    parameter BANKS_WIDTH=(BANKS>1 ? $clog2(BANKS) : 1),
    parameter BANK_AS_BITS=12)
   (
    input                                clk,
    input                                rst,

    input [BANK_AS_BITS+BANKS_WIDTH-1:0] bus_addr,
    input [7:0]                          bus_data_in,
    input                                bus_write,
    output [7:0]                         bus_data_out,
    output                               bus_err,

    input [BANKS*8-1:0]                  gpio_in,
    output [BANKS*8-1:0]                 gpio_out,
    output [BANKS*8-1:0]                 gpio_oe
    );

   reg [7:0]             gpio_reg [BANKS];
   reg [7:0]             gpio_dir [BANKS];

   logic [BANKS_WIDTH-1:0] addr_bank;
   logic                   write_data;
   logic                   write_dir;
   assign addr_bank = bus_addr[BANK_AS_BITS+BANKS_WIDTH-1:BANK_AS_BITS];
   assign write_data = bus_write & ~bus_addr[0];
   assign write_dir = bus_write & bus_addr[0];
   assign bus_err = |bus_addr[BANK_AS_BITS-1:1];
   
   logic [7:0]             data[BANKS];
   logic [7:0]             dir[BANKS];
   assign bus_data_out = bus_addr[0] ? dir[addr_bank] : data[addr_bank];
   
   genvar                  bank;
   generate
      for (bank=0; bank<BANKS; bank=bank+1) begin
         mgpio_bank u_bank
                (.clk      (clk),
                 .rst      (rst),
                 .data_en  ((addr_bank == bank) & write_data),
                 .data_in  (bus_data_in),
                 .dir_en   ((addr_bank == bank) & write_dir),
                 .dir_in   (bus_data_in),
                 .data_out (data[bank]),
                 .dir_out  (dir[bank]),
                 .gpio_in  (gpio_in[bank*8-1:-8]),
                 .gpio_out (gpio_out[bank*8-1:-8]),
                 .gpio_oe  (gpio_oe[bank*8-1:-8]));
      end
   endgenerate

endmodule // mgpio
