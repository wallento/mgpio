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

module mgpio_bank
  (
   input        clk,
   input        rst,

   input        data_en,
   input [7:0]  data_in,
   input        dir_en,
   input [7:0]  dir_in,
   output [7:0] data_out,
   output [7:0] dir_out,

   input [7:0]  gpio_in,
   output [7:0] gpio_out,
   output [7:0] gpio_oe
   );
   
   reg [7:0]    data;
   logic [7:0]  nxt_data;
   reg [7:0]    dir;

   assign gpio_oe = dir;
   assign gpio_out = data;

   always @(posedge clk) begin
      if (rst) begin
         dir <= 8'h0;
         data <= 8'hx;
      end else begin
         if (dir_en) dir <= dir_in;
         data <= nxt_data;
      end
   end

   always @(*) begin
      nxt_data = data;

      if (data_en)
        nxt_data = data_in;

      nxt_data = (nxt_data & dir) |
                 (gpio_in & ~dir);
   end
   
endmodule // mgpio_bank
