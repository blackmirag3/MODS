`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2024 01:05:13 AM
// Design Name: 
// Module Name: game_state
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module game_state (input clk, input [12:0] x, y,
                    input USER_READY, OPP_READY, GAME_END, USER_WIN, NEW_GAME, 
                    output reg GAME_START = 0, 
                    output reg [15:0] oled_screen);

    wire clk_25Mhz, clk_1khz;
    
    reg [15:0] orange = 16'b11111_101010_00000;
    reg [15:0] yellow = 16'b11111_111010_00000;
    reg [15:0] green = 16'b10101_111111_00000;

    reg [11:0] count = 0;
    reg [1:0] count_down_state = 0;

    slow_clock c1 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
    slow_clock c2 (.CLOCK(clk), .m(32'd49999), .SLOW_CLOCK(clk_1khz));

    wire ready, press, not_ready;
    wire waiting, for_p2, waiting_scr;
    wire three, three_edge, two, two_edge, one, one_edge;
    wire user_win, user_lose;
    
    assign ready = (x >= 18 && x <= 19 && y >= 15 && y <= 24) || (x >= 24 && x <= 25 && y >= 17 && y <= 18) ||
                   (x >= 20 && x <= 23 && y >= 15 && y <= 16) || (x >= 20 && x <= 23 && y >= 19 && y <= 20) ||
                   (x >= 22 && x <= 23 && y >= 21 && y <= 22) || (x >= 24 && x <= 25 && y >= 23 && y <= 24) || // letter R
                   (x >= 28 && x <= 29 && y >= 15 && y <= 24) || (x >= 30 && x <= 35 && y >= 15 && y <= 16) ||
                   (x >= 30 && x <= 33 && y >= 19 && y <= 20) || (x >= 30 && x <= 35 && y >= 23 && y <= 24) || // letter E
                   (x >= 38 && x <= 39 && y >= 17 && y <= 24) || (x >= 44 && x <= 45 && y >= 17 && y <= 24) ||
                   (x >= 40 && x <= 43 && y >= 15 && y <= 16) || (x >= 40 && x <= 43 && y >= 19 && y <= 20) || // letter A
                   (x >= 48 && x <= 49 && y >= 15 && y <= 24) || (x >= 54 && x <= 55 && y >= 17 && y <= 22) ||
                   (x >= 50 && x <= 53 && y >= 15 && y <= 16) || (x >= 50 && x <= 53 && y >= 23 && y <= 24) || // letter D
                   (x >= 58 && x <= 59 && y >= 15 && y <= 18) || (x >= 66 && x <= 67 && y >= 15 && y <= 18) ||
                   (x >= 60 && x <= 65 && y >= 19 && y <= 20) || (x >= 62 && x <= 63 && y >= 21 && y <= 24) || // letter Y
                   (x >= 70 && x <= 75 && y >= 15 && y <= 16) || (x >= 76 && x <= 77 && y >= 17 && y <= 20) ||
                   (x >= 72 && x <= 75 && y >= 19 && y <= 20) || (x >= 73 && x <= 74 && y >= 23 && y <= 24);   // ? mark

    assign press = (y == 31 && ((x >= 23 && x <= 25) || (x >= 28 && x <= 30) || (x >= 33 && x <= 36) || (x >= 39 && x <= 41) ||
                   (x >= 44 && x <= 46) || (x >= 50 && x <= 52) || (x >= 55 && x <= 59) || x == 61 || x == 64 || (x >= 67 && x <= 68) || 
                   (x == 72))) || // first row
                   (y == 32 && (x == 23 || x == 26 || x == 28 || x == 31 || x == 33 || x == 38 || x == 43 || x == 50 || x == 53 ||
                   x == 57 || x == 64 || (x >= 61 && x <= 62) || x == 66 || x == 69 || x == 72)) || // second row
                   (y == 33 && ((x >= 23 && x <= 25) || (x >= 28 && x <= 30) || (x >= 33 && x <= 35) || (x >= 39 && x <= 40) ||
                   (x >= 44 && x <= 45) || (x >= 50 && x <= 52) || x == 57 || x == 61 || (x >= 63 && x <= 64) || x == 66 || x == 72)) || // third row
                   (y == 34 && (x == 23 || x == 28 || x == 30 || x == 33 || x == 41 || x == 46 || x == 50 || x == 53 || x == 57 ||
                   x == 61 || x == 64 || x == 66 || x == 69)) || // fourth row
                   (y == 35 && (x == 23 || x == 28 || x == 31 || (x >= 33 && x <= 36) || (x >= 38 && x <= 40) || (x >= 43 && x <= 45) ||
                   (x >= 50 && x <= 52) || x == 57 || x == 61 || x == 64 || (x >= 67 && x <= 68) || x == 72)); // fifth row
                   
    assign not_ready = ready || press; 
    
    assign waiting = (x >= 14 && x <= 15 && y >= 17 && y <= 26) || (x >= 22 && x <= 23 && y >= 17 && y <= 26) ||
                     (x >= 16 && x <= 17 && y >= 23 && y <= 24) || (x >= 18 && x <= 19 && y >= 21 && y <= 22) ||
                     (x >= 20 && x <= 21 && y >= 23 && y <= 24) || // letter W
                     (x >= 26 && x <= 27 && y >= 19 && y <= 26) || (x >= 32 && x <= 33 && y >= 19 && y <= 26) ||
                     (x >= 28 && x <= 31 && y >= 17 && y <= 18) || (x >= 28 && x <= 31 && y >= 21 && y <= 22) || // letter A
                     (x >= 36 && x <= 41 && y >= 17 && y <= 18) || (x >= 38 && x <= 39 && y >= 19 && y <= 24) ||
                     (x >= 36 && x <= 41 && y >= 25 && y <= 26) || // letter I
                     (x >= 44 && x <= 53 && y >= 17 && y <= 18) || (x >= 48 && x <= 49 && y >= 19 && y <= 26) || // letter T
                     (x >= 56 && x <= 61 && y >= 17 && y <= 18) || (x >= 58 && x <= 59 && y >= 19 && y <= 24) ||
                     (x >= 56 && x <= 61 && y >= 25 && y <= 26) || // letter I
                     (x >= 64 && x <= 65 && y >= 17 && y <= 26) || (x >= 66 && x <= 67 && y >= 19 && y <= 20) ||
                     (x >= 68 && x <= 69 && y >= 21 && y <= 22) || (x >= 70 && x <= 71 && y >= 17 && y <= 26) || // letter N
                     (x >= 74 && x <= 75 && y >= 19 && y <= 24) || (x >= 76 && x <= 79 && y >= 17 && y <= 18) ||
                     (x >= 76 && x <= 79 && y >= 25 && y <= 26) || (x >= 78 && x <= 81 && y >= 21 && y <= 22) ||
                     (x >= 80 && x <= 81 && y >= 23 && y <= 24); // letter G
                     
    assign for_p2 = (x >= 11 && x <= 12 && y >= 31 && y <= 40) || (x >= 13 && x <= 18 && y >= 31 && y <= 32) ||
                    (x >= 13 && x <= 16 && y >= 35 && y <= 36) || // letter F
                    (x >= 21 && x <= 22 && y >= 33 && y <= 38) || (x >= 23 && x <= 26 && y >= 31 && y <= 32) ||
                    (x >= 27 && x <= 28 && y >= 33 && y <= 38) || (x >= 23 && x <= 26 && y >= 39 && y <= 40) || // letter O
                    (x >= 31 && x <= 36 && y >= 31 && y <= 32) || (x >= 31 && x <= 32 && y >= 33 && y <= 40) ||
                    (x >= 33 && x <= 36 && y >= 35 && y <= 36) || (x >= 37 && x <= 38 && y >= 33 && y <= 34) ||
                    (x >= 35 && x <= 36 && y >= 37 && y <= 38) || (x >= 37 && x <= 38 && y >= 39 && y <= 40) || // letter R
                    (x >= 45 && x <= 46 && y >= 31 && y <= 40) || (x >= 47 && x <= 50 && y >= 31 && y <= 32) ||
                    (x >= 51 && x <= 52 && y >= 33 && y <= 34) || (x >= 47 && x <= 50 && y >= 35 && y <= 36) || // letter P
                    (x >= 55 && x <= 56 && y >= 33 && y <= 34) || (x >= 57 && x <= 60 && y >= 31 && y <= 32) ||
                    (x >= 61 && x <= 62 && y >= 33 && y <= 34) || (x >= 59 && x <= 60 && y >= 35 && y <= 36) ||
                    (x >= 57 && x <= 58 && y >= 37 && y <= 38) || (x >= 55 && x <= 62 && y >= 39 && y <= 40) || // num 2
                    (x >= 67 && x <= 68 && y >= 39 && y <= 40) || (x >= 75 && x <= 76 && y >= 39 && y <= 40) ||
                    (x >= 83 && x <= 84 && y >= 39 && y <= 40);
                    
    assign waiting_scr = waiting || for_p2;
    
    assign three = (x >= 37 && x <= 56 && y >= 7 && y <= 13) || (x >= 30 && x <= 36 && y >= 14 && y <= 20) ||
                   (x >= 57 && x <= 63 && y >= 14 && y <= 27) || (x >= 44 && x <= 56 && y >= 28 && y <= 34) ||
                   (x >= 57 && x <= 63 && y >= 35 && y <= 48) || (x >= 30 && x <= 36 && y >= 42 && y <= 48) ||
                   (x >= 37 && x <= 56 && y >= 49 && y <= 55);
                   
    assign three_edge = ((x >= 37 && x <= 56) && (y == 6 || y == 14 || y == 48 || y == 56)) ||
                        (x == 36 && ((y >= 7 && y <= 13) || (y >= 49 && y <= 55))) ||
                        (x == 57 && ((y >= 7 && y <= 13) || (y >= 49 && y <= 55))) ||
                        ((x == 29 || x == 37) && ((y >= 14 && y <= 20) || (y >= 42 && y <= 48))) ||
                        ((x == 56 || x == 64) && ((y >= 14 && y <= 27) || (y >= 35 && y <= 48))) ||
                        ((x >= 30 && x <= 36) && (y == 13 || y == 21 || y == 41 || y == 49)) ||
                        ((x >= 57 && x <= 63) && (y == 13 || y == 28 || y == 34 || y == 49)) ||
                        ((x >= 44 && x <= 55) && (y == 27 || y == 35)) ||
                        ((y >= 28 && y <= 34) && (x == 43 || x == 57));
                        
    assign two = (x >= 37 && x <= 56 && y >= 7 && y <= 13) || (x >= 30 && x <= 36 && y >= 14 && y <= 20) ||
                 (x >= 57 && x <= 63 && y >= 14 && y <= 27) || (x >= 44 && x <= 56 && y >= 28 && y <= 34) ||
                 (x >= 37 && x <= 43 && y >= 35 && y <= 41) || (x >= 30 && x <= 36 && y >= 42 && y <= 48) ||
                 (x >= 30 && x <= 63 && y >= 49 && y <= 55);
                 
    assign two_edge = ((x >= 37 && x <= 56) && (y == 6 || y == 14)) ||
                      ((x == 36 || x == 57) && (y >= 7 && y <= 13)) ||
                      (y == 13 && ((x >= 30 && x <= 36) || (x >= 57 && x <= 63))) ||
                      ((x == 29 || x == 37) && (y >= 14 && y <= 20)) ||
                      (y == 21 && x >= 30 && x <= 36) || ((x == 56 || x == 64) && (y >= 14 && y <= 27)) ||
                      (y == 28 && x >= 57 && x <= 63) || ((x >= 44 && x <= 56) && (y == 27 || y == 35)) ||
                      ((x == 43 || x == 57) && (y >= 28 && y <= 34)) || ((x >= 37 && x <= 43) && (y == 34 || y == 42)) ||
                      ((x == 36 || x == 44) && (y >= 35 && y <= 41)) || (y == 41 && x >= 30 && x <= 35) ||
                      (x == 37 && y >= 43 && y <= 48) || (x == 29 && y >= 42 && y <= 55) ||
                      (y == 48 && x >= 38 && x <= 63) || (y == 56 && x >= 30 && x <= 63) || (x == 64 && y >= 49 && y <= 55);

    assign one = (x >= 44 && x <= 50 && y >= 7 && y <= 48) || (x >= 37 && x <= 43 && y >= 14 && y <= 20) || (x >= 30 && x <= 63 && y >= 49 && y <= 55);
    
    assign one_edge = (y == 6 && x >= 44 && x <= 50) || (x == 51 && y >= 7 && y <= 47) || (x == 36 && y >= 14 && y <= 20) ||
                      (x == 43 && ((y >= 7 && y <= 13) || y >= 21 && y <= 47)) || ((x >= 37 && x <= 42) && (y == 13 || y == 21)) ||
                      (y == 48 && ((x >= 30 && x <= 43) || (x >= 51 && x <= 63))) || (y == 56 && x >= 30 && x <= 63) ||
                      ((x == 29 || x == 64) && (y >= 49 && y <= 55));

    always @ (posedge clk_1khz)
    begin
                
        count_down_state <= 0;
        if (USER_READY == 1 && OPP_READY == 1) begin
            count <= count == 3001 ? 0 : count + 1;

            if (count > 1000) count_down_state <= 1;
            if (count > 2000) count_down_state <= 2;
            if (count > 3000) count_down_state <= 3;
        end
        else count <= 0;
    end

    always @ (posedge clk_25Mhz)
    begin
        
        if (GAME_START == 0) begin
            
            if (USER_READY == 0) begin
                // not ready screen
                if (not_ready) begin
                    oled_screen <= 0;
                end
                else oled_screen <= 16'b11111_111111_11111;
            end
            else if (USER_READY == 1 && OPP_READY == 0) begin
                // wait screen
                if (waiting_scr) begin
                    oled_screen <= 0;
                end
                else oled_screen <= 16'b11111_111111_11111;
            end
            else if (USER_READY == 1 && OPP_READY == 1) begin
                case (count_down_state)
                    0 : begin
                        if (three) begin
                            oled_screen <= orange;
                        end
                        else if (three_edge) begin
                            oled_screen = 0;
                        end
                        else oled_screen <= 16'b11111_111111_11111;
                    end
                    1 : begin
                        if (two) begin
                            oled_screen <= yellow;
                        end
                        else if (two_edge) begin
                            oled_screen = 0;
                        end
                        else oled_screen <= 16'b11111_111111_11111;
                    end
                    2 : begin
                        if (one) begin
                            oled_screen <= green;
                        end
                        else if (one_edge) begin
                            oled_screen = 0;
                        end
                        else oled_screen <= 16'b11111_111111_11111;
                    end
                    3 : begin
                        GAME_START <= 1;
                    end
                endcase
                
            end
        end
        
        if (GAME_END == 1) begin
        
            if (USER_WIN) begin
                if (waiting) begin
                    oled_screen <= green;
                end
                else oled_screen <= 16'b11111_111111_11111;
            end
            else begin
                if (for_p2) begin
                    oled_screen <= yellow;
                end
                else oled_screen <= 16'b11111_111111_11111;
            end
            
            GAME_START <= ~NEW_GAME;
        end
        
    end

endmodule
