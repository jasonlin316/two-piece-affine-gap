/* FE Release Version: 3.4.22 */
/* lang compiler Version: 3.0.4 */
//
//       CONFIDENTIAL AND PROPRIETARY SOFTWARE OF ARM PHYSICAL IP, INC.
//      
//       Copyright (c) 1993 - 2020 ARM Physical IP, Inc.  All Rights Reserved.
//      
//       Use of this Software is subject to the terms and conditions of the
//       applicable license agreement with ARM Physical IP, Inc.
//       In addition, this Software is protected by patents, copyright law 
//       and international treaties.
//      
//       The copyright notice(s) in this Software does not indicate actual or
//       intended publication of this Software.
//
//      Verilog model for Synchronous Single-Port Ram
//
//       Instance Name:              sram_sp_hde
//       Words:                      256
//       Bits:                       80
//       Mux:                        8
//       Drive:                      6
//       Write Mask:                 Off
//       Write Thru:                 On
//       Extra Margin Adjustment:    On
//       Redundant Rows:             0
//       Redundant Columns:          0
//       Test Muxes                  On
//       Power Gating:               Off
//       Retention:                  On
//       Pipeline:                   Off
//       Weak Bit Test:	        Off
//       Read Disturb Test:	        Off
//       
//       Creation Date:  Tue Jun 30 14:49:16 2020
//       Version: 	r11p2
//
//      Modeling Assumptions: This model supports full gate level simulation
//          including proper x-handling and timing check behavior.  Unit
//          delay timing is included in the model. Back-annotation of SDF
//          (v3.0 or v2.1) is supported.  SDF can be created utilyzing the delay
//          calculation views provided with this generator and supported
//          delay calculators.  All buses are modeled [MSB:LSB].  All 
//          ports are padded with Verilog primitives.
//
//      Modeling Limitations: None.
//
//      Known Bugs: None.
//
//      Known Work Arounds: N/A
//
`timescale 1 ns/1 ps
// If ARM_UD_MODEL is defined at Simulator Command Line, it Selects the Fast Functional Model
`ifdef ARM_UD_MODEL

// Following parameter Values can be overridden at Simulator Command Line.

// ARM_UD_DP Defines the delay through Data Paths, for Memory Models it represents BIST MUX output delays.
`ifdef ARM_UD_DP
`else
`define ARM_UD_DP #0.001
`endif
// ARM_UD_CP Defines the delay through Clock Path Cells, for Memory Models it is not used.
`ifdef ARM_UD_CP
`else
`define ARM_UD_CP
`endif
// ARM_UD_SEQ Defines the delay through the Memory, for Memory Models it is used for CLK->Q delays.
`ifdef ARM_UD_SEQ
`else
`define ARM_UD_SEQ #0.01
`endif

`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module sram_sp_hde (VDDCE, VDDPE, VSSE, CENY, WENY, AY, DY, Q, CLK, CEN, WEN, A, D,
    EMA, EMAW, EMAS, TEN, BEN, TCEN, TWEN, TA, TD, TQ, RET1N, STOV);
`else
module sram_sp_hde (CENY, WENY, AY, DY, Q, CLK, CEN, WEN, A, D, EMA, EMAW, EMAS, TEN,
    BEN, TCEN, TWEN, TA, TD, TQ, RET1N, STOV);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 80;
  parameter WORDS = 256;
  parameter MUX = 8;
  parameter MEM_WIDTH = 640; // redun block size 4, 320 on left, 320 on right
  parameter MEM_HEIGHT = 32;
  parameter WP_SIZE = 80 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENY;
  output  WENY;
  output [7:0] AY;
  output [79:0] DY;
  output [79:0] Q;
  input  CLK;
  input  CEN;
  input  WEN;
  input [7:0] A;
  input [79:0] D;
  input [2:0] EMA;
  input [1:0] EMAW;
  input  EMAS;
  input  TEN;
  input  BEN;
  input  TCEN;
  input  TWEN;
  input [7:0] TA;
  input [79:0] TD;
  input [79:0] TQ;
  input  RET1N;
  input  STOV;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

  integer row_address;
  integer mux_address;
  reg [639:0] mem [0:31];
  reg [639:0] row;
  reg LAST_CLK;
  reg [639:0] row_mask;
  reg [639:0] new_data;
  reg [639:0] data_out;
  reg [159:0] readLatch0;
  reg [159:0] shifted_readLatch0;
  reg  read_mux_sel0;
  reg [79:0] Q_int;
  reg [79:0] Q_int_delayed;
  reg [79:0] writeEnable;

  reg NOT_CEN, NOT_WEN, NOT_A7, NOT_A6, NOT_A5, NOT_A4, NOT_A3, NOT_A2, NOT_A1, NOT_A0;
  reg NOT_D79, NOT_D78, NOT_D77, NOT_D76, NOT_D75, NOT_D74, NOT_D73, NOT_D72, NOT_D71;
  reg NOT_D70, NOT_D69, NOT_D68, NOT_D67, NOT_D66, NOT_D65, NOT_D64, NOT_D63, NOT_D62;
  reg NOT_D61, NOT_D60, NOT_D59, NOT_D58, NOT_D57, NOT_D56, NOT_D55, NOT_D54, NOT_D53;
  reg NOT_D52, NOT_D51, NOT_D50, NOT_D49, NOT_D48, NOT_D47, NOT_D46, NOT_D45, NOT_D44;
  reg NOT_D43, NOT_D42, NOT_D41, NOT_D40, NOT_D39, NOT_D38, NOT_D37, NOT_D36, NOT_D35;
  reg NOT_D34, NOT_D33, NOT_D32, NOT_D31, NOT_D30, NOT_D29, NOT_D28, NOT_D27, NOT_D26;
  reg NOT_D25, NOT_D24, NOT_D23, NOT_D22, NOT_D21, NOT_D20, NOT_D19, NOT_D18, NOT_D17;
  reg NOT_D16, NOT_D15, NOT_D14, NOT_D13, NOT_D12, NOT_D11, NOT_D10, NOT_D9, NOT_D8;
  reg NOT_D7, NOT_D6, NOT_D5, NOT_D4, NOT_D3, NOT_D2, NOT_D1, NOT_D0, NOT_EMA2, NOT_EMA1;
  reg NOT_EMA0, NOT_EMAW1, NOT_EMAW0, NOT_EMAS, NOT_TEN, NOT_TCEN, NOT_TWEN, NOT_TA7;
  reg NOT_TA6, NOT_TA5, NOT_TA4, NOT_TA3, NOT_TA2, NOT_TA1, NOT_TA0, NOT_TD79, NOT_TD78;
  reg NOT_TD77, NOT_TD76, NOT_TD75, NOT_TD74, NOT_TD73, NOT_TD72, NOT_TD71, NOT_TD70;
  reg NOT_TD69, NOT_TD68, NOT_TD67, NOT_TD66, NOT_TD65, NOT_TD64, NOT_TD63, NOT_TD62;
  reg NOT_TD61, NOT_TD60, NOT_TD59, NOT_TD58, NOT_TD57, NOT_TD56, NOT_TD55, NOT_TD54;
  reg NOT_TD53, NOT_TD52, NOT_TD51, NOT_TD50, NOT_TD49, NOT_TD48, NOT_TD47, NOT_TD46;
  reg NOT_TD45, NOT_TD44, NOT_TD43, NOT_TD42, NOT_TD41, NOT_TD40, NOT_TD39, NOT_TD38;
  reg NOT_TD37, NOT_TD36, NOT_TD35, NOT_TD34, NOT_TD33, NOT_TD32, NOT_TD31, NOT_TD30;
  reg NOT_TD29, NOT_TD28, NOT_TD27, NOT_TD26, NOT_TD25, NOT_TD24, NOT_TD23, NOT_TD22;
  reg NOT_TD21, NOT_TD20, NOT_TD19, NOT_TD18, NOT_TD17, NOT_TD16, NOT_TD15, NOT_TD14;
  reg NOT_TD13, NOT_TD12, NOT_TD11, NOT_TD10, NOT_TD9, NOT_TD8, NOT_TD7, NOT_TD6, NOT_TD5;
  reg NOT_TD4, NOT_TD3, NOT_TD2, NOT_TD1, NOT_TD0, NOT_RET1N, NOT_STOV;
  reg NOT_CLK_PER, NOT_CLK_MINH, NOT_CLK_MINL;
  reg clk0_int;

  wire  CENY_;
  wire  WENY_;
  wire [7:0] AY_;
  wire [79:0] DY_;
  wire [79:0] Q_;
 wire  CLK_;
  wire  CEN_;
  reg  CEN_int;
  reg  CEN_p2;
  wire  WEN_;
  reg  WEN_int;
  wire [7:0] A_;
  reg [7:0] A_int;
  wire [79:0] D_;
  reg [79:0] D_int;
  wire [2:0] EMA_;
  reg [2:0] EMA_int;
  wire [1:0] EMAW_;
  reg [1:0] EMAW_int;
  wire  EMAS_;
  reg  EMAS_int;
  wire  TEN_;
  reg  TEN_int;
  wire  BEN_;
  reg  BEN_int;
  wire  TCEN_;
  reg  TCEN_int;
  reg  TCEN_p2;
  wire  TWEN_;
  reg  TWEN_int;
  wire [7:0] TA_;
  reg [7:0] TA_int;
  wire [79:0] TD_;
  reg [79:0] TD_int;
  wire [79:0] TQ_;
  reg [79:0] TQ_int;
  wire  RET1N_;
  reg  RET1N_int;
  wire  STOV_;
  reg  STOV_int;

  assign CENY = CENY_; 
  assign WENY = WENY_; 
  assign AY[0] = AY_[0]; 
  assign AY[1] = AY_[1]; 
  assign AY[2] = AY_[2]; 
  assign AY[3] = AY_[3]; 
  assign AY[4] = AY_[4]; 
  assign AY[5] = AY_[5]; 
  assign AY[6] = AY_[6]; 
  assign AY[7] = AY_[7]; 
  assign DY[0] = DY_[0]; 
  assign DY[1] = DY_[1]; 
  assign DY[2] = DY_[2]; 
  assign DY[3] = DY_[3]; 
  assign DY[4] = DY_[4]; 
  assign DY[5] = DY_[5]; 
  assign DY[6] = DY_[6]; 
  assign DY[7] = DY_[7]; 
  assign DY[8] = DY_[8]; 
  assign DY[9] = DY_[9]; 
  assign DY[10] = DY_[10]; 
  assign DY[11] = DY_[11]; 
  assign DY[12] = DY_[12]; 
  assign DY[13] = DY_[13]; 
  assign DY[14] = DY_[14]; 
  assign DY[15] = DY_[15]; 
  assign DY[16] = DY_[16]; 
  assign DY[17] = DY_[17]; 
  assign DY[18] = DY_[18]; 
  assign DY[19] = DY_[19]; 
  assign DY[20] = DY_[20]; 
  assign DY[21] = DY_[21]; 
  assign DY[22] = DY_[22]; 
  assign DY[23] = DY_[23]; 
  assign DY[24] = DY_[24]; 
  assign DY[25] = DY_[25]; 
  assign DY[26] = DY_[26]; 
  assign DY[27] = DY_[27]; 
  assign DY[28] = DY_[28]; 
  assign DY[29] = DY_[29]; 
  assign DY[30] = DY_[30]; 
  assign DY[31] = DY_[31]; 
  assign DY[32] = DY_[32]; 
  assign DY[33] = DY_[33]; 
  assign DY[34] = DY_[34]; 
  assign DY[35] = DY_[35]; 
  assign DY[36] = DY_[36]; 
  assign DY[37] = DY_[37]; 
  assign DY[38] = DY_[38]; 
  assign DY[39] = DY_[39]; 
  assign DY[40] = DY_[40]; 
  assign DY[41] = DY_[41]; 
  assign DY[42] = DY_[42]; 
  assign DY[43] = DY_[43]; 
  assign DY[44] = DY_[44]; 
  assign DY[45] = DY_[45]; 
  assign DY[46] = DY_[46]; 
  assign DY[47] = DY_[47]; 
  assign DY[48] = DY_[48]; 
  assign DY[49] = DY_[49]; 
  assign DY[50] = DY_[50]; 
  assign DY[51] = DY_[51]; 
  assign DY[52] = DY_[52]; 
  assign DY[53] = DY_[53]; 
  assign DY[54] = DY_[54]; 
  assign DY[55] = DY_[55]; 
  assign DY[56] = DY_[56]; 
  assign DY[57] = DY_[57]; 
  assign DY[58] = DY_[58]; 
  assign DY[59] = DY_[59]; 
  assign DY[60] = DY_[60]; 
  assign DY[61] = DY_[61]; 
  assign DY[62] = DY_[62]; 
  assign DY[63] = DY_[63]; 
  assign DY[64] = DY_[64]; 
  assign DY[65] = DY_[65]; 
  assign DY[66] = DY_[66]; 
  assign DY[67] = DY_[67]; 
  assign DY[68] = DY_[68]; 
  assign DY[69] = DY_[69]; 
  assign DY[70] = DY_[70]; 
  assign DY[71] = DY_[71]; 
  assign DY[72] = DY_[72]; 
  assign DY[73] = DY_[73]; 
  assign DY[74] = DY_[74]; 
  assign DY[75] = DY_[75]; 
  assign DY[76] = DY_[76]; 
  assign DY[77] = DY_[77]; 
  assign DY[78] = DY_[78]; 
  assign DY[79] = DY_[79]; 
  assign Q[0] = Q_[0]; 
  assign Q[1] = Q_[1]; 
  assign Q[2] = Q_[2]; 
  assign Q[3] = Q_[3]; 
  assign Q[4] = Q_[4]; 
  assign Q[5] = Q_[5]; 
  assign Q[6] = Q_[6]; 
  assign Q[7] = Q_[7]; 
  assign Q[8] = Q_[8]; 
  assign Q[9] = Q_[9]; 
  assign Q[10] = Q_[10]; 
  assign Q[11] = Q_[11]; 
  assign Q[12] = Q_[12]; 
  assign Q[13] = Q_[13]; 
  assign Q[14] = Q_[14]; 
  assign Q[15] = Q_[15]; 
  assign Q[16] = Q_[16]; 
  assign Q[17] = Q_[17]; 
  assign Q[18] = Q_[18]; 
  assign Q[19] = Q_[19]; 
  assign Q[20] = Q_[20]; 
  assign Q[21] = Q_[21]; 
  assign Q[22] = Q_[22]; 
  assign Q[23] = Q_[23]; 
  assign Q[24] = Q_[24]; 
  assign Q[25] = Q_[25]; 
  assign Q[26] = Q_[26]; 
  assign Q[27] = Q_[27]; 
  assign Q[28] = Q_[28]; 
  assign Q[29] = Q_[29]; 
  assign Q[30] = Q_[30]; 
  assign Q[31] = Q_[31]; 
  assign Q[32] = Q_[32]; 
  assign Q[33] = Q_[33]; 
  assign Q[34] = Q_[34]; 
  assign Q[35] = Q_[35]; 
  assign Q[36] = Q_[36]; 
  assign Q[37] = Q_[37]; 
  assign Q[38] = Q_[38]; 
  assign Q[39] = Q_[39]; 
  assign Q[40] = Q_[40]; 
  assign Q[41] = Q_[41]; 
  assign Q[42] = Q_[42]; 
  assign Q[43] = Q_[43]; 
  assign Q[44] = Q_[44]; 
  assign Q[45] = Q_[45]; 
  assign Q[46] = Q_[46]; 
  assign Q[47] = Q_[47]; 
  assign Q[48] = Q_[48]; 
  assign Q[49] = Q_[49]; 
  assign Q[50] = Q_[50]; 
  assign Q[51] = Q_[51]; 
  assign Q[52] = Q_[52]; 
  assign Q[53] = Q_[53]; 
  assign Q[54] = Q_[54]; 
  assign Q[55] = Q_[55]; 
  assign Q[56] = Q_[56]; 
  assign Q[57] = Q_[57]; 
  assign Q[58] = Q_[58]; 
  assign Q[59] = Q_[59]; 
  assign Q[60] = Q_[60]; 
  assign Q[61] = Q_[61]; 
  assign Q[62] = Q_[62]; 
  assign Q[63] = Q_[63]; 
  assign Q[64] = Q_[64]; 
  assign Q[65] = Q_[65]; 
  assign Q[66] = Q_[66]; 
  assign Q[67] = Q_[67]; 
  assign Q[68] = Q_[68]; 
  assign Q[69] = Q_[69]; 
  assign Q[70] = Q_[70]; 
  assign Q[71] = Q_[71]; 
  assign Q[72] = Q_[72]; 
  assign Q[73] = Q_[73]; 
  assign Q[74] = Q_[74]; 
  assign Q[75] = Q_[75]; 
  assign Q[76] = Q_[76]; 
  assign Q[77] = Q_[77]; 
  assign Q[78] = Q_[78]; 
  assign Q[79] = Q_[79]; 
  assign CLK_ = CLK;
  assign CEN_ = CEN;
  assign WEN_ = WEN;
  assign A_[0] = A[0];
  assign A_[1] = A[1];
  assign A_[2] = A[2];
  assign A_[3] = A[3];
  assign A_[4] = A[4];
  assign A_[5] = A[5];
  assign A_[6] = A[6];
  assign A_[7] = A[7];
  assign D_[0] = D[0];
  assign D_[1] = D[1];
  assign D_[2] = D[2];
  assign D_[3] = D[3];
  assign D_[4] = D[4];
  assign D_[5] = D[5];
  assign D_[6] = D[6];
  assign D_[7] = D[7];
  assign D_[8] = D[8];
  assign D_[9] = D[9];
  assign D_[10] = D[10];
  assign D_[11] = D[11];
  assign D_[12] = D[12];
  assign D_[13] = D[13];
  assign D_[14] = D[14];
  assign D_[15] = D[15];
  assign D_[16] = D[16];
  assign D_[17] = D[17];
  assign D_[18] = D[18];
  assign D_[19] = D[19];
  assign D_[20] = D[20];
  assign D_[21] = D[21];
  assign D_[22] = D[22];
  assign D_[23] = D[23];
  assign D_[24] = D[24];
  assign D_[25] = D[25];
  assign D_[26] = D[26];
  assign D_[27] = D[27];
  assign D_[28] = D[28];
  assign D_[29] = D[29];
  assign D_[30] = D[30];
  assign D_[31] = D[31];
  assign D_[32] = D[32];
  assign D_[33] = D[33];
  assign D_[34] = D[34];
  assign D_[35] = D[35];
  assign D_[36] = D[36];
  assign D_[37] = D[37];
  assign D_[38] = D[38];
  assign D_[39] = D[39];
  assign D_[40] = D[40];
  assign D_[41] = D[41];
  assign D_[42] = D[42];
  assign D_[43] = D[43];
  assign D_[44] = D[44];
  assign D_[45] = D[45];
  assign D_[46] = D[46];
  assign D_[47] = D[47];
  assign D_[48] = D[48];
  assign D_[49] = D[49];
  assign D_[50] = D[50];
  assign D_[51] = D[51];
  assign D_[52] = D[52];
  assign D_[53] = D[53];
  assign D_[54] = D[54];
  assign D_[55] = D[55];
  assign D_[56] = D[56];
  assign D_[57] = D[57];
  assign D_[58] = D[58];
  assign D_[59] = D[59];
  assign D_[60] = D[60];
  assign D_[61] = D[61];
  assign D_[62] = D[62];
  assign D_[63] = D[63];
  assign D_[64] = D[64];
  assign D_[65] = D[65];
  assign D_[66] = D[66];
  assign D_[67] = D[67];
  assign D_[68] = D[68];
  assign D_[69] = D[69];
  assign D_[70] = D[70];
  assign D_[71] = D[71];
  assign D_[72] = D[72];
  assign D_[73] = D[73];
  assign D_[74] = D[74];
  assign D_[75] = D[75];
  assign D_[76] = D[76];
  assign D_[77] = D[77];
  assign D_[78] = D[78];
  assign D_[79] = D[79];
  assign EMA_[0] = EMA[0];
  assign EMA_[1] = EMA[1];
  assign EMA_[2] = EMA[2];
  assign EMAW_[0] = EMAW[0];
  assign EMAW_[1] = EMAW[1];
  assign EMAS_ = EMAS;
  assign TEN_ = TEN;
  assign BEN_ = BEN;
  assign TCEN_ = TCEN;
  assign TWEN_ = TWEN;
  assign TA_[0] = TA[0];
  assign TA_[1] = TA[1];
  assign TA_[2] = TA[2];
  assign TA_[3] = TA[3];
  assign TA_[4] = TA[4];
  assign TA_[5] = TA[5];
  assign TA_[6] = TA[6];
  assign TA_[7] = TA[7];
  assign TD_[0] = TD[0];
  assign TD_[1] = TD[1];
  assign TD_[2] = TD[2];
  assign TD_[3] = TD[3];
  assign TD_[4] = TD[4];
  assign TD_[5] = TD[5];
  assign TD_[6] = TD[6];
  assign TD_[7] = TD[7];
  assign TD_[8] = TD[8];
  assign TD_[9] = TD[9];
  assign TD_[10] = TD[10];
  assign TD_[11] = TD[11];
  assign TD_[12] = TD[12];
  assign TD_[13] = TD[13];
  assign TD_[14] = TD[14];
  assign TD_[15] = TD[15];
  assign TD_[16] = TD[16];
  assign TD_[17] = TD[17];
  assign TD_[18] = TD[18];
  assign TD_[19] = TD[19];
  assign TD_[20] = TD[20];
  assign TD_[21] = TD[21];
  assign TD_[22] = TD[22];
  assign TD_[23] = TD[23];
  assign TD_[24] = TD[24];
  assign TD_[25] = TD[25];
  assign TD_[26] = TD[26];
  assign TD_[27] = TD[27];
  assign TD_[28] = TD[28];
  assign TD_[29] = TD[29];
  assign TD_[30] = TD[30];
  assign TD_[31] = TD[31];
  assign TD_[32] = TD[32];
  assign TD_[33] = TD[33];
  assign TD_[34] = TD[34];
  assign TD_[35] = TD[35];
  assign TD_[36] = TD[36];
  assign TD_[37] = TD[37];
  assign TD_[38] = TD[38];
  assign TD_[39] = TD[39];
  assign TD_[40] = TD[40];
  assign TD_[41] = TD[41];
  assign TD_[42] = TD[42];
  assign TD_[43] = TD[43];
  assign TD_[44] = TD[44];
  assign TD_[45] = TD[45];
  assign TD_[46] = TD[46];
  assign TD_[47] = TD[47];
  assign TD_[48] = TD[48];
  assign TD_[49] = TD[49];
  assign TD_[50] = TD[50];
  assign TD_[51] = TD[51];
  assign TD_[52] = TD[52];
  assign TD_[53] = TD[53];
  assign TD_[54] = TD[54];
  assign TD_[55] = TD[55];
  assign TD_[56] = TD[56];
  assign TD_[57] = TD[57];
  assign TD_[58] = TD[58];
  assign TD_[59] = TD[59];
  assign TD_[60] = TD[60];
  assign TD_[61] = TD[61];
  assign TD_[62] = TD[62];
  assign TD_[63] = TD[63];
  assign TD_[64] = TD[64];
  assign TD_[65] = TD[65];
  assign TD_[66] = TD[66];
  assign TD_[67] = TD[67];
  assign TD_[68] = TD[68];
  assign TD_[69] = TD[69];
  assign TD_[70] = TD[70];
  assign TD_[71] = TD[71];
  assign TD_[72] = TD[72];
  assign TD_[73] = TD[73];
  assign TD_[74] = TD[74];
  assign TD_[75] = TD[75];
  assign TD_[76] = TD[76];
  assign TD_[77] = TD[77];
  assign TD_[78] = TD[78];
  assign TD_[79] = TD[79];
  assign TQ_[0] = TQ[0];
  assign TQ_[1] = TQ[1];
  assign TQ_[2] = TQ[2];
  assign TQ_[3] = TQ[3];
  assign TQ_[4] = TQ[4];
  assign TQ_[5] = TQ[5];
  assign TQ_[6] = TQ[6];
  assign TQ_[7] = TQ[7];
  assign TQ_[8] = TQ[8];
  assign TQ_[9] = TQ[9];
  assign TQ_[10] = TQ[10];
  assign TQ_[11] = TQ[11];
  assign TQ_[12] = TQ[12];
  assign TQ_[13] = TQ[13];
  assign TQ_[14] = TQ[14];
  assign TQ_[15] = TQ[15];
  assign TQ_[16] = TQ[16];
  assign TQ_[17] = TQ[17];
  assign TQ_[18] = TQ[18];
  assign TQ_[19] = TQ[19];
  assign TQ_[20] = TQ[20];
  assign TQ_[21] = TQ[21];
  assign TQ_[22] = TQ[22];
  assign TQ_[23] = TQ[23];
  assign TQ_[24] = TQ[24];
  assign TQ_[25] = TQ[25];
  assign TQ_[26] = TQ[26];
  assign TQ_[27] = TQ[27];
  assign TQ_[28] = TQ[28];
  assign TQ_[29] = TQ[29];
  assign TQ_[30] = TQ[30];
  assign TQ_[31] = TQ[31];
  assign TQ_[32] = TQ[32];
  assign TQ_[33] = TQ[33];
  assign TQ_[34] = TQ[34];
  assign TQ_[35] = TQ[35];
  assign TQ_[36] = TQ[36];
  assign TQ_[37] = TQ[37];
  assign TQ_[38] = TQ[38];
  assign TQ_[39] = TQ[39];
  assign TQ_[40] = TQ[40];
  assign TQ_[41] = TQ[41];
  assign TQ_[42] = TQ[42];
  assign TQ_[43] = TQ[43];
  assign TQ_[44] = TQ[44];
  assign TQ_[45] = TQ[45];
  assign TQ_[46] = TQ[46];
  assign TQ_[47] = TQ[47];
  assign TQ_[48] = TQ[48];
  assign TQ_[49] = TQ[49];
  assign TQ_[50] = TQ[50];
  assign TQ_[51] = TQ[51];
  assign TQ_[52] = TQ[52];
  assign TQ_[53] = TQ[53];
  assign TQ_[54] = TQ[54];
  assign TQ_[55] = TQ[55];
  assign TQ_[56] = TQ[56];
  assign TQ_[57] = TQ[57];
  assign TQ_[58] = TQ[58];
  assign TQ_[59] = TQ[59];
  assign TQ_[60] = TQ[60];
  assign TQ_[61] = TQ[61];
  assign TQ_[62] = TQ[62];
  assign TQ_[63] = TQ[63];
  assign TQ_[64] = TQ[64];
  assign TQ_[65] = TQ[65];
  assign TQ_[66] = TQ[66];
  assign TQ_[67] = TQ[67];
  assign TQ_[68] = TQ[68];
  assign TQ_[69] = TQ[69];
  assign TQ_[70] = TQ[70];
  assign TQ_[71] = TQ[71];
  assign TQ_[72] = TQ[72];
  assign TQ_[73] = TQ[73];
  assign TQ_[74] = TQ[74];
  assign TQ_[75] = TQ[75];
  assign TQ_[76] = TQ[76];
  assign TQ_[77] = TQ[77];
  assign TQ_[78] = TQ[78];
  assign TQ_[79] = TQ[79];
  assign RET1N_ = RET1N;
  assign STOV_ = STOV;

  assign `ARM_UD_DP CENY_ = RET1N_ ? (TEN_ ? CEN_ : TCEN_) : 1'bx;
  assign `ARM_UD_DP WENY_ = RET1N_ ? (TEN_ ? WEN_ : TWEN_) : 1'bx;
  assign `ARM_UD_DP AY_ = RET1N_ ? (TEN_ ? A_ : TA_) : {8{1'bx}};
  assign `ARM_UD_DP DY_ = RET1N_ ? (TEN_ ? D_ : TD_) : {80{1'bx}};
  assign `ARM_UD_SEQ Q_ = RET1N_ ? (BEN_ ? ((STOV_ ? (Q_int_delayed) : (Q_int))) : TQ_) : {80{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
`endif

  task failedWrite;
  input port_f;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitval;
    begin
      isBitX = ( bitval===1'bx || bitval==1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [7:0] Atemp;
  begin
	$readmemb(filename, memld);
     if (CEN_ === 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 3'b111);
      row_address = (Atemp >> 3);
      row = mem[row_address];
        writeEnable = {80{1'b1}};
        row_mask =  ( {7'b0000000, writeEnable[79], 7'b0000000, writeEnable[78], 7'b0000000, writeEnable[77],
          7'b0000000, writeEnable[76], 7'b0000000, writeEnable[75], 7'b0000000, writeEnable[74],
          7'b0000000, writeEnable[73], 7'b0000000, writeEnable[72], 7'b0000000, writeEnable[71],
          7'b0000000, writeEnable[70], 7'b0000000, writeEnable[69], 7'b0000000, writeEnable[68],
          7'b0000000, writeEnable[67], 7'b0000000, writeEnable[66], 7'b0000000, writeEnable[65],
          7'b0000000, writeEnable[64], 7'b0000000, writeEnable[63], 7'b0000000, writeEnable[62],
          7'b0000000, writeEnable[61], 7'b0000000, writeEnable[60], 7'b0000000, writeEnable[59],
          7'b0000000, writeEnable[58], 7'b0000000, writeEnable[57], 7'b0000000, writeEnable[56],
          7'b0000000, writeEnable[55], 7'b0000000, writeEnable[54], 7'b0000000, writeEnable[53],
          7'b0000000, writeEnable[52], 7'b0000000, writeEnable[51], 7'b0000000, writeEnable[50],
          7'b0000000, writeEnable[49], 7'b0000000, writeEnable[48], 7'b0000000, writeEnable[47],
          7'b0000000, writeEnable[46], 7'b0000000, writeEnable[45], 7'b0000000, writeEnable[44],
          7'b0000000, writeEnable[43], 7'b0000000, writeEnable[42], 7'b0000000, writeEnable[41],
          7'b0000000, writeEnable[40], 7'b0000000, writeEnable[39], 7'b0000000, writeEnable[38],
          7'b0000000, writeEnable[37], 7'b0000000, writeEnable[36], 7'b0000000, writeEnable[35],
          7'b0000000, writeEnable[34], 7'b0000000, writeEnable[33], 7'b0000000, writeEnable[32],
          7'b0000000, writeEnable[31], 7'b0000000, writeEnable[30], 7'b0000000, writeEnable[29],
          7'b0000000, writeEnable[28], 7'b0000000, writeEnable[27], 7'b0000000, writeEnable[26],
          7'b0000000, writeEnable[25], 7'b0000000, writeEnable[24], 7'b0000000, writeEnable[23],
          7'b0000000, writeEnable[22], 7'b0000000, writeEnable[21], 7'b0000000, writeEnable[20],
          7'b0000000, writeEnable[19], 7'b0000000, writeEnable[18], 7'b0000000, writeEnable[17],
          7'b0000000, writeEnable[16], 7'b0000000, writeEnable[15], 7'b0000000, writeEnable[14],
          7'b0000000, writeEnable[13], 7'b0000000, writeEnable[12], 7'b0000000, writeEnable[11],
          7'b0000000, writeEnable[10], 7'b0000000, writeEnable[9], 7'b0000000, writeEnable[8],
          7'b0000000, writeEnable[7], 7'b0000000, writeEnable[6], 7'b0000000, writeEnable[5],
          7'b0000000, writeEnable[4], 7'b0000000, writeEnable[3], 7'b0000000, writeEnable[2],
          7'b0000000, writeEnable[1], 7'b0000000, writeEnable[0]} << mux_address);
        new_data =  ( {7'b0000000, wordtemp[79], 7'b0000000, wordtemp[78], 7'b0000000, wordtemp[77],
          7'b0000000, wordtemp[76], 7'b0000000, wordtemp[75], 7'b0000000, wordtemp[74],
          7'b0000000, wordtemp[73], 7'b0000000, wordtemp[72], 7'b0000000, wordtemp[71],
          7'b0000000, wordtemp[70], 7'b0000000, wordtemp[69], 7'b0000000, wordtemp[68],
          7'b0000000, wordtemp[67], 7'b0000000, wordtemp[66], 7'b0000000, wordtemp[65],
          7'b0000000, wordtemp[64], 7'b0000000, wordtemp[63], 7'b0000000, wordtemp[62],
          7'b0000000, wordtemp[61], 7'b0000000, wordtemp[60], 7'b0000000, wordtemp[59],
          7'b0000000, wordtemp[58], 7'b0000000, wordtemp[57], 7'b0000000, wordtemp[56],
          7'b0000000, wordtemp[55], 7'b0000000, wordtemp[54], 7'b0000000, wordtemp[53],
          7'b0000000, wordtemp[52], 7'b0000000, wordtemp[51], 7'b0000000, wordtemp[50],
          7'b0000000, wordtemp[49], 7'b0000000, wordtemp[48], 7'b0000000, wordtemp[47],
          7'b0000000, wordtemp[46], 7'b0000000, wordtemp[45], 7'b0000000, wordtemp[44],
          7'b0000000, wordtemp[43], 7'b0000000, wordtemp[42], 7'b0000000, wordtemp[41],
          7'b0000000, wordtemp[40], 7'b0000000, wordtemp[39], 7'b0000000, wordtemp[38],
          7'b0000000, wordtemp[37], 7'b0000000, wordtemp[36], 7'b0000000, wordtemp[35],
          7'b0000000, wordtemp[34], 7'b0000000, wordtemp[33], 7'b0000000, wordtemp[32],
          7'b0000000, wordtemp[31], 7'b0000000, wordtemp[30], 7'b0000000, wordtemp[29],
          7'b0000000, wordtemp[28], 7'b0000000, wordtemp[27], 7'b0000000, wordtemp[26],
          7'b0000000, wordtemp[25], 7'b0000000, wordtemp[24], 7'b0000000, wordtemp[23],
          7'b0000000, wordtemp[22], 7'b0000000, wordtemp[21], 7'b0000000, wordtemp[20],
          7'b0000000, wordtemp[19], 7'b0000000, wordtemp[18], 7'b0000000, wordtemp[17],
          7'b0000000, wordtemp[16], 7'b0000000, wordtemp[15], 7'b0000000, wordtemp[14],
          7'b0000000, wordtemp[13], 7'b0000000, wordtemp[12], 7'b0000000, wordtemp[11],
          7'b0000000, wordtemp[10], 7'b0000000, wordtemp[9], 7'b0000000, wordtemp[8],
          7'b0000000, wordtemp[7], 7'b0000000, wordtemp[6], 7'b0000000, wordtemp[5],
          7'b0000000, wordtemp[4], 7'b0000000, wordtemp[3], 7'b0000000, wordtemp[2],
          7'b0000000, wordtemp[1], 7'b0000000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
  end
  end
  endtask

task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [7:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
     if (CEN_ === 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 3'b111);
      row_address = (Atemp >> 3);
      row = mem[row_address];
        writeEnable = {80{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[636], data_out[632], data_out[628], data_out[624], data_out[620],
          data_out[616], data_out[612], data_out[608], data_out[604], data_out[600],
          data_out[596], data_out[592], data_out[588], data_out[584], data_out[580],
          data_out[576], data_out[572], data_out[568], data_out[564], data_out[560],
          data_out[556], data_out[552], data_out[548], data_out[544], data_out[540],
          data_out[536], data_out[532], data_out[528], data_out[524], data_out[520],
          data_out[516], data_out[512], data_out[508], data_out[504], data_out[500],
          data_out[496], data_out[492], data_out[488], data_out[484], data_out[480],
          data_out[476], data_out[472], data_out[468], data_out[464], data_out[460],
          data_out[456], data_out[452], data_out[448], data_out[444], data_out[440],
          data_out[436], data_out[432], data_out[428], data_out[424], data_out[420],
          data_out[416], data_out[412], data_out[408], data_out[404], data_out[400],
          data_out[396], data_out[392], data_out[388], data_out[384], data_out[380],
          data_out[376], data_out[372], data_out[368], data_out[364], data_out[360],
          data_out[356], data_out[352], data_out[348], data_out[344], data_out[340],
          data_out[336], data_out[332], data_out[328], data_out[324], data_out[320],
          data_out[316], data_out[312], data_out[308], data_out[304], data_out[300],
          data_out[296], data_out[292], data_out[288], data_out[284], data_out[280],
          data_out[276], data_out[272], data_out[268], data_out[264], data_out[260],
          data_out[256], data_out[252], data_out[248], data_out[244], data_out[240],
          data_out[236], data_out[232], data_out[228], data_out[224], data_out[220],
          data_out[216], data_out[212], data_out[208], data_out[204], data_out[200],
          data_out[196], data_out[192], data_out[188], data_out[184], data_out[180],
          data_out[176], data_out[172], data_out[168], data_out[164], data_out[160],
          data_out[156], data_out[152], data_out[148], data_out[144], data_out[140],
          data_out[136], data_out[132], data_out[128], data_out[124], data_out[120],
          data_out[116], data_out[112], data_out[108], data_out[104], data_out[100],
          data_out[96], data_out[92], data_out[88], data_out[84], data_out[80], data_out[76],
          data_out[72], data_out[68], data_out[64], data_out[60], data_out[56], data_out[52],
          data_out[48], data_out[44], data_out[40], data_out[36], data_out[32], data_out[28],
          data_out[24], data_out[20], data_out[16], data_out[12], data_out[8], data_out[4],
          data_out[0]};
        shifted_readLatch0 = readLatch0;
        Q_int = {shifted_readLatch0[158], shifted_readLatch0[156], shifted_readLatch0[154],
          shifted_readLatch0[152], shifted_readLatch0[150], shifted_readLatch0[148],
          shifted_readLatch0[146], shifted_readLatch0[144], shifted_readLatch0[142],
          shifted_readLatch0[140], shifted_readLatch0[138], shifted_readLatch0[136],
          shifted_readLatch0[134], shifted_readLatch0[132], shifted_readLatch0[130],
          shifted_readLatch0[128], shifted_readLatch0[126], shifted_readLatch0[124],
          shifted_readLatch0[122], shifted_readLatch0[120], shifted_readLatch0[118],
          shifted_readLatch0[116], shifted_readLatch0[114], shifted_readLatch0[112],
          shifted_readLatch0[110], shifted_readLatch0[108], shifted_readLatch0[106],
          shifted_readLatch0[104], shifted_readLatch0[102], shifted_readLatch0[100],
          shifted_readLatch0[98], shifted_readLatch0[96], shifted_readLatch0[94], shifted_readLatch0[92],
          shifted_readLatch0[90], shifted_readLatch0[88], shifted_readLatch0[86], shifted_readLatch0[84],
          shifted_readLatch0[82], shifted_readLatch0[80], shifted_readLatch0[78], shifted_readLatch0[76],
          shifted_readLatch0[74], shifted_readLatch0[72], shifted_readLatch0[70], shifted_readLatch0[68],
          shifted_readLatch0[66], shifted_readLatch0[64], shifted_readLatch0[62], shifted_readLatch0[60],
          shifted_readLatch0[58], shifted_readLatch0[56], shifted_readLatch0[54], shifted_readLatch0[52],
          shifted_readLatch0[50], shifted_readLatch0[48], shifted_readLatch0[46], shifted_readLatch0[44],
          shifted_readLatch0[42], shifted_readLatch0[40], shifted_readLatch0[38], shifted_readLatch0[36],
          shifted_readLatch0[34], shifted_readLatch0[32], shifted_readLatch0[30], shifted_readLatch0[28],
          shifted_readLatch0[26], shifted_readLatch0[24], shifted_readLatch0[22], shifted_readLatch0[20],
          shifted_readLatch0[18], shifted_readLatch0[16], shifted_readLatch0[14], shifted_readLatch0[12],
          shifted_readLatch0[10], shifted_readLatch0[8], shifted_readLatch0[6], shifted_readLatch0[4],
          shifted_readLatch0[2], shifted_readLatch0[0]};
   	$fdisplay(dump_file_desc, "%b", Q_int);
  end
  	end
//    $fclose(filename_dump);
  end
  endtask


  task readWrite;
  begin
    if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if (RET1N_int === 1'b0 && CEN_int === 1'b0) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{CEN_int, EMA_int, EMAW_int, EMAS_int, RET1N_int, (STOV_int && !CEN_int)} 
     === 1'bx) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if ((A_int >= WORDS) && (CEN_int === 1'b0)) begin
      Q_int = WEN_int !== 1'b1 ? D_int : {80{1'bx}};
      Q_int_delayed = WEN_int !== 1'b1 ? D_int : {80{1'bx}};
    end else if (CEN_int === 1'b0 && (^A_int) === 1'bx) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if (CEN_int === 1'b0) begin
      mux_address = (A_int & 3'b111);
      row_address = (A_int >> 3);
      if (row_address > 31)
        row = {640{1'bx}};
      else
        row = mem[row_address];
      writeEnable = ~{80{WEN_int}};
      if (WEN_int !== 1'b1) begin
        row_mask =  ( {7'b0000000, writeEnable[79], 7'b0000000, writeEnable[78], 7'b0000000, writeEnable[77],
          7'b0000000, writeEnable[76], 7'b0000000, writeEnable[75], 7'b0000000, writeEnable[74],
          7'b0000000, writeEnable[73], 7'b0000000, writeEnable[72], 7'b0000000, writeEnable[71],
          7'b0000000, writeEnable[70], 7'b0000000, writeEnable[69], 7'b0000000, writeEnable[68],
          7'b0000000, writeEnable[67], 7'b0000000, writeEnable[66], 7'b0000000, writeEnable[65],
          7'b0000000, writeEnable[64], 7'b0000000, writeEnable[63], 7'b0000000, writeEnable[62],
          7'b0000000, writeEnable[61], 7'b0000000, writeEnable[60], 7'b0000000, writeEnable[59],
          7'b0000000, writeEnable[58], 7'b0000000, writeEnable[57], 7'b0000000, writeEnable[56],
          7'b0000000, writeEnable[55], 7'b0000000, writeEnable[54], 7'b0000000, writeEnable[53],
          7'b0000000, writeEnable[52], 7'b0000000, writeEnable[51], 7'b0000000, writeEnable[50],
          7'b0000000, writeEnable[49], 7'b0000000, writeEnable[48], 7'b0000000, writeEnable[47],
          7'b0000000, writeEnable[46], 7'b0000000, writeEnable[45], 7'b0000000, writeEnable[44],
          7'b0000000, writeEnable[43], 7'b0000000, writeEnable[42], 7'b0000000, writeEnable[41],
          7'b0000000, writeEnable[40], 7'b0000000, writeEnable[39], 7'b0000000, writeEnable[38],
          7'b0000000, writeEnable[37], 7'b0000000, writeEnable[36], 7'b0000000, writeEnable[35],
          7'b0000000, writeEnable[34], 7'b0000000, writeEnable[33], 7'b0000000, writeEnable[32],
          7'b0000000, writeEnable[31], 7'b0000000, writeEnable[30], 7'b0000000, writeEnable[29],
          7'b0000000, writeEnable[28], 7'b0000000, writeEnable[27], 7'b0000000, writeEnable[26],
          7'b0000000, writeEnable[25], 7'b0000000, writeEnable[24], 7'b0000000, writeEnable[23],
          7'b0000000, writeEnable[22], 7'b0000000, writeEnable[21], 7'b0000000, writeEnable[20],
          7'b0000000, writeEnable[19], 7'b0000000, writeEnable[18], 7'b0000000, writeEnable[17],
          7'b0000000, writeEnable[16], 7'b0000000, writeEnable[15], 7'b0000000, writeEnable[14],
          7'b0000000, writeEnable[13], 7'b0000000, writeEnable[12], 7'b0000000, writeEnable[11],
          7'b0000000, writeEnable[10], 7'b0000000, writeEnable[9], 7'b0000000, writeEnable[8],
          7'b0000000, writeEnable[7], 7'b0000000, writeEnable[6], 7'b0000000, writeEnable[5],
          7'b0000000, writeEnable[4], 7'b0000000, writeEnable[3], 7'b0000000, writeEnable[2],
          7'b0000000, writeEnable[1], 7'b0000000, writeEnable[0]} << mux_address);
        new_data =  ( {7'b0000000, D_int[79], 7'b0000000, D_int[78], 7'b0000000, D_int[77],
          7'b0000000, D_int[76], 7'b0000000, D_int[75], 7'b0000000, D_int[74], 7'b0000000, D_int[73],
          7'b0000000, D_int[72], 7'b0000000, D_int[71], 7'b0000000, D_int[70], 7'b0000000, D_int[69],
          7'b0000000, D_int[68], 7'b0000000, D_int[67], 7'b0000000, D_int[66], 7'b0000000, D_int[65],
          7'b0000000, D_int[64], 7'b0000000, D_int[63], 7'b0000000, D_int[62], 7'b0000000, D_int[61],
          7'b0000000, D_int[60], 7'b0000000, D_int[59], 7'b0000000, D_int[58], 7'b0000000, D_int[57],
          7'b0000000, D_int[56], 7'b0000000, D_int[55], 7'b0000000, D_int[54], 7'b0000000, D_int[53],
          7'b0000000, D_int[52], 7'b0000000, D_int[51], 7'b0000000, D_int[50], 7'b0000000, D_int[49],
          7'b0000000, D_int[48], 7'b0000000, D_int[47], 7'b0000000, D_int[46], 7'b0000000, D_int[45],
          7'b0000000, D_int[44], 7'b0000000, D_int[43], 7'b0000000, D_int[42], 7'b0000000, D_int[41],
          7'b0000000, D_int[40], 7'b0000000, D_int[39], 7'b0000000, D_int[38], 7'b0000000, D_int[37],
          7'b0000000, D_int[36], 7'b0000000, D_int[35], 7'b0000000, D_int[34], 7'b0000000, D_int[33],
          7'b0000000, D_int[32], 7'b0000000, D_int[31], 7'b0000000, D_int[30], 7'b0000000, D_int[29],
          7'b0000000, D_int[28], 7'b0000000, D_int[27], 7'b0000000, D_int[26], 7'b0000000, D_int[25],
          7'b0000000, D_int[24], 7'b0000000, D_int[23], 7'b0000000, D_int[22], 7'b0000000, D_int[21],
          7'b0000000, D_int[20], 7'b0000000, D_int[19], 7'b0000000, D_int[18], 7'b0000000, D_int[17],
          7'b0000000, D_int[16], 7'b0000000, D_int[15], 7'b0000000, D_int[14], 7'b0000000, D_int[13],
          7'b0000000, D_int[12], 7'b0000000, D_int[11], 7'b0000000, D_int[10], 7'b0000000, D_int[9],
          7'b0000000, D_int[8], 7'b0000000, D_int[7], 7'b0000000, D_int[6], 7'b0000000, D_int[5],
          7'b0000000, D_int[4], 7'b0000000, D_int[3], 7'b0000000, D_int[2], 7'b0000000, D_int[1],
          7'b0000000, D_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[636], data_out[632], data_out[628], data_out[624], data_out[620],
          data_out[616], data_out[612], data_out[608], data_out[604], data_out[600],
          data_out[596], data_out[592], data_out[588], data_out[584], data_out[580],
          data_out[576], data_out[572], data_out[568], data_out[564], data_out[560],
          data_out[556], data_out[552], data_out[548], data_out[544], data_out[540],
          data_out[536], data_out[532], data_out[528], data_out[524], data_out[520],
          data_out[516], data_out[512], data_out[508], data_out[504], data_out[500],
          data_out[496], data_out[492], data_out[488], data_out[484], data_out[480],
          data_out[476], data_out[472], data_out[468], data_out[464], data_out[460],
          data_out[456], data_out[452], data_out[448], data_out[444], data_out[440],
          data_out[436], data_out[432], data_out[428], data_out[424], data_out[420],
          data_out[416], data_out[412], data_out[408], data_out[404], data_out[400],
          data_out[396], data_out[392], data_out[388], data_out[384], data_out[380],
          data_out[376], data_out[372], data_out[368], data_out[364], data_out[360],
          data_out[356], data_out[352], data_out[348], data_out[344], data_out[340],
          data_out[336], data_out[332], data_out[328], data_out[324], data_out[320],
          data_out[316], data_out[312], data_out[308], data_out[304], data_out[300],
          data_out[296], data_out[292], data_out[288], data_out[284], data_out[280],
          data_out[276], data_out[272], data_out[268], data_out[264], data_out[260],
          data_out[256], data_out[252], data_out[248], data_out[244], data_out[240],
          data_out[236], data_out[232], data_out[228], data_out[224], data_out[220],
          data_out[216], data_out[212], data_out[208], data_out[204], data_out[200],
          data_out[196], data_out[192], data_out[188], data_out[184], data_out[180],
          data_out[176], data_out[172], data_out[168], data_out[164], data_out[160],
          data_out[156], data_out[152], data_out[148], data_out[144], data_out[140],
          data_out[136], data_out[132], data_out[128], data_out[124], data_out[120],
          data_out[116], data_out[112], data_out[108], data_out[104], data_out[100],
          data_out[96], data_out[92], data_out[88], data_out[84], data_out[80], data_out[76],
          data_out[72], data_out[68], data_out[64], data_out[60], data_out[56], data_out[52],
          data_out[48], data_out[44], data_out[40], data_out[36], data_out[32], data_out[28],
          data_out[24], data_out[20], data_out[16], data_out[12], data_out[8], data_out[4],
          data_out[0]};
      end
      if (WEN_int !== 1'b1) begin
        Q_int = D_int;
        Q_int_delayed = D_int;
      end else begin
        shifted_readLatch0 = (readLatch0 >> A_int[2]);
        Q_int = {shifted_readLatch0[158], shifted_readLatch0[156], shifted_readLatch0[154],
          shifted_readLatch0[152], shifted_readLatch0[150], shifted_readLatch0[148],
          shifted_readLatch0[146], shifted_readLatch0[144], shifted_readLatch0[142],
          shifted_readLatch0[140], shifted_readLatch0[138], shifted_readLatch0[136],
          shifted_readLatch0[134], shifted_readLatch0[132], shifted_readLatch0[130],
          shifted_readLatch0[128], shifted_readLatch0[126], shifted_readLatch0[124],
          shifted_readLatch0[122], shifted_readLatch0[120], shifted_readLatch0[118],
          shifted_readLatch0[116], shifted_readLatch0[114], shifted_readLatch0[112],
          shifted_readLatch0[110], shifted_readLatch0[108], shifted_readLatch0[106],
          shifted_readLatch0[104], shifted_readLatch0[102], shifted_readLatch0[100],
          shifted_readLatch0[98], shifted_readLatch0[96], shifted_readLatch0[94], shifted_readLatch0[92],
          shifted_readLatch0[90], shifted_readLatch0[88], shifted_readLatch0[86], shifted_readLatch0[84],
          shifted_readLatch0[82], shifted_readLatch0[80], shifted_readLatch0[78], shifted_readLatch0[76],
          shifted_readLatch0[74], shifted_readLatch0[72], shifted_readLatch0[70], shifted_readLatch0[68],
          shifted_readLatch0[66], shifted_readLatch0[64], shifted_readLatch0[62], shifted_readLatch0[60],
          shifted_readLatch0[58], shifted_readLatch0[56], shifted_readLatch0[54], shifted_readLatch0[52],
          shifted_readLatch0[50], shifted_readLatch0[48], shifted_readLatch0[46], shifted_readLatch0[44],
          shifted_readLatch0[42], shifted_readLatch0[40], shifted_readLatch0[38], shifted_readLatch0[36],
          shifted_readLatch0[34], shifted_readLatch0[32], shifted_readLatch0[30], shifted_readLatch0[28],
          shifted_readLatch0[26], shifted_readLatch0[24], shifted_readLatch0[22], shifted_readLatch0[20],
          shifted_readLatch0[18], shifted_readLatch0[16], shifted_readLatch0[14], shifted_readLatch0[12],
          shifted_readLatch0[10], shifted_readLatch0[8], shifted_readLatch0[6], shifted_readLatch0[4],
          shifted_readLatch0[2], shifted_readLatch0[0]};
      end
    end
  end
  endtask
  always @ (CEN_ or TCEN_ or TEN_ or CLK_) begin
  	if(CLK_ == 1'b0) begin
  		CEN_p2 = CEN_;
  		TCEN_p2 = TCEN_;
  	end
  end

  always @ RET1N_ begin
    if (CLK_ == 1'b1) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CEN_p2 === 1'b0 || TCEN_p2 === 1'b0) ) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CEN_p2 === 1'b0 || TCEN_p2 === 1'b0) ) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end
    if (RET1N_ == 1'b0) begin
      Q_int = {80{1'bx}};
      Q_int_delayed = {80{1'bx}};
      CEN_int = 1'bx;
      WEN_int = 1'bx;
      A_int = {8{1'bx}};
      D_int = {80{1'bx}};
      EMA_int = {3{1'bx}};
      EMAW_int = {2{1'bx}};
      EMAS_int = 1'bx;
      TEN_int = 1'bx;
      BEN_int = 1'bx;
      TCEN_int = 1'bx;
      TWEN_int = 1'bx;
      TA_int = {8{1'bx}};
      TD_int = {80{1'bx}};
      TQ_int = {80{1'bx}};
      RET1N_int = 1'bx;
      STOV_int = 1'bx;
    end else begin
      Q_int = {80{1'bx}};
      Q_int_delayed = {80{1'bx}};
      CEN_int = 1'bx;
      WEN_int = 1'bx;
      A_int = {8{1'bx}};
      D_int = {80{1'bx}};
      EMA_int = {3{1'bx}};
      EMAW_int = {2{1'bx}};
      EMAS_int = 1'bx;
      TEN_int = 1'bx;
      BEN_int = 1'bx;
      TCEN_int = 1'bx;
      TWEN_int = 1'bx;
      TA_int = {8{1'bx}};
      TD_int = {80{1'bx}};
      TQ_int = {80{1'bx}};
      RET1N_int = 1'bx;
      STOV_int = 1'bx;
    end
    RET1N_int = RET1N_;
  end


  always @ CLK_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("ERROR: Illegal value for VDDCE %b", VDDCE);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("ERROR: Illegal value for VDDPE %b", VDDPE);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("ERROR: Illegal value for VSSE %b", VSSE);
`endif
  if (RET1N_ == 1'b0) begin
      // no cycle in retention mode
  end else begin
    if ((CLK_ === 1'bx || CLK_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if (CLK_ === 1'b1 && LAST_CLK === 1'b0) begin
      CEN_int = TEN_ ? CEN_ : TCEN_;
      EMA_int = EMA_;
      EMAW_int = EMAW_;
      EMAS_int = EMAS_;
      TEN_int = TEN_;
      BEN_int = BEN_;
      TWEN_int = TWEN_;
      TQ_int = TQ_;
      RET1N_int = RET1N_;
      STOV_int = STOV_;
      if (CEN_int != 1'b1) begin
        WEN_int = TEN_ ? WEN_ : TWEN_;
        A_int = TEN_ ? A_ : TA_;
        D_int = TEN_ ? D_ : TD_;
        TCEN_int = TCEN_;
        TA_int = TA_;
        TD_int = TD_;
        if (WEN_int === 1'b1)
          read_mux_sel0 = (TEN_ ? A_[2] : TA_[2] );
      end
      clk0_int = 1'b0;
      if (CEN_int === 1'b0 && WEN_int === 1'b1) 
         Q_int_delayed = {80{1'bx}};
    readWrite;
    end else if (CLK_ === 1'b0 && LAST_CLK === 1'b1) begin
      Q_int_delayed = Q_int;
    end
    LAST_CLK = CLK_;
  end
  end

endmodule
`endcelldefine
`else
`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module sram_sp_hde (VDDCE, VDDPE, VSSE, CENY, WENY, AY, DY, Q, CLK, CEN, WEN, A, D,
    EMA, EMAW, EMAS, TEN, BEN, TCEN, TWEN, TA, TD, TQ, RET1N, STOV);
`else
module sram_sp_hde (CENY, WENY, AY, DY, Q, CLK, CEN, WEN, A, D, EMA, EMAW, EMAS, TEN,
    BEN, TCEN, TWEN, TA, TD, TQ, RET1N, STOV);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 80;
  parameter WORDS = 256;
  parameter MUX = 8;
  parameter MEM_WIDTH = 640; // redun block size 4, 320 on left, 320 on right
  parameter MEM_HEIGHT = 32;
  parameter WP_SIZE = 80 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENY;
  output  WENY;
  output [7:0] AY;
  output [79:0] DY;
  output [79:0] Q;
  input  CLK;
  input  CEN;
  input  WEN;
  input [7:0] A;
  input [79:0] D;
  input [2:0] EMA;
  input [1:0] EMAW;
  input  EMAS;
  input  TEN;
  input  BEN;
  input  TCEN;
  input  TWEN;
  input [7:0] TA;
  input [79:0] TD;
  input [79:0] TQ;
  input  RET1N;
  input  STOV;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

  integer row_address;
  integer mux_address;
  reg [639:0] mem [0:31];
  reg [639:0] row;
  reg LAST_CLK;
  reg [639:0] row_mask;
  reg [639:0] new_data;
  reg [639:0] data_out;
  reg [159:0] readLatch0;
  reg [159:0] shifted_readLatch0;
  reg  read_mux_sel0;
  reg [79:0] Q_int;
  reg [79:0] Q_int_delayed;
  reg [79:0] writeEnable;

  reg NOT_CEN, NOT_WEN, NOT_A7, NOT_A6, NOT_A5, NOT_A4, NOT_A3, NOT_A2, NOT_A1, NOT_A0;
  reg NOT_D79, NOT_D78, NOT_D77, NOT_D76, NOT_D75, NOT_D74, NOT_D73, NOT_D72, NOT_D71;
  reg NOT_D70, NOT_D69, NOT_D68, NOT_D67, NOT_D66, NOT_D65, NOT_D64, NOT_D63, NOT_D62;
  reg NOT_D61, NOT_D60, NOT_D59, NOT_D58, NOT_D57, NOT_D56, NOT_D55, NOT_D54, NOT_D53;
  reg NOT_D52, NOT_D51, NOT_D50, NOT_D49, NOT_D48, NOT_D47, NOT_D46, NOT_D45, NOT_D44;
  reg NOT_D43, NOT_D42, NOT_D41, NOT_D40, NOT_D39, NOT_D38, NOT_D37, NOT_D36, NOT_D35;
  reg NOT_D34, NOT_D33, NOT_D32, NOT_D31, NOT_D30, NOT_D29, NOT_D28, NOT_D27, NOT_D26;
  reg NOT_D25, NOT_D24, NOT_D23, NOT_D22, NOT_D21, NOT_D20, NOT_D19, NOT_D18, NOT_D17;
  reg NOT_D16, NOT_D15, NOT_D14, NOT_D13, NOT_D12, NOT_D11, NOT_D10, NOT_D9, NOT_D8;
  reg NOT_D7, NOT_D6, NOT_D5, NOT_D4, NOT_D3, NOT_D2, NOT_D1, NOT_D0, NOT_EMA2, NOT_EMA1;
  reg NOT_EMA0, NOT_EMAW1, NOT_EMAW0, NOT_EMAS, NOT_TEN, NOT_TCEN, NOT_TWEN, NOT_TA7;
  reg NOT_TA6, NOT_TA5, NOT_TA4, NOT_TA3, NOT_TA2, NOT_TA1, NOT_TA0, NOT_TD79, NOT_TD78;
  reg NOT_TD77, NOT_TD76, NOT_TD75, NOT_TD74, NOT_TD73, NOT_TD72, NOT_TD71, NOT_TD70;
  reg NOT_TD69, NOT_TD68, NOT_TD67, NOT_TD66, NOT_TD65, NOT_TD64, NOT_TD63, NOT_TD62;
  reg NOT_TD61, NOT_TD60, NOT_TD59, NOT_TD58, NOT_TD57, NOT_TD56, NOT_TD55, NOT_TD54;
  reg NOT_TD53, NOT_TD52, NOT_TD51, NOT_TD50, NOT_TD49, NOT_TD48, NOT_TD47, NOT_TD46;
  reg NOT_TD45, NOT_TD44, NOT_TD43, NOT_TD42, NOT_TD41, NOT_TD40, NOT_TD39, NOT_TD38;
  reg NOT_TD37, NOT_TD36, NOT_TD35, NOT_TD34, NOT_TD33, NOT_TD32, NOT_TD31, NOT_TD30;
  reg NOT_TD29, NOT_TD28, NOT_TD27, NOT_TD26, NOT_TD25, NOT_TD24, NOT_TD23, NOT_TD22;
  reg NOT_TD21, NOT_TD20, NOT_TD19, NOT_TD18, NOT_TD17, NOT_TD16, NOT_TD15, NOT_TD14;
  reg NOT_TD13, NOT_TD12, NOT_TD11, NOT_TD10, NOT_TD9, NOT_TD8, NOT_TD7, NOT_TD6, NOT_TD5;
  reg NOT_TD4, NOT_TD3, NOT_TD2, NOT_TD1, NOT_TD0, NOT_RET1N, NOT_STOV;
  reg NOT_CLK_PER, NOT_CLK_MINH, NOT_CLK_MINL;
  reg clk0_int;

  wire  CENY_;
  wire  WENY_;
  wire [7:0] AY_;
  wire [79:0] DY_;
  wire [79:0] Q_;
 wire  CLK_;
  wire  CEN_;
  reg  CEN_int;
  reg  CEN_p2;
  wire  WEN_;
  reg  WEN_int;
  wire [7:0] A_;
  reg [7:0] A_int;
  wire [79:0] D_;
  reg [79:0] D_int;
  wire [2:0] EMA_;
  reg [2:0] EMA_int;
  wire [1:0] EMAW_;
  reg [1:0] EMAW_int;
  wire  EMAS_;
  reg  EMAS_int;
  wire  TEN_;
  reg  TEN_int;
  wire  BEN_;
  reg  BEN_int;
  wire  TCEN_;
  reg  TCEN_int;
  reg  TCEN_p2;
  wire  TWEN_;
  reg  TWEN_int;
  wire [7:0] TA_;
  reg [7:0] TA_int;
  wire [79:0] TD_;
  reg [79:0] TD_int;
  wire [79:0] TQ_;
  reg [79:0] TQ_int;
  wire  RET1N_;
  reg  RET1N_int;
  wire  STOV_;
  reg  STOV_int;

  buf B0(CENY, CENY_);
  buf B1(WENY, WENY_);
  buf B2(AY[0], AY_[0]);
  buf B3(AY[1], AY_[1]);
  buf B4(AY[2], AY_[2]);
  buf B5(AY[3], AY_[3]);
  buf B6(AY[4], AY_[4]);
  buf B7(AY[5], AY_[5]);
  buf B8(AY[6], AY_[6]);
  buf B9(AY[7], AY_[7]);
  buf B10(DY[0], DY_[0]);
  buf B11(DY[1], DY_[1]);
  buf B12(DY[2], DY_[2]);
  buf B13(DY[3], DY_[3]);
  buf B14(DY[4], DY_[4]);
  buf B15(DY[5], DY_[5]);
  buf B16(DY[6], DY_[6]);
  buf B17(DY[7], DY_[7]);
  buf B18(DY[8], DY_[8]);
  buf B19(DY[9], DY_[9]);
  buf B20(DY[10], DY_[10]);
  buf B21(DY[11], DY_[11]);
  buf B22(DY[12], DY_[12]);
  buf B23(DY[13], DY_[13]);
  buf B24(DY[14], DY_[14]);
  buf B25(DY[15], DY_[15]);
  buf B26(DY[16], DY_[16]);
  buf B27(DY[17], DY_[17]);
  buf B28(DY[18], DY_[18]);
  buf B29(DY[19], DY_[19]);
  buf B30(DY[20], DY_[20]);
  buf B31(DY[21], DY_[21]);
  buf B32(DY[22], DY_[22]);
  buf B33(DY[23], DY_[23]);
  buf B34(DY[24], DY_[24]);
  buf B35(DY[25], DY_[25]);
  buf B36(DY[26], DY_[26]);
  buf B37(DY[27], DY_[27]);
  buf B38(DY[28], DY_[28]);
  buf B39(DY[29], DY_[29]);
  buf B40(DY[30], DY_[30]);
  buf B41(DY[31], DY_[31]);
  buf B42(DY[32], DY_[32]);
  buf B43(DY[33], DY_[33]);
  buf B44(DY[34], DY_[34]);
  buf B45(DY[35], DY_[35]);
  buf B46(DY[36], DY_[36]);
  buf B47(DY[37], DY_[37]);
  buf B48(DY[38], DY_[38]);
  buf B49(DY[39], DY_[39]);
  buf B50(DY[40], DY_[40]);
  buf B51(DY[41], DY_[41]);
  buf B52(DY[42], DY_[42]);
  buf B53(DY[43], DY_[43]);
  buf B54(DY[44], DY_[44]);
  buf B55(DY[45], DY_[45]);
  buf B56(DY[46], DY_[46]);
  buf B57(DY[47], DY_[47]);
  buf B58(DY[48], DY_[48]);
  buf B59(DY[49], DY_[49]);
  buf B60(DY[50], DY_[50]);
  buf B61(DY[51], DY_[51]);
  buf B62(DY[52], DY_[52]);
  buf B63(DY[53], DY_[53]);
  buf B64(DY[54], DY_[54]);
  buf B65(DY[55], DY_[55]);
  buf B66(DY[56], DY_[56]);
  buf B67(DY[57], DY_[57]);
  buf B68(DY[58], DY_[58]);
  buf B69(DY[59], DY_[59]);
  buf B70(DY[60], DY_[60]);
  buf B71(DY[61], DY_[61]);
  buf B72(DY[62], DY_[62]);
  buf B73(DY[63], DY_[63]);
  buf B74(DY[64], DY_[64]);
  buf B75(DY[65], DY_[65]);
  buf B76(DY[66], DY_[66]);
  buf B77(DY[67], DY_[67]);
  buf B78(DY[68], DY_[68]);
  buf B79(DY[69], DY_[69]);
  buf B80(DY[70], DY_[70]);
  buf B81(DY[71], DY_[71]);
  buf B82(DY[72], DY_[72]);
  buf B83(DY[73], DY_[73]);
  buf B84(DY[74], DY_[74]);
  buf B85(DY[75], DY_[75]);
  buf B86(DY[76], DY_[76]);
  buf B87(DY[77], DY_[77]);
  buf B88(DY[78], DY_[78]);
  buf B89(DY[79], DY_[79]);
  buf B90(Q[0], Q_[0]);
  buf B91(Q[1], Q_[1]);
  buf B92(Q[2], Q_[2]);
  buf B93(Q[3], Q_[3]);
  buf B94(Q[4], Q_[4]);
  buf B95(Q[5], Q_[5]);
  buf B96(Q[6], Q_[6]);
  buf B97(Q[7], Q_[7]);
  buf B98(Q[8], Q_[8]);
  buf B99(Q[9], Q_[9]);
  buf B100(Q[10], Q_[10]);
  buf B101(Q[11], Q_[11]);
  buf B102(Q[12], Q_[12]);
  buf B103(Q[13], Q_[13]);
  buf B104(Q[14], Q_[14]);
  buf B105(Q[15], Q_[15]);
  buf B106(Q[16], Q_[16]);
  buf B107(Q[17], Q_[17]);
  buf B108(Q[18], Q_[18]);
  buf B109(Q[19], Q_[19]);
  buf B110(Q[20], Q_[20]);
  buf B111(Q[21], Q_[21]);
  buf B112(Q[22], Q_[22]);
  buf B113(Q[23], Q_[23]);
  buf B114(Q[24], Q_[24]);
  buf B115(Q[25], Q_[25]);
  buf B116(Q[26], Q_[26]);
  buf B117(Q[27], Q_[27]);
  buf B118(Q[28], Q_[28]);
  buf B119(Q[29], Q_[29]);
  buf B120(Q[30], Q_[30]);
  buf B121(Q[31], Q_[31]);
  buf B122(Q[32], Q_[32]);
  buf B123(Q[33], Q_[33]);
  buf B124(Q[34], Q_[34]);
  buf B125(Q[35], Q_[35]);
  buf B126(Q[36], Q_[36]);
  buf B127(Q[37], Q_[37]);
  buf B128(Q[38], Q_[38]);
  buf B129(Q[39], Q_[39]);
  buf B130(Q[40], Q_[40]);
  buf B131(Q[41], Q_[41]);
  buf B132(Q[42], Q_[42]);
  buf B133(Q[43], Q_[43]);
  buf B134(Q[44], Q_[44]);
  buf B135(Q[45], Q_[45]);
  buf B136(Q[46], Q_[46]);
  buf B137(Q[47], Q_[47]);
  buf B138(Q[48], Q_[48]);
  buf B139(Q[49], Q_[49]);
  buf B140(Q[50], Q_[50]);
  buf B141(Q[51], Q_[51]);
  buf B142(Q[52], Q_[52]);
  buf B143(Q[53], Q_[53]);
  buf B144(Q[54], Q_[54]);
  buf B145(Q[55], Q_[55]);
  buf B146(Q[56], Q_[56]);
  buf B147(Q[57], Q_[57]);
  buf B148(Q[58], Q_[58]);
  buf B149(Q[59], Q_[59]);
  buf B150(Q[60], Q_[60]);
  buf B151(Q[61], Q_[61]);
  buf B152(Q[62], Q_[62]);
  buf B153(Q[63], Q_[63]);
  buf B154(Q[64], Q_[64]);
  buf B155(Q[65], Q_[65]);
  buf B156(Q[66], Q_[66]);
  buf B157(Q[67], Q_[67]);
  buf B158(Q[68], Q_[68]);
  buf B159(Q[69], Q_[69]);
  buf B160(Q[70], Q_[70]);
  buf B161(Q[71], Q_[71]);
  buf B162(Q[72], Q_[72]);
  buf B163(Q[73], Q_[73]);
  buf B164(Q[74], Q_[74]);
  buf B165(Q[75], Q_[75]);
  buf B166(Q[76], Q_[76]);
  buf B167(Q[77], Q_[77]);
  buf B168(Q[78], Q_[78]);
  buf B169(Q[79], Q_[79]);
  buf B170(CLK_, CLK);
  buf B171(CEN_, CEN);
  buf B172(WEN_, WEN);
  buf B173(A_[0], A[0]);
  buf B174(A_[1], A[1]);
  buf B175(A_[2], A[2]);
  buf B176(A_[3], A[3]);
  buf B177(A_[4], A[4]);
  buf B178(A_[5], A[5]);
  buf B179(A_[6], A[6]);
  buf B180(A_[7], A[7]);
  buf B181(D_[0], D[0]);
  buf B182(D_[1], D[1]);
  buf B183(D_[2], D[2]);
  buf B184(D_[3], D[3]);
  buf B185(D_[4], D[4]);
  buf B186(D_[5], D[5]);
  buf B187(D_[6], D[6]);
  buf B188(D_[7], D[7]);
  buf B189(D_[8], D[8]);
  buf B190(D_[9], D[9]);
  buf B191(D_[10], D[10]);
  buf B192(D_[11], D[11]);
  buf B193(D_[12], D[12]);
  buf B194(D_[13], D[13]);
  buf B195(D_[14], D[14]);
  buf B196(D_[15], D[15]);
  buf B197(D_[16], D[16]);
  buf B198(D_[17], D[17]);
  buf B199(D_[18], D[18]);
  buf B200(D_[19], D[19]);
  buf B201(D_[20], D[20]);
  buf B202(D_[21], D[21]);
  buf B203(D_[22], D[22]);
  buf B204(D_[23], D[23]);
  buf B205(D_[24], D[24]);
  buf B206(D_[25], D[25]);
  buf B207(D_[26], D[26]);
  buf B208(D_[27], D[27]);
  buf B209(D_[28], D[28]);
  buf B210(D_[29], D[29]);
  buf B211(D_[30], D[30]);
  buf B212(D_[31], D[31]);
  buf B213(D_[32], D[32]);
  buf B214(D_[33], D[33]);
  buf B215(D_[34], D[34]);
  buf B216(D_[35], D[35]);
  buf B217(D_[36], D[36]);
  buf B218(D_[37], D[37]);
  buf B219(D_[38], D[38]);
  buf B220(D_[39], D[39]);
  buf B221(D_[40], D[40]);
  buf B222(D_[41], D[41]);
  buf B223(D_[42], D[42]);
  buf B224(D_[43], D[43]);
  buf B225(D_[44], D[44]);
  buf B226(D_[45], D[45]);
  buf B227(D_[46], D[46]);
  buf B228(D_[47], D[47]);
  buf B229(D_[48], D[48]);
  buf B230(D_[49], D[49]);
  buf B231(D_[50], D[50]);
  buf B232(D_[51], D[51]);
  buf B233(D_[52], D[52]);
  buf B234(D_[53], D[53]);
  buf B235(D_[54], D[54]);
  buf B236(D_[55], D[55]);
  buf B237(D_[56], D[56]);
  buf B238(D_[57], D[57]);
  buf B239(D_[58], D[58]);
  buf B240(D_[59], D[59]);
  buf B241(D_[60], D[60]);
  buf B242(D_[61], D[61]);
  buf B243(D_[62], D[62]);
  buf B244(D_[63], D[63]);
  buf B245(D_[64], D[64]);
  buf B246(D_[65], D[65]);
  buf B247(D_[66], D[66]);
  buf B248(D_[67], D[67]);
  buf B249(D_[68], D[68]);
  buf B250(D_[69], D[69]);
  buf B251(D_[70], D[70]);
  buf B252(D_[71], D[71]);
  buf B253(D_[72], D[72]);
  buf B254(D_[73], D[73]);
  buf B255(D_[74], D[74]);
  buf B256(D_[75], D[75]);
  buf B257(D_[76], D[76]);
  buf B258(D_[77], D[77]);
  buf B259(D_[78], D[78]);
  buf B260(D_[79], D[79]);
  buf B261(EMA_[0], EMA[0]);
  buf B262(EMA_[1], EMA[1]);
  buf B263(EMA_[2], EMA[2]);
  buf B264(EMAW_[0], EMAW[0]);
  buf B265(EMAW_[1], EMAW[1]);
  buf B266(EMAS_, EMAS);
  buf B267(TEN_, TEN);
  buf B268(BEN_, BEN);
  buf B269(TCEN_, TCEN);
  buf B270(TWEN_, TWEN);
  buf B271(TA_[0], TA[0]);
  buf B272(TA_[1], TA[1]);
  buf B273(TA_[2], TA[2]);
  buf B274(TA_[3], TA[3]);
  buf B275(TA_[4], TA[4]);
  buf B276(TA_[5], TA[5]);
  buf B277(TA_[6], TA[6]);
  buf B278(TA_[7], TA[7]);
  buf B279(TD_[0], TD[0]);
  buf B280(TD_[1], TD[1]);
  buf B281(TD_[2], TD[2]);
  buf B282(TD_[3], TD[3]);
  buf B283(TD_[4], TD[4]);
  buf B284(TD_[5], TD[5]);
  buf B285(TD_[6], TD[6]);
  buf B286(TD_[7], TD[7]);
  buf B287(TD_[8], TD[8]);
  buf B288(TD_[9], TD[9]);
  buf B289(TD_[10], TD[10]);
  buf B290(TD_[11], TD[11]);
  buf B291(TD_[12], TD[12]);
  buf B292(TD_[13], TD[13]);
  buf B293(TD_[14], TD[14]);
  buf B294(TD_[15], TD[15]);
  buf B295(TD_[16], TD[16]);
  buf B296(TD_[17], TD[17]);
  buf B297(TD_[18], TD[18]);
  buf B298(TD_[19], TD[19]);
  buf B299(TD_[20], TD[20]);
  buf B300(TD_[21], TD[21]);
  buf B301(TD_[22], TD[22]);
  buf B302(TD_[23], TD[23]);
  buf B303(TD_[24], TD[24]);
  buf B304(TD_[25], TD[25]);
  buf B305(TD_[26], TD[26]);
  buf B306(TD_[27], TD[27]);
  buf B307(TD_[28], TD[28]);
  buf B308(TD_[29], TD[29]);
  buf B309(TD_[30], TD[30]);
  buf B310(TD_[31], TD[31]);
  buf B311(TD_[32], TD[32]);
  buf B312(TD_[33], TD[33]);
  buf B313(TD_[34], TD[34]);
  buf B314(TD_[35], TD[35]);
  buf B315(TD_[36], TD[36]);
  buf B316(TD_[37], TD[37]);
  buf B317(TD_[38], TD[38]);
  buf B318(TD_[39], TD[39]);
  buf B319(TD_[40], TD[40]);
  buf B320(TD_[41], TD[41]);
  buf B321(TD_[42], TD[42]);
  buf B322(TD_[43], TD[43]);
  buf B323(TD_[44], TD[44]);
  buf B324(TD_[45], TD[45]);
  buf B325(TD_[46], TD[46]);
  buf B326(TD_[47], TD[47]);
  buf B327(TD_[48], TD[48]);
  buf B328(TD_[49], TD[49]);
  buf B329(TD_[50], TD[50]);
  buf B330(TD_[51], TD[51]);
  buf B331(TD_[52], TD[52]);
  buf B332(TD_[53], TD[53]);
  buf B333(TD_[54], TD[54]);
  buf B334(TD_[55], TD[55]);
  buf B335(TD_[56], TD[56]);
  buf B336(TD_[57], TD[57]);
  buf B337(TD_[58], TD[58]);
  buf B338(TD_[59], TD[59]);
  buf B339(TD_[60], TD[60]);
  buf B340(TD_[61], TD[61]);
  buf B341(TD_[62], TD[62]);
  buf B342(TD_[63], TD[63]);
  buf B343(TD_[64], TD[64]);
  buf B344(TD_[65], TD[65]);
  buf B345(TD_[66], TD[66]);
  buf B346(TD_[67], TD[67]);
  buf B347(TD_[68], TD[68]);
  buf B348(TD_[69], TD[69]);
  buf B349(TD_[70], TD[70]);
  buf B350(TD_[71], TD[71]);
  buf B351(TD_[72], TD[72]);
  buf B352(TD_[73], TD[73]);
  buf B353(TD_[74], TD[74]);
  buf B354(TD_[75], TD[75]);
  buf B355(TD_[76], TD[76]);
  buf B356(TD_[77], TD[77]);
  buf B357(TD_[78], TD[78]);
  buf B358(TD_[79], TD[79]);
  buf B359(TQ_[0], TQ[0]);
  buf B360(TQ_[1], TQ[1]);
  buf B361(TQ_[2], TQ[2]);
  buf B362(TQ_[3], TQ[3]);
  buf B363(TQ_[4], TQ[4]);
  buf B364(TQ_[5], TQ[5]);
  buf B365(TQ_[6], TQ[6]);
  buf B366(TQ_[7], TQ[7]);
  buf B367(TQ_[8], TQ[8]);
  buf B368(TQ_[9], TQ[9]);
  buf B369(TQ_[10], TQ[10]);
  buf B370(TQ_[11], TQ[11]);
  buf B371(TQ_[12], TQ[12]);
  buf B372(TQ_[13], TQ[13]);
  buf B373(TQ_[14], TQ[14]);
  buf B374(TQ_[15], TQ[15]);
  buf B375(TQ_[16], TQ[16]);
  buf B376(TQ_[17], TQ[17]);
  buf B377(TQ_[18], TQ[18]);
  buf B378(TQ_[19], TQ[19]);
  buf B379(TQ_[20], TQ[20]);
  buf B380(TQ_[21], TQ[21]);
  buf B381(TQ_[22], TQ[22]);
  buf B382(TQ_[23], TQ[23]);
  buf B383(TQ_[24], TQ[24]);
  buf B384(TQ_[25], TQ[25]);
  buf B385(TQ_[26], TQ[26]);
  buf B386(TQ_[27], TQ[27]);
  buf B387(TQ_[28], TQ[28]);
  buf B388(TQ_[29], TQ[29]);
  buf B389(TQ_[30], TQ[30]);
  buf B390(TQ_[31], TQ[31]);
  buf B391(TQ_[32], TQ[32]);
  buf B392(TQ_[33], TQ[33]);
  buf B393(TQ_[34], TQ[34]);
  buf B394(TQ_[35], TQ[35]);
  buf B395(TQ_[36], TQ[36]);
  buf B396(TQ_[37], TQ[37]);
  buf B397(TQ_[38], TQ[38]);
  buf B398(TQ_[39], TQ[39]);
  buf B399(TQ_[40], TQ[40]);
  buf B400(TQ_[41], TQ[41]);
  buf B401(TQ_[42], TQ[42]);
  buf B402(TQ_[43], TQ[43]);
  buf B403(TQ_[44], TQ[44]);
  buf B404(TQ_[45], TQ[45]);
  buf B405(TQ_[46], TQ[46]);
  buf B406(TQ_[47], TQ[47]);
  buf B407(TQ_[48], TQ[48]);
  buf B408(TQ_[49], TQ[49]);
  buf B409(TQ_[50], TQ[50]);
  buf B410(TQ_[51], TQ[51]);
  buf B411(TQ_[52], TQ[52]);
  buf B412(TQ_[53], TQ[53]);
  buf B413(TQ_[54], TQ[54]);
  buf B414(TQ_[55], TQ[55]);
  buf B415(TQ_[56], TQ[56]);
  buf B416(TQ_[57], TQ[57]);
  buf B417(TQ_[58], TQ[58]);
  buf B418(TQ_[59], TQ[59]);
  buf B419(TQ_[60], TQ[60]);
  buf B420(TQ_[61], TQ[61]);
  buf B421(TQ_[62], TQ[62]);
  buf B422(TQ_[63], TQ[63]);
  buf B423(TQ_[64], TQ[64]);
  buf B424(TQ_[65], TQ[65]);
  buf B425(TQ_[66], TQ[66]);
  buf B426(TQ_[67], TQ[67]);
  buf B427(TQ_[68], TQ[68]);
  buf B428(TQ_[69], TQ[69]);
  buf B429(TQ_[70], TQ[70]);
  buf B430(TQ_[71], TQ[71]);
  buf B431(TQ_[72], TQ[72]);
  buf B432(TQ_[73], TQ[73]);
  buf B433(TQ_[74], TQ[74]);
  buf B434(TQ_[75], TQ[75]);
  buf B435(TQ_[76], TQ[76]);
  buf B436(TQ_[77], TQ[77]);
  buf B437(TQ_[78], TQ[78]);
  buf B438(TQ_[79], TQ[79]);
  buf B439(RET1N_, RET1N);
  buf B440(STOV_, STOV);

  assign CENY_ = RET1N_ ? (TEN_ ? CEN_ : TCEN_) : 1'bx;
  assign WENY_ = RET1N_ ? (TEN_ ? WEN_ : TWEN_) : 1'bx;
  assign AY_ = RET1N_ ? (TEN_ ? A_ : TA_) : {8{1'bx}};
  assign DY_ = RET1N_ ? (TEN_ ? D_ : TD_) : {80{1'bx}};
   `ifdef ARM_FAULT_MODELING
     sram_sp_hde_error_injection u1(.CLK(CLK_), .Q_out(Q_), .A(A_int), .CEN(CEN_int), .TQ(TQ_), .BEN(BEN_), .WEN(WEN_int), .Q_in(Q_int));
  `else
  assign Q_ = RET1N_ ? (BEN_ ? ((STOV_ ? (Q_int_delayed) : (Q_int))) : TQ_) : {80{1'bx}};
  `endif

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
`endif

  task failedWrite;
  input port_f;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitval;
    begin
      isBitX = ( bitval===1'bx || bitval==1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [7:0] Atemp;
  begin
	$readmemb(filename, memld);
     if (CEN_ === 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 3'b111);
      row_address = (Atemp >> 3);
      row = mem[row_address];
        writeEnable = {80{1'b1}};
        row_mask =  ( {7'b0000000, writeEnable[79], 7'b0000000, writeEnable[78], 7'b0000000, writeEnable[77],
          7'b0000000, writeEnable[76], 7'b0000000, writeEnable[75], 7'b0000000, writeEnable[74],
          7'b0000000, writeEnable[73], 7'b0000000, writeEnable[72], 7'b0000000, writeEnable[71],
          7'b0000000, writeEnable[70], 7'b0000000, writeEnable[69], 7'b0000000, writeEnable[68],
          7'b0000000, writeEnable[67], 7'b0000000, writeEnable[66], 7'b0000000, writeEnable[65],
          7'b0000000, writeEnable[64], 7'b0000000, writeEnable[63], 7'b0000000, writeEnable[62],
          7'b0000000, writeEnable[61], 7'b0000000, writeEnable[60], 7'b0000000, writeEnable[59],
          7'b0000000, writeEnable[58], 7'b0000000, writeEnable[57], 7'b0000000, writeEnable[56],
          7'b0000000, writeEnable[55], 7'b0000000, writeEnable[54], 7'b0000000, writeEnable[53],
          7'b0000000, writeEnable[52], 7'b0000000, writeEnable[51], 7'b0000000, writeEnable[50],
          7'b0000000, writeEnable[49], 7'b0000000, writeEnable[48], 7'b0000000, writeEnable[47],
          7'b0000000, writeEnable[46], 7'b0000000, writeEnable[45], 7'b0000000, writeEnable[44],
          7'b0000000, writeEnable[43], 7'b0000000, writeEnable[42], 7'b0000000, writeEnable[41],
          7'b0000000, writeEnable[40], 7'b0000000, writeEnable[39], 7'b0000000, writeEnable[38],
          7'b0000000, writeEnable[37], 7'b0000000, writeEnable[36], 7'b0000000, writeEnable[35],
          7'b0000000, writeEnable[34], 7'b0000000, writeEnable[33], 7'b0000000, writeEnable[32],
          7'b0000000, writeEnable[31], 7'b0000000, writeEnable[30], 7'b0000000, writeEnable[29],
          7'b0000000, writeEnable[28], 7'b0000000, writeEnable[27], 7'b0000000, writeEnable[26],
          7'b0000000, writeEnable[25], 7'b0000000, writeEnable[24], 7'b0000000, writeEnable[23],
          7'b0000000, writeEnable[22], 7'b0000000, writeEnable[21], 7'b0000000, writeEnable[20],
          7'b0000000, writeEnable[19], 7'b0000000, writeEnable[18], 7'b0000000, writeEnable[17],
          7'b0000000, writeEnable[16], 7'b0000000, writeEnable[15], 7'b0000000, writeEnable[14],
          7'b0000000, writeEnable[13], 7'b0000000, writeEnable[12], 7'b0000000, writeEnable[11],
          7'b0000000, writeEnable[10], 7'b0000000, writeEnable[9], 7'b0000000, writeEnable[8],
          7'b0000000, writeEnable[7], 7'b0000000, writeEnable[6], 7'b0000000, writeEnable[5],
          7'b0000000, writeEnable[4], 7'b0000000, writeEnable[3], 7'b0000000, writeEnable[2],
          7'b0000000, writeEnable[1], 7'b0000000, writeEnable[0]} << mux_address);
        new_data =  ( {7'b0000000, wordtemp[79], 7'b0000000, wordtemp[78], 7'b0000000, wordtemp[77],
          7'b0000000, wordtemp[76], 7'b0000000, wordtemp[75], 7'b0000000, wordtemp[74],
          7'b0000000, wordtemp[73], 7'b0000000, wordtemp[72], 7'b0000000, wordtemp[71],
          7'b0000000, wordtemp[70], 7'b0000000, wordtemp[69], 7'b0000000, wordtemp[68],
          7'b0000000, wordtemp[67], 7'b0000000, wordtemp[66], 7'b0000000, wordtemp[65],
          7'b0000000, wordtemp[64], 7'b0000000, wordtemp[63], 7'b0000000, wordtemp[62],
          7'b0000000, wordtemp[61], 7'b0000000, wordtemp[60], 7'b0000000, wordtemp[59],
          7'b0000000, wordtemp[58], 7'b0000000, wordtemp[57], 7'b0000000, wordtemp[56],
          7'b0000000, wordtemp[55], 7'b0000000, wordtemp[54], 7'b0000000, wordtemp[53],
          7'b0000000, wordtemp[52], 7'b0000000, wordtemp[51], 7'b0000000, wordtemp[50],
          7'b0000000, wordtemp[49], 7'b0000000, wordtemp[48], 7'b0000000, wordtemp[47],
          7'b0000000, wordtemp[46], 7'b0000000, wordtemp[45], 7'b0000000, wordtemp[44],
          7'b0000000, wordtemp[43], 7'b0000000, wordtemp[42], 7'b0000000, wordtemp[41],
          7'b0000000, wordtemp[40], 7'b0000000, wordtemp[39], 7'b0000000, wordtemp[38],
          7'b0000000, wordtemp[37], 7'b0000000, wordtemp[36], 7'b0000000, wordtemp[35],
          7'b0000000, wordtemp[34], 7'b0000000, wordtemp[33], 7'b0000000, wordtemp[32],
          7'b0000000, wordtemp[31], 7'b0000000, wordtemp[30], 7'b0000000, wordtemp[29],
          7'b0000000, wordtemp[28], 7'b0000000, wordtemp[27], 7'b0000000, wordtemp[26],
          7'b0000000, wordtemp[25], 7'b0000000, wordtemp[24], 7'b0000000, wordtemp[23],
          7'b0000000, wordtemp[22], 7'b0000000, wordtemp[21], 7'b0000000, wordtemp[20],
          7'b0000000, wordtemp[19], 7'b0000000, wordtemp[18], 7'b0000000, wordtemp[17],
          7'b0000000, wordtemp[16], 7'b0000000, wordtemp[15], 7'b0000000, wordtemp[14],
          7'b0000000, wordtemp[13], 7'b0000000, wordtemp[12], 7'b0000000, wordtemp[11],
          7'b0000000, wordtemp[10], 7'b0000000, wordtemp[9], 7'b0000000, wordtemp[8],
          7'b0000000, wordtemp[7], 7'b0000000, wordtemp[6], 7'b0000000, wordtemp[5],
          7'b0000000, wordtemp[4], 7'b0000000, wordtemp[3], 7'b0000000, wordtemp[2],
          7'b0000000, wordtemp[1], 7'b0000000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
  end
  end
  endtask

task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [7:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
     if (CEN_ === 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 3'b111);
      row_address = (Atemp >> 3);
      row = mem[row_address];
        writeEnable = {80{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[636], data_out[632], data_out[628], data_out[624], data_out[620],
          data_out[616], data_out[612], data_out[608], data_out[604], data_out[600],
          data_out[596], data_out[592], data_out[588], data_out[584], data_out[580],
          data_out[576], data_out[572], data_out[568], data_out[564], data_out[560],
          data_out[556], data_out[552], data_out[548], data_out[544], data_out[540],
          data_out[536], data_out[532], data_out[528], data_out[524], data_out[520],
          data_out[516], data_out[512], data_out[508], data_out[504], data_out[500],
          data_out[496], data_out[492], data_out[488], data_out[484], data_out[480],
          data_out[476], data_out[472], data_out[468], data_out[464], data_out[460],
          data_out[456], data_out[452], data_out[448], data_out[444], data_out[440],
          data_out[436], data_out[432], data_out[428], data_out[424], data_out[420],
          data_out[416], data_out[412], data_out[408], data_out[404], data_out[400],
          data_out[396], data_out[392], data_out[388], data_out[384], data_out[380],
          data_out[376], data_out[372], data_out[368], data_out[364], data_out[360],
          data_out[356], data_out[352], data_out[348], data_out[344], data_out[340],
          data_out[336], data_out[332], data_out[328], data_out[324], data_out[320],
          data_out[316], data_out[312], data_out[308], data_out[304], data_out[300],
          data_out[296], data_out[292], data_out[288], data_out[284], data_out[280],
          data_out[276], data_out[272], data_out[268], data_out[264], data_out[260],
          data_out[256], data_out[252], data_out[248], data_out[244], data_out[240],
          data_out[236], data_out[232], data_out[228], data_out[224], data_out[220],
          data_out[216], data_out[212], data_out[208], data_out[204], data_out[200],
          data_out[196], data_out[192], data_out[188], data_out[184], data_out[180],
          data_out[176], data_out[172], data_out[168], data_out[164], data_out[160],
          data_out[156], data_out[152], data_out[148], data_out[144], data_out[140],
          data_out[136], data_out[132], data_out[128], data_out[124], data_out[120],
          data_out[116], data_out[112], data_out[108], data_out[104], data_out[100],
          data_out[96], data_out[92], data_out[88], data_out[84], data_out[80], data_out[76],
          data_out[72], data_out[68], data_out[64], data_out[60], data_out[56], data_out[52],
          data_out[48], data_out[44], data_out[40], data_out[36], data_out[32], data_out[28],
          data_out[24], data_out[20], data_out[16], data_out[12], data_out[8], data_out[4],
          data_out[0]};
        shifted_readLatch0 = readLatch0;
        Q_int = {shifted_readLatch0[158], shifted_readLatch0[156], shifted_readLatch0[154],
          shifted_readLatch0[152], shifted_readLatch0[150], shifted_readLatch0[148],
          shifted_readLatch0[146], shifted_readLatch0[144], shifted_readLatch0[142],
          shifted_readLatch0[140], shifted_readLatch0[138], shifted_readLatch0[136],
          shifted_readLatch0[134], shifted_readLatch0[132], shifted_readLatch0[130],
          shifted_readLatch0[128], shifted_readLatch0[126], shifted_readLatch0[124],
          shifted_readLatch0[122], shifted_readLatch0[120], shifted_readLatch0[118],
          shifted_readLatch0[116], shifted_readLatch0[114], shifted_readLatch0[112],
          shifted_readLatch0[110], shifted_readLatch0[108], shifted_readLatch0[106],
          shifted_readLatch0[104], shifted_readLatch0[102], shifted_readLatch0[100],
          shifted_readLatch0[98], shifted_readLatch0[96], shifted_readLatch0[94], shifted_readLatch0[92],
          shifted_readLatch0[90], shifted_readLatch0[88], shifted_readLatch0[86], shifted_readLatch0[84],
          shifted_readLatch0[82], shifted_readLatch0[80], shifted_readLatch0[78], shifted_readLatch0[76],
          shifted_readLatch0[74], shifted_readLatch0[72], shifted_readLatch0[70], shifted_readLatch0[68],
          shifted_readLatch0[66], shifted_readLatch0[64], shifted_readLatch0[62], shifted_readLatch0[60],
          shifted_readLatch0[58], shifted_readLatch0[56], shifted_readLatch0[54], shifted_readLatch0[52],
          shifted_readLatch0[50], shifted_readLatch0[48], shifted_readLatch0[46], shifted_readLatch0[44],
          shifted_readLatch0[42], shifted_readLatch0[40], shifted_readLatch0[38], shifted_readLatch0[36],
          shifted_readLatch0[34], shifted_readLatch0[32], shifted_readLatch0[30], shifted_readLatch0[28],
          shifted_readLatch0[26], shifted_readLatch0[24], shifted_readLatch0[22], shifted_readLatch0[20],
          shifted_readLatch0[18], shifted_readLatch0[16], shifted_readLatch0[14], shifted_readLatch0[12],
          shifted_readLatch0[10], shifted_readLatch0[8], shifted_readLatch0[6], shifted_readLatch0[4],
          shifted_readLatch0[2], shifted_readLatch0[0]};
   	$fdisplay(dump_file_desc, "%b", Q_int);
  end
  	end
//    $fclose(filename_dump);
  end
  endtask


  task readWrite;
  begin
    if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if (RET1N_int === 1'b0 && CEN_int === 1'b0) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{CEN_int, EMA_int, EMAW_int, EMAS_int, RET1N_int, (STOV_int && !CEN_int)} 
     === 1'bx) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if ((A_int >= WORDS) && (CEN_int === 1'b0)) begin
      Q_int = WEN_int !== 1'b1 ? D_int : {80{1'bx}};
      Q_int_delayed = WEN_int !== 1'b1 ? D_int : {80{1'bx}};
    end else if (CEN_int === 1'b0 && (^A_int) === 1'bx) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if (CEN_int === 1'b0) begin
      mux_address = (A_int & 3'b111);
      row_address = (A_int >> 3);
      if (row_address > 31)
        row = {640{1'bx}};
      else
        row = mem[row_address];
      writeEnable = ~{80{WEN_int}};
      if (WEN_int !== 1'b1) begin
        row_mask =  ( {7'b0000000, writeEnable[79], 7'b0000000, writeEnable[78], 7'b0000000, writeEnable[77],
          7'b0000000, writeEnable[76], 7'b0000000, writeEnable[75], 7'b0000000, writeEnable[74],
          7'b0000000, writeEnable[73], 7'b0000000, writeEnable[72], 7'b0000000, writeEnable[71],
          7'b0000000, writeEnable[70], 7'b0000000, writeEnable[69], 7'b0000000, writeEnable[68],
          7'b0000000, writeEnable[67], 7'b0000000, writeEnable[66], 7'b0000000, writeEnable[65],
          7'b0000000, writeEnable[64], 7'b0000000, writeEnable[63], 7'b0000000, writeEnable[62],
          7'b0000000, writeEnable[61], 7'b0000000, writeEnable[60], 7'b0000000, writeEnable[59],
          7'b0000000, writeEnable[58], 7'b0000000, writeEnable[57], 7'b0000000, writeEnable[56],
          7'b0000000, writeEnable[55], 7'b0000000, writeEnable[54], 7'b0000000, writeEnable[53],
          7'b0000000, writeEnable[52], 7'b0000000, writeEnable[51], 7'b0000000, writeEnable[50],
          7'b0000000, writeEnable[49], 7'b0000000, writeEnable[48], 7'b0000000, writeEnable[47],
          7'b0000000, writeEnable[46], 7'b0000000, writeEnable[45], 7'b0000000, writeEnable[44],
          7'b0000000, writeEnable[43], 7'b0000000, writeEnable[42], 7'b0000000, writeEnable[41],
          7'b0000000, writeEnable[40], 7'b0000000, writeEnable[39], 7'b0000000, writeEnable[38],
          7'b0000000, writeEnable[37], 7'b0000000, writeEnable[36], 7'b0000000, writeEnable[35],
          7'b0000000, writeEnable[34], 7'b0000000, writeEnable[33], 7'b0000000, writeEnable[32],
          7'b0000000, writeEnable[31], 7'b0000000, writeEnable[30], 7'b0000000, writeEnable[29],
          7'b0000000, writeEnable[28], 7'b0000000, writeEnable[27], 7'b0000000, writeEnable[26],
          7'b0000000, writeEnable[25], 7'b0000000, writeEnable[24], 7'b0000000, writeEnable[23],
          7'b0000000, writeEnable[22], 7'b0000000, writeEnable[21], 7'b0000000, writeEnable[20],
          7'b0000000, writeEnable[19], 7'b0000000, writeEnable[18], 7'b0000000, writeEnable[17],
          7'b0000000, writeEnable[16], 7'b0000000, writeEnable[15], 7'b0000000, writeEnable[14],
          7'b0000000, writeEnable[13], 7'b0000000, writeEnable[12], 7'b0000000, writeEnable[11],
          7'b0000000, writeEnable[10], 7'b0000000, writeEnable[9], 7'b0000000, writeEnable[8],
          7'b0000000, writeEnable[7], 7'b0000000, writeEnable[6], 7'b0000000, writeEnable[5],
          7'b0000000, writeEnable[4], 7'b0000000, writeEnable[3], 7'b0000000, writeEnable[2],
          7'b0000000, writeEnable[1], 7'b0000000, writeEnable[0]} << mux_address);
        new_data =  ( {7'b0000000, D_int[79], 7'b0000000, D_int[78], 7'b0000000, D_int[77],
          7'b0000000, D_int[76], 7'b0000000, D_int[75], 7'b0000000, D_int[74], 7'b0000000, D_int[73],
          7'b0000000, D_int[72], 7'b0000000, D_int[71], 7'b0000000, D_int[70], 7'b0000000, D_int[69],
          7'b0000000, D_int[68], 7'b0000000, D_int[67], 7'b0000000, D_int[66], 7'b0000000, D_int[65],
          7'b0000000, D_int[64], 7'b0000000, D_int[63], 7'b0000000, D_int[62], 7'b0000000, D_int[61],
          7'b0000000, D_int[60], 7'b0000000, D_int[59], 7'b0000000, D_int[58], 7'b0000000, D_int[57],
          7'b0000000, D_int[56], 7'b0000000, D_int[55], 7'b0000000, D_int[54], 7'b0000000, D_int[53],
          7'b0000000, D_int[52], 7'b0000000, D_int[51], 7'b0000000, D_int[50], 7'b0000000, D_int[49],
          7'b0000000, D_int[48], 7'b0000000, D_int[47], 7'b0000000, D_int[46], 7'b0000000, D_int[45],
          7'b0000000, D_int[44], 7'b0000000, D_int[43], 7'b0000000, D_int[42], 7'b0000000, D_int[41],
          7'b0000000, D_int[40], 7'b0000000, D_int[39], 7'b0000000, D_int[38], 7'b0000000, D_int[37],
          7'b0000000, D_int[36], 7'b0000000, D_int[35], 7'b0000000, D_int[34], 7'b0000000, D_int[33],
          7'b0000000, D_int[32], 7'b0000000, D_int[31], 7'b0000000, D_int[30], 7'b0000000, D_int[29],
          7'b0000000, D_int[28], 7'b0000000, D_int[27], 7'b0000000, D_int[26], 7'b0000000, D_int[25],
          7'b0000000, D_int[24], 7'b0000000, D_int[23], 7'b0000000, D_int[22], 7'b0000000, D_int[21],
          7'b0000000, D_int[20], 7'b0000000, D_int[19], 7'b0000000, D_int[18], 7'b0000000, D_int[17],
          7'b0000000, D_int[16], 7'b0000000, D_int[15], 7'b0000000, D_int[14], 7'b0000000, D_int[13],
          7'b0000000, D_int[12], 7'b0000000, D_int[11], 7'b0000000, D_int[10], 7'b0000000, D_int[9],
          7'b0000000, D_int[8], 7'b0000000, D_int[7], 7'b0000000, D_int[6], 7'b0000000, D_int[5],
          7'b0000000, D_int[4], 7'b0000000, D_int[3], 7'b0000000, D_int[2], 7'b0000000, D_int[1],
          7'b0000000, D_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[636], data_out[632], data_out[628], data_out[624], data_out[620],
          data_out[616], data_out[612], data_out[608], data_out[604], data_out[600],
          data_out[596], data_out[592], data_out[588], data_out[584], data_out[580],
          data_out[576], data_out[572], data_out[568], data_out[564], data_out[560],
          data_out[556], data_out[552], data_out[548], data_out[544], data_out[540],
          data_out[536], data_out[532], data_out[528], data_out[524], data_out[520],
          data_out[516], data_out[512], data_out[508], data_out[504], data_out[500],
          data_out[496], data_out[492], data_out[488], data_out[484], data_out[480],
          data_out[476], data_out[472], data_out[468], data_out[464], data_out[460],
          data_out[456], data_out[452], data_out[448], data_out[444], data_out[440],
          data_out[436], data_out[432], data_out[428], data_out[424], data_out[420],
          data_out[416], data_out[412], data_out[408], data_out[404], data_out[400],
          data_out[396], data_out[392], data_out[388], data_out[384], data_out[380],
          data_out[376], data_out[372], data_out[368], data_out[364], data_out[360],
          data_out[356], data_out[352], data_out[348], data_out[344], data_out[340],
          data_out[336], data_out[332], data_out[328], data_out[324], data_out[320],
          data_out[316], data_out[312], data_out[308], data_out[304], data_out[300],
          data_out[296], data_out[292], data_out[288], data_out[284], data_out[280],
          data_out[276], data_out[272], data_out[268], data_out[264], data_out[260],
          data_out[256], data_out[252], data_out[248], data_out[244], data_out[240],
          data_out[236], data_out[232], data_out[228], data_out[224], data_out[220],
          data_out[216], data_out[212], data_out[208], data_out[204], data_out[200],
          data_out[196], data_out[192], data_out[188], data_out[184], data_out[180],
          data_out[176], data_out[172], data_out[168], data_out[164], data_out[160],
          data_out[156], data_out[152], data_out[148], data_out[144], data_out[140],
          data_out[136], data_out[132], data_out[128], data_out[124], data_out[120],
          data_out[116], data_out[112], data_out[108], data_out[104], data_out[100],
          data_out[96], data_out[92], data_out[88], data_out[84], data_out[80], data_out[76],
          data_out[72], data_out[68], data_out[64], data_out[60], data_out[56], data_out[52],
          data_out[48], data_out[44], data_out[40], data_out[36], data_out[32], data_out[28],
          data_out[24], data_out[20], data_out[16], data_out[12], data_out[8], data_out[4],
          data_out[0]};
      end
      if (WEN_int !== 1'b1) begin
        Q_int = D_int;
        Q_int_delayed = D_int;
      end else begin
        shifted_readLatch0 = (readLatch0 >> A_int[2]);
        Q_int = {shifted_readLatch0[158], shifted_readLatch0[156], shifted_readLatch0[154],
          shifted_readLatch0[152], shifted_readLatch0[150], shifted_readLatch0[148],
          shifted_readLatch0[146], shifted_readLatch0[144], shifted_readLatch0[142],
          shifted_readLatch0[140], shifted_readLatch0[138], shifted_readLatch0[136],
          shifted_readLatch0[134], shifted_readLatch0[132], shifted_readLatch0[130],
          shifted_readLatch0[128], shifted_readLatch0[126], shifted_readLatch0[124],
          shifted_readLatch0[122], shifted_readLatch0[120], shifted_readLatch0[118],
          shifted_readLatch0[116], shifted_readLatch0[114], shifted_readLatch0[112],
          shifted_readLatch0[110], shifted_readLatch0[108], shifted_readLatch0[106],
          shifted_readLatch0[104], shifted_readLatch0[102], shifted_readLatch0[100],
          shifted_readLatch0[98], shifted_readLatch0[96], shifted_readLatch0[94], shifted_readLatch0[92],
          shifted_readLatch0[90], shifted_readLatch0[88], shifted_readLatch0[86], shifted_readLatch0[84],
          shifted_readLatch0[82], shifted_readLatch0[80], shifted_readLatch0[78], shifted_readLatch0[76],
          shifted_readLatch0[74], shifted_readLatch0[72], shifted_readLatch0[70], shifted_readLatch0[68],
          shifted_readLatch0[66], shifted_readLatch0[64], shifted_readLatch0[62], shifted_readLatch0[60],
          shifted_readLatch0[58], shifted_readLatch0[56], shifted_readLatch0[54], shifted_readLatch0[52],
          shifted_readLatch0[50], shifted_readLatch0[48], shifted_readLatch0[46], shifted_readLatch0[44],
          shifted_readLatch0[42], shifted_readLatch0[40], shifted_readLatch0[38], shifted_readLatch0[36],
          shifted_readLatch0[34], shifted_readLatch0[32], shifted_readLatch0[30], shifted_readLatch0[28],
          shifted_readLatch0[26], shifted_readLatch0[24], shifted_readLatch0[22], shifted_readLatch0[20],
          shifted_readLatch0[18], shifted_readLatch0[16], shifted_readLatch0[14], shifted_readLatch0[12],
          shifted_readLatch0[10], shifted_readLatch0[8], shifted_readLatch0[6], shifted_readLatch0[4],
          shifted_readLatch0[2], shifted_readLatch0[0]};
      end
    end
  end
  endtask
  always @ (CEN_ or TCEN_ or TEN_ or CLK_) begin
  	if(CLK_ == 1'b0) begin
  		CEN_p2 = CEN_;
  		TCEN_p2 = TCEN_;
  	end
  end

  always @ RET1N_ begin
    if (CLK_ == 1'b1) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CEN_p2 === 1'b0 || TCEN_p2 === 1'b0) ) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CEN_p2 === 1'b0 || TCEN_p2 === 1'b0) ) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end
    if (RET1N_ == 1'b0) begin
      Q_int = {80{1'bx}};
      Q_int_delayed = {80{1'bx}};
      CEN_int = 1'bx;
      WEN_int = 1'bx;
      A_int = {8{1'bx}};
      D_int = {80{1'bx}};
      EMA_int = {3{1'bx}};
      EMAW_int = {2{1'bx}};
      EMAS_int = 1'bx;
      TEN_int = 1'bx;
      BEN_int = 1'bx;
      TCEN_int = 1'bx;
      TWEN_int = 1'bx;
      TA_int = {8{1'bx}};
      TD_int = {80{1'bx}};
      TQ_int = {80{1'bx}};
      RET1N_int = 1'bx;
      STOV_int = 1'bx;
    end else begin
      Q_int = {80{1'bx}};
      Q_int_delayed = {80{1'bx}};
      CEN_int = 1'bx;
      WEN_int = 1'bx;
      A_int = {8{1'bx}};
      D_int = {80{1'bx}};
      EMA_int = {3{1'bx}};
      EMAW_int = {2{1'bx}};
      EMAS_int = 1'bx;
      TEN_int = 1'bx;
      BEN_int = 1'bx;
      TCEN_int = 1'bx;
      TWEN_int = 1'bx;
      TA_int = {8{1'bx}};
      TD_int = {80{1'bx}};
      TQ_int = {80{1'bx}};
      RET1N_int = 1'bx;
      STOV_int = 1'bx;
    end
    RET1N_int = RET1N_;
  end


  always @ CLK_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("ERROR: Illegal value for VDDCE %b", VDDCE);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("ERROR: Illegal value for VDDPE %b", VDDPE);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("ERROR: Illegal value for VSSE %b", VSSE);
`endif
  if (RET1N_ == 1'b0) begin
      // no cycle in retention mode
  end else begin
    if ((CLK_ === 1'bx || CLK_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(0);
      Q_int = {80{1'bx}};
    end else if (CLK_ === 1'b1 && LAST_CLK === 1'b0) begin
      CEN_int = TEN_ ? CEN_ : TCEN_;
      EMA_int = EMA_;
      EMAW_int = EMAW_;
      EMAS_int = EMAS_;
      TEN_int = TEN_;
      BEN_int = BEN_;
      TWEN_int = TWEN_;
      TQ_int = TQ_;
      RET1N_int = RET1N_;
      STOV_int = STOV_;
      if (CEN_int != 1'b1) begin
        WEN_int = TEN_ ? WEN_ : TWEN_;
        A_int = TEN_ ? A_ : TA_;
        D_int = TEN_ ? D_ : TD_;
        TCEN_int = TCEN_;
        TA_int = TA_;
        TD_int = TD_;
        if (WEN_int === 1'b1)
          read_mux_sel0 = (TEN_ ? A_[2] : TA_[2] );
      end
      clk0_int = 1'b0;
      if (CEN_int === 1'b0 && WEN_int === 1'b1) 
         Q_int_delayed = {80{1'bx}};
    readWrite;
    end else if (CLK_ === 1'b0 && LAST_CLK === 1'b1) begin
      Q_int_delayed = Q_int;
    end
    LAST_CLK = CLK_;
  end
  end

  reg globalNotifier0;
  initial globalNotifier0 = 1'b0;

  always @ globalNotifier0 begin
    if ($realtime == 0) begin
    end else if (CEN_int === 1'bx || EMAS_int === 1'bx || EMAW_int[0] === 1'bx || 
      EMAW_int[1] === 1'bx || EMA_int[0] === 1'bx || EMA_int[1] === 1'bx || EMA_int[2] === 1'bx || 
      RET1N_int === 1'bx || (STOV_int && !CEN_int) === 1'bx || TEN_int === 1'bx || 
      clk0_int === 1'bx) begin
      Q_int = {80{1'bx}};
    if (clk0_int === 1'bx || CEN_int === 1'bx) begin
      D_int = {80{1'bx}};
    end
      failedWrite(0);
    end else begin
      readWrite;
   end
    globalNotifier0 = 1'b0;
  end

  always @ NOT_CEN begin
    CEN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WEN begin
    WEN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A7 begin
    A_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A6 begin
    A_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A5 begin
    A_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A4 begin
    A_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A3 begin
    A_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A2 begin
    A_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A1 begin
    A_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A0 begin
    A_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D79 begin
    D_int[79] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D78 begin
    D_int[78] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D77 begin
    D_int[77] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D76 begin
    D_int[76] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D75 begin
    D_int[75] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D74 begin
    D_int[74] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D73 begin
    D_int[73] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D72 begin
    D_int[72] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D71 begin
    D_int[71] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D70 begin
    D_int[70] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D69 begin
    D_int[69] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D68 begin
    D_int[68] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D67 begin
    D_int[67] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D66 begin
    D_int[66] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D65 begin
    D_int[65] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D64 begin
    D_int[64] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D63 begin
    D_int[63] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D62 begin
    D_int[62] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D61 begin
    D_int[61] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D60 begin
    D_int[60] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D59 begin
    D_int[59] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D58 begin
    D_int[58] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D57 begin
    D_int[57] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D56 begin
    D_int[56] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D55 begin
    D_int[55] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D54 begin
    D_int[54] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D53 begin
    D_int[53] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D52 begin
    D_int[52] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D51 begin
    D_int[51] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D50 begin
    D_int[50] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D49 begin
    D_int[49] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D48 begin
    D_int[48] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D47 begin
    D_int[47] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D46 begin
    D_int[46] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D45 begin
    D_int[45] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D44 begin
    D_int[44] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D43 begin
    D_int[43] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D42 begin
    D_int[42] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D41 begin
    D_int[41] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D40 begin
    D_int[40] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D39 begin
    D_int[39] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D38 begin
    D_int[38] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D37 begin
    D_int[37] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D36 begin
    D_int[36] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D35 begin
    D_int[35] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D34 begin
    D_int[34] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D33 begin
    D_int[33] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D32 begin
    D_int[32] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D31 begin
    D_int[31] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D30 begin
    D_int[30] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D29 begin
    D_int[29] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D28 begin
    D_int[28] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D27 begin
    D_int[27] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D26 begin
    D_int[26] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D25 begin
    D_int[25] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D24 begin
    D_int[24] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D23 begin
    D_int[23] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D22 begin
    D_int[22] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D21 begin
    D_int[21] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D20 begin
    D_int[20] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D19 begin
    D_int[19] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D18 begin
    D_int[18] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D17 begin
    D_int[17] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D16 begin
    D_int[16] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D15 begin
    D_int[15] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D14 begin
    D_int[14] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D13 begin
    D_int[13] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D12 begin
    D_int[12] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D11 begin
    D_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D10 begin
    D_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D9 begin
    D_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D8 begin
    D_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D7 begin
    D_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D6 begin
    D_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D5 begin
    D_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D4 begin
    D_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D3 begin
    D_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D2 begin
    D_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D1 begin
    D_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D0 begin
    D_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMA2 begin
    EMA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMA1 begin
    EMA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMA0 begin
    EMA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAW1 begin
    EMAW_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAW0 begin
    EMAW_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAS begin
    EMAS_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TEN begin
    TEN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TCEN begin
    CEN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWEN begin
    WEN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA7 begin
    A_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA6 begin
    A_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA5 begin
    A_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA4 begin
    A_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA3 begin
    A_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA2 begin
    A_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA1 begin
    A_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA0 begin
    A_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD79 begin
    D_int[79] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD78 begin
    D_int[78] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD77 begin
    D_int[77] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD76 begin
    D_int[76] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD75 begin
    D_int[75] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD74 begin
    D_int[74] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD73 begin
    D_int[73] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD72 begin
    D_int[72] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD71 begin
    D_int[71] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD70 begin
    D_int[70] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD69 begin
    D_int[69] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD68 begin
    D_int[68] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD67 begin
    D_int[67] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD66 begin
    D_int[66] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD65 begin
    D_int[65] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD64 begin
    D_int[64] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD63 begin
    D_int[63] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD62 begin
    D_int[62] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD61 begin
    D_int[61] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD60 begin
    D_int[60] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD59 begin
    D_int[59] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD58 begin
    D_int[58] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD57 begin
    D_int[57] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD56 begin
    D_int[56] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD55 begin
    D_int[55] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD54 begin
    D_int[54] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD53 begin
    D_int[53] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD52 begin
    D_int[52] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD51 begin
    D_int[51] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD50 begin
    D_int[50] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD49 begin
    D_int[49] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD48 begin
    D_int[48] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD47 begin
    D_int[47] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD46 begin
    D_int[46] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD45 begin
    D_int[45] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD44 begin
    D_int[44] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD43 begin
    D_int[43] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD42 begin
    D_int[42] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD41 begin
    D_int[41] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD40 begin
    D_int[40] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD39 begin
    D_int[39] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD38 begin
    D_int[38] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD37 begin
    D_int[37] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD36 begin
    D_int[36] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD35 begin
    D_int[35] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD34 begin
    D_int[34] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD33 begin
    D_int[33] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD32 begin
    D_int[32] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD31 begin
    D_int[31] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD30 begin
    D_int[30] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD29 begin
    D_int[29] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD28 begin
    D_int[28] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD27 begin
    D_int[27] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD26 begin
    D_int[26] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD25 begin
    D_int[25] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD24 begin
    D_int[24] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD23 begin
    D_int[23] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD22 begin
    D_int[22] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD21 begin
    D_int[21] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD20 begin
    D_int[20] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD19 begin
    D_int[19] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD18 begin
    D_int[18] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD17 begin
    D_int[17] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD16 begin
    D_int[16] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD15 begin
    D_int[15] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD14 begin
    D_int[14] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD13 begin
    D_int[13] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD12 begin
    D_int[12] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD11 begin
    D_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD10 begin
    D_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD9 begin
    D_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD8 begin
    D_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD7 begin
    D_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD6 begin
    D_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD5 begin
    D_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD4 begin
    D_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD3 begin
    D_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD2 begin
    D_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD1 begin
    D_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TD0 begin
    D_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_RET1N begin
    RET1N_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_STOV begin
    STOV_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end

  always @ NOT_CLK_PER begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLK_MINH begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLK_MINL begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end


  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire STOVeq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp;
  wire opopTENeq1andCENeq0cporopTENeq0andTCENeq0cpcp;
  wire opTENeq1andCENeq0cporopTENeq0andTCENeq0cp;

  wire STOVeq0, STOVeq1andEMASeq0, STOVeq1andEMASeq1, TENeq1andCENeq0, TENeq1andCENeq0andWENeq0;
  wire TENeq0andTCENeq0, TENeq0andTCENeq0andTWENeq0, TENeq1, TENeq0;

  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (!EMA[0]) && (!EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (!EMA[0]) && (EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (EMA[0]) && (!EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (EMA[0]) && (EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (!EMA[0]) && (!EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (!EMA[0]) && (EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (EMA[0]) && (!EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (EMA[0]) && (EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (!EMA[0]) && (!EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (!EMA[0]) && (EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (EMA[0]) && (!EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (EMA[0]) && (EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (!EMA[0]) && (!EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (!EMA[0]) && (EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (EMA[0]) && (!EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (EMA[0]) && (EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (STOV) && (!EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp = 
         (STOV) && (EMAS) && ((TEN && WEN) || (!TEN && TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (!EMA[0]) && (!EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (!EMA[0]) && (!EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (!EMA[0]) && (EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (!EMA[0]) && (EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (EMA[0]) && (!EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (EMA[0]) && (!EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (EMA[0]) && (EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (EMA[0]) && (EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (!EMA[0]) && (!EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (!EMA[0]) && (!EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (!EMA[0]) && (EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (!EMA[0]) && (EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (EMA[0]) && (!EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (EMA[0]) && (!EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (EMA[0]) && (EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (EMA[0]) && (EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (!EMA[0]) && (!EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (!EMA[0]) && (!EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (!EMA[0]) && (EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (!EMA[0]) && (EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (EMA[0]) && (!EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (EMA[0]) && (!EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (EMA[0]) && (EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (EMA[0]) && (EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (!EMA[0]) && (!EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (!EMA[0]) && (!EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (!EMA[0]) && (EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (!EMA[0]) && (EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (EMA[0]) && (!EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (EMA[0]) && (!EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (EMA[0]) && (EMAW[1]) && (!EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (EMA[0]) && (EMAW[1]) && (EMAW[0]) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp = 
         (STOV) && ((TEN && !WEN) || (!TEN && !TWEN)) && !(TEN ? CEN : TCEN);
  assign STOVeq1andEMASeq0 = 
         (STOV) && (!EMAS) && !(TEN ? CEN : TCEN);
  assign STOVeq1andEMASeq1 = 
         (STOV) && (EMAS) && !(TEN ? CEN : TCEN);
  assign TENeq1andCENeq0 = 
         !(!TEN || CEN);
  assign TENeq1andCENeq0andWENeq0 = 
         !(!TEN ||  CEN || WEN);
  assign TENeq0andTCENeq0 = 
         !(TEN || TCEN);
  assign TENeq0andTCENeq0andTWENeq0 = 
         !(TEN ||  TCEN || TWEN);
  assign opopTENeq1andCENeq0cporopTENeq0andTCENeq0cpcp = 
         ((TEN ? CEN : TCEN));
  assign opTENeq1andCENeq0cporopTENeq0andTCENeq0cp = 
         !(TEN ? CEN : TCEN);

  assign STOVeq0 = (!STOV) && !(TEN ? CEN : TCEN);
  assign TENeq1 = TEN;
  assign TENeq0 = !TEN;

  specify
    if (CEN == 1'b0 && TCEN == 1'b1)
       (TEN => CENY) = (1.000, 1.000);
    if (CEN == 1'b1 && TCEN == 1'b0)
       (TEN => CENY) = (1.000, 1.000);
    if (TEN == 1'b1)
       (CEN => CENY) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TCEN => CENY) = (1.000, 1.000);
    if (WEN == 1'b0 && TWEN == 1'b1)
       (TEN => WENY) = (1.000, 1.000);
    if (WEN == 1'b1 && TWEN == 1'b0)
       (TEN => WENY) = (1.000, 1.000);
    if (TEN == 1'b1)
       (WEN => WENY) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TWEN => WENY) = (1.000, 1.000);
    if (A[7] == 1'b0 && TA[7] == 1'b1)
       (TEN => AY[7]) = (1.000, 1.000);
    if (A[7] == 1'b1 && TA[7] == 1'b0)
       (TEN => AY[7]) = (1.000, 1.000);
    if (A[6] == 1'b0 && TA[6] == 1'b1)
       (TEN => AY[6]) = (1.000, 1.000);
    if (A[6] == 1'b1 && TA[6] == 1'b0)
       (TEN => AY[6]) = (1.000, 1.000);
    if (A[5] == 1'b0 && TA[5] == 1'b1)
       (TEN => AY[5]) = (1.000, 1.000);
    if (A[5] == 1'b1 && TA[5] == 1'b0)
       (TEN => AY[5]) = (1.000, 1.000);
    if (A[4] == 1'b0 && TA[4] == 1'b1)
       (TEN => AY[4]) = (1.000, 1.000);
    if (A[4] == 1'b1 && TA[4] == 1'b0)
       (TEN => AY[4]) = (1.000, 1.000);
    if (A[3] == 1'b0 && TA[3] == 1'b1)
       (TEN => AY[3]) = (1.000, 1.000);
    if (A[3] == 1'b1 && TA[3] == 1'b0)
       (TEN => AY[3]) = (1.000, 1.000);
    if (A[2] == 1'b0 && TA[2] == 1'b1)
       (TEN => AY[2]) = (1.000, 1.000);
    if (A[2] == 1'b1 && TA[2] == 1'b0)
       (TEN => AY[2]) = (1.000, 1.000);
    if (A[1] == 1'b0 && TA[1] == 1'b1)
       (TEN => AY[1]) = (1.000, 1.000);
    if (A[1] == 1'b1 && TA[1] == 1'b0)
       (TEN => AY[1]) = (1.000, 1.000);
    if (A[0] == 1'b0 && TA[0] == 1'b1)
       (TEN => AY[0]) = (1.000, 1.000);
    if (A[0] == 1'b1 && TA[0] == 1'b0)
       (TEN => AY[0]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[7] => AY[7]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[6] => AY[6]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[5] => AY[5]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[4] => AY[4]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[3] => AY[3]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[2] => AY[2]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[1] => AY[1]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[0] => AY[0]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[7] => AY[7]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[6] => AY[6]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[5] => AY[5]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[4] => AY[4]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[3] => AY[3]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[2] => AY[2]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[1] => AY[1]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[0] => AY[0]) = (1.000, 1.000);
    if (D[79] == 1'b0 && TD[79] == 1'b1)
       (TEN => DY[79]) = (1.000, 1.000);
    if (D[79] == 1'b1 && TD[79] == 1'b0)
       (TEN => DY[79]) = (1.000, 1.000);
    if (D[78] == 1'b0 && TD[78] == 1'b1)
       (TEN => DY[78]) = (1.000, 1.000);
    if (D[78] == 1'b1 && TD[78] == 1'b0)
       (TEN => DY[78]) = (1.000, 1.000);
    if (D[77] == 1'b0 && TD[77] == 1'b1)
       (TEN => DY[77]) = (1.000, 1.000);
    if (D[77] == 1'b1 && TD[77] == 1'b0)
       (TEN => DY[77]) = (1.000, 1.000);
    if (D[76] == 1'b0 && TD[76] == 1'b1)
       (TEN => DY[76]) = (1.000, 1.000);
    if (D[76] == 1'b1 && TD[76] == 1'b0)
       (TEN => DY[76]) = (1.000, 1.000);
    if (D[75] == 1'b0 && TD[75] == 1'b1)
       (TEN => DY[75]) = (1.000, 1.000);
    if (D[75] == 1'b1 && TD[75] == 1'b0)
       (TEN => DY[75]) = (1.000, 1.000);
    if (D[74] == 1'b0 && TD[74] == 1'b1)
       (TEN => DY[74]) = (1.000, 1.000);
    if (D[74] == 1'b1 && TD[74] == 1'b0)
       (TEN => DY[74]) = (1.000, 1.000);
    if (D[73] == 1'b0 && TD[73] == 1'b1)
       (TEN => DY[73]) = (1.000, 1.000);
    if (D[73] == 1'b1 && TD[73] == 1'b0)
       (TEN => DY[73]) = (1.000, 1.000);
    if (D[72] == 1'b0 && TD[72] == 1'b1)
       (TEN => DY[72]) = (1.000, 1.000);
    if (D[72] == 1'b1 && TD[72] == 1'b0)
       (TEN => DY[72]) = (1.000, 1.000);
    if (D[71] == 1'b0 && TD[71] == 1'b1)
       (TEN => DY[71]) = (1.000, 1.000);
    if (D[71] == 1'b1 && TD[71] == 1'b0)
       (TEN => DY[71]) = (1.000, 1.000);
    if (D[70] == 1'b0 && TD[70] == 1'b1)
       (TEN => DY[70]) = (1.000, 1.000);
    if (D[70] == 1'b1 && TD[70] == 1'b0)
       (TEN => DY[70]) = (1.000, 1.000);
    if (D[69] == 1'b0 && TD[69] == 1'b1)
       (TEN => DY[69]) = (1.000, 1.000);
    if (D[69] == 1'b1 && TD[69] == 1'b0)
       (TEN => DY[69]) = (1.000, 1.000);
    if (D[68] == 1'b0 && TD[68] == 1'b1)
       (TEN => DY[68]) = (1.000, 1.000);
    if (D[68] == 1'b1 && TD[68] == 1'b0)
       (TEN => DY[68]) = (1.000, 1.000);
    if (D[67] == 1'b0 && TD[67] == 1'b1)
       (TEN => DY[67]) = (1.000, 1.000);
    if (D[67] == 1'b1 && TD[67] == 1'b0)
       (TEN => DY[67]) = (1.000, 1.000);
    if (D[66] == 1'b0 && TD[66] == 1'b1)
       (TEN => DY[66]) = (1.000, 1.000);
    if (D[66] == 1'b1 && TD[66] == 1'b0)
       (TEN => DY[66]) = (1.000, 1.000);
    if (D[65] == 1'b0 && TD[65] == 1'b1)
       (TEN => DY[65]) = (1.000, 1.000);
    if (D[65] == 1'b1 && TD[65] == 1'b0)
       (TEN => DY[65]) = (1.000, 1.000);
    if (D[64] == 1'b0 && TD[64] == 1'b1)
       (TEN => DY[64]) = (1.000, 1.000);
    if (D[64] == 1'b1 && TD[64] == 1'b0)
       (TEN => DY[64]) = (1.000, 1.000);
    if (D[63] == 1'b0 && TD[63] == 1'b1)
       (TEN => DY[63]) = (1.000, 1.000);
    if (D[63] == 1'b1 && TD[63] == 1'b0)
       (TEN => DY[63]) = (1.000, 1.000);
    if (D[62] == 1'b0 && TD[62] == 1'b1)
       (TEN => DY[62]) = (1.000, 1.000);
    if (D[62] == 1'b1 && TD[62] == 1'b0)
       (TEN => DY[62]) = (1.000, 1.000);
    if (D[61] == 1'b0 && TD[61] == 1'b1)
       (TEN => DY[61]) = (1.000, 1.000);
    if (D[61] == 1'b1 && TD[61] == 1'b0)
       (TEN => DY[61]) = (1.000, 1.000);
    if (D[60] == 1'b0 && TD[60] == 1'b1)
       (TEN => DY[60]) = (1.000, 1.000);
    if (D[60] == 1'b1 && TD[60] == 1'b0)
       (TEN => DY[60]) = (1.000, 1.000);
    if (D[59] == 1'b0 && TD[59] == 1'b1)
       (TEN => DY[59]) = (1.000, 1.000);
    if (D[59] == 1'b1 && TD[59] == 1'b0)
       (TEN => DY[59]) = (1.000, 1.000);
    if (D[58] == 1'b0 && TD[58] == 1'b1)
       (TEN => DY[58]) = (1.000, 1.000);
    if (D[58] == 1'b1 && TD[58] == 1'b0)
       (TEN => DY[58]) = (1.000, 1.000);
    if (D[57] == 1'b0 && TD[57] == 1'b1)
       (TEN => DY[57]) = (1.000, 1.000);
    if (D[57] == 1'b1 && TD[57] == 1'b0)
       (TEN => DY[57]) = (1.000, 1.000);
    if (D[56] == 1'b0 && TD[56] == 1'b1)
       (TEN => DY[56]) = (1.000, 1.000);
    if (D[56] == 1'b1 && TD[56] == 1'b0)
       (TEN => DY[56]) = (1.000, 1.000);
    if (D[55] == 1'b0 && TD[55] == 1'b1)
       (TEN => DY[55]) = (1.000, 1.000);
    if (D[55] == 1'b1 && TD[55] == 1'b0)
       (TEN => DY[55]) = (1.000, 1.000);
    if (D[54] == 1'b0 && TD[54] == 1'b1)
       (TEN => DY[54]) = (1.000, 1.000);
    if (D[54] == 1'b1 && TD[54] == 1'b0)
       (TEN => DY[54]) = (1.000, 1.000);
    if (D[53] == 1'b0 && TD[53] == 1'b1)
       (TEN => DY[53]) = (1.000, 1.000);
    if (D[53] == 1'b1 && TD[53] == 1'b0)
       (TEN => DY[53]) = (1.000, 1.000);
    if (D[52] == 1'b0 && TD[52] == 1'b1)
       (TEN => DY[52]) = (1.000, 1.000);
    if (D[52] == 1'b1 && TD[52] == 1'b0)
       (TEN => DY[52]) = (1.000, 1.000);
    if (D[51] == 1'b0 && TD[51] == 1'b1)
       (TEN => DY[51]) = (1.000, 1.000);
    if (D[51] == 1'b1 && TD[51] == 1'b0)
       (TEN => DY[51]) = (1.000, 1.000);
    if (D[50] == 1'b0 && TD[50] == 1'b1)
       (TEN => DY[50]) = (1.000, 1.000);
    if (D[50] == 1'b1 && TD[50] == 1'b0)
       (TEN => DY[50]) = (1.000, 1.000);
    if (D[49] == 1'b0 && TD[49] == 1'b1)
       (TEN => DY[49]) = (1.000, 1.000);
    if (D[49] == 1'b1 && TD[49] == 1'b0)
       (TEN => DY[49]) = (1.000, 1.000);
    if (D[48] == 1'b0 && TD[48] == 1'b1)
       (TEN => DY[48]) = (1.000, 1.000);
    if (D[48] == 1'b1 && TD[48] == 1'b0)
       (TEN => DY[48]) = (1.000, 1.000);
    if (D[47] == 1'b0 && TD[47] == 1'b1)
       (TEN => DY[47]) = (1.000, 1.000);
    if (D[47] == 1'b1 && TD[47] == 1'b0)
       (TEN => DY[47]) = (1.000, 1.000);
    if (D[46] == 1'b0 && TD[46] == 1'b1)
       (TEN => DY[46]) = (1.000, 1.000);
    if (D[46] == 1'b1 && TD[46] == 1'b0)
       (TEN => DY[46]) = (1.000, 1.000);
    if (D[45] == 1'b0 && TD[45] == 1'b1)
       (TEN => DY[45]) = (1.000, 1.000);
    if (D[45] == 1'b1 && TD[45] == 1'b0)
       (TEN => DY[45]) = (1.000, 1.000);
    if (D[44] == 1'b0 && TD[44] == 1'b1)
       (TEN => DY[44]) = (1.000, 1.000);
    if (D[44] == 1'b1 && TD[44] == 1'b0)
       (TEN => DY[44]) = (1.000, 1.000);
    if (D[43] == 1'b0 && TD[43] == 1'b1)
       (TEN => DY[43]) = (1.000, 1.000);
    if (D[43] == 1'b1 && TD[43] == 1'b0)
       (TEN => DY[43]) = (1.000, 1.000);
    if (D[42] == 1'b0 && TD[42] == 1'b1)
       (TEN => DY[42]) = (1.000, 1.000);
    if (D[42] == 1'b1 && TD[42] == 1'b0)
       (TEN => DY[42]) = (1.000, 1.000);
    if (D[41] == 1'b0 && TD[41] == 1'b1)
       (TEN => DY[41]) = (1.000, 1.000);
    if (D[41] == 1'b1 && TD[41] == 1'b0)
       (TEN => DY[41]) = (1.000, 1.000);
    if (D[40] == 1'b0 && TD[40] == 1'b1)
       (TEN => DY[40]) = (1.000, 1.000);
    if (D[40] == 1'b1 && TD[40] == 1'b0)
       (TEN => DY[40]) = (1.000, 1.000);
    if (D[39] == 1'b0 && TD[39] == 1'b1)
       (TEN => DY[39]) = (1.000, 1.000);
    if (D[39] == 1'b1 && TD[39] == 1'b0)
       (TEN => DY[39]) = (1.000, 1.000);
    if (D[38] == 1'b0 && TD[38] == 1'b1)
       (TEN => DY[38]) = (1.000, 1.000);
    if (D[38] == 1'b1 && TD[38] == 1'b0)
       (TEN => DY[38]) = (1.000, 1.000);
    if (D[37] == 1'b0 && TD[37] == 1'b1)
       (TEN => DY[37]) = (1.000, 1.000);
    if (D[37] == 1'b1 && TD[37] == 1'b0)
       (TEN => DY[37]) = (1.000, 1.000);
    if (D[36] == 1'b0 && TD[36] == 1'b1)
       (TEN => DY[36]) = (1.000, 1.000);
    if (D[36] == 1'b1 && TD[36] == 1'b0)
       (TEN => DY[36]) = (1.000, 1.000);
    if (D[35] == 1'b0 && TD[35] == 1'b1)
       (TEN => DY[35]) = (1.000, 1.000);
    if (D[35] == 1'b1 && TD[35] == 1'b0)
       (TEN => DY[35]) = (1.000, 1.000);
    if (D[34] == 1'b0 && TD[34] == 1'b1)
       (TEN => DY[34]) = (1.000, 1.000);
    if (D[34] == 1'b1 && TD[34] == 1'b0)
       (TEN => DY[34]) = (1.000, 1.000);
    if (D[33] == 1'b0 && TD[33] == 1'b1)
       (TEN => DY[33]) = (1.000, 1.000);
    if (D[33] == 1'b1 && TD[33] == 1'b0)
       (TEN => DY[33]) = (1.000, 1.000);
    if (D[32] == 1'b0 && TD[32] == 1'b1)
       (TEN => DY[32]) = (1.000, 1.000);
    if (D[32] == 1'b1 && TD[32] == 1'b0)
       (TEN => DY[32]) = (1.000, 1.000);
    if (D[31] == 1'b0 && TD[31] == 1'b1)
       (TEN => DY[31]) = (1.000, 1.000);
    if (D[31] == 1'b1 && TD[31] == 1'b0)
       (TEN => DY[31]) = (1.000, 1.000);
    if (D[30] == 1'b0 && TD[30] == 1'b1)
       (TEN => DY[30]) = (1.000, 1.000);
    if (D[30] == 1'b1 && TD[30] == 1'b0)
       (TEN => DY[30]) = (1.000, 1.000);
    if (D[29] == 1'b0 && TD[29] == 1'b1)
       (TEN => DY[29]) = (1.000, 1.000);
    if (D[29] == 1'b1 && TD[29] == 1'b0)
       (TEN => DY[29]) = (1.000, 1.000);
    if (D[28] == 1'b0 && TD[28] == 1'b1)
       (TEN => DY[28]) = (1.000, 1.000);
    if (D[28] == 1'b1 && TD[28] == 1'b0)
       (TEN => DY[28]) = (1.000, 1.000);
    if (D[27] == 1'b0 && TD[27] == 1'b1)
       (TEN => DY[27]) = (1.000, 1.000);
    if (D[27] == 1'b1 && TD[27] == 1'b0)
       (TEN => DY[27]) = (1.000, 1.000);
    if (D[26] == 1'b0 && TD[26] == 1'b1)
       (TEN => DY[26]) = (1.000, 1.000);
    if (D[26] == 1'b1 && TD[26] == 1'b0)
       (TEN => DY[26]) = (1.000, 1.000);
    if (D[25] == 1'b0 && TD[25] == 1'b1)
       (TEN => DY[25]) = (1.000, 1.000);
    if (D[25] == 1'b1 && TD[25] == 1'b0)
       (TEN => DY[25]) = (1.000, 1.000);
    if (D[24] == 1'b0 && TD[24] == 1'b1)
       (TEN => DY[24]) = (1.000, 1.000);
    if (D[24] == 1'b1 && TD[24] == 1'b0)
       (TEN => DY[24]) = (1.000, 1.000);
    if (D[23] == 1'b0 && TD[23] == 1'b1)
       (TEN => DY[23]) = (1.000, 1.000);
    if (D[23] == 1'b1 && TD[23] == 1'b0)
       (TEN => DY[23]) = (1.000, 1.000);
    if (D[22] == 1'b0 && TD[22] == 1'b1)
       (TEN => DY[22]) = (1.000, 1.000);
    if (D[22] == 1'b1 && TD[22] == 1'b0)
       (TEN => DY[22]) = (1.000, 1.000);
    if (D[21] == 1'b0 && TD[21] == 1'b1)
       (TEN => DY[21]) = (1.000, 1.000);
    if (D[21] == 1'b1 && TD[21] == 1'b0)
       (TEN => DY[21]) = (1.000, 1.000);
    if (D[20] == 1'b0 && TD[20] == 1'b1)
       (TEN => DY[20]) = (1.000, 1.000);
    if (D[20] == 1'b1 && TD[20] == 1'b0)
       (TEN => DY[20]) = (1.000, 1.000);
    if (D[19] == 1'b0 && TD[19] == 1'b1)
       (TEN => DY[19]) = (1.000, 1.000);
    if (D[19] == 1'b1 && TD[19] == 1'b0)
       (TEN => DY[19]) = (1.000, 1.000);
    if (D[18] == 1'b0 && TD[18] == 1'b1)
       (TEN => DY[18]) = (1.000, 1.000);
    if (D[18] == 1'b1 && TD[18] == 1'b0)
       (TEN => DY[18]) = (1.000, 1.000);
    if (D[17] == 1'b0 && TD[17] == 1'b1)
       (TEN => DY[17]) = (1.000, 1.000);
    if (D[17] == 1'b1 && TD[17] == 1'b0)
       (TEN => DY[17]) = (1.000, 1.000);
    if (D[16] == 1'b0 && TD[16] == 1'b1)
       (TEN => DY[16]) = (1.000, 1.000);
    if (D[16] == 1'b1 && TD[16] == 1'b0)
       (TEN => DY[16]) = (1.000, 1.000);
    if (D[15] == 1'b0 && TD[15] == 1'b1)
       (TEN => DY[15]) = (1.000, 1.000);
    if (D[15] == 1'b1 && TD[15] == 1'b0)
       (TEN => DY[15]) = (1.000, 1.000);
    if (D[14] == 1'b0 && TD[14] == 1'b1)
       (TEN => DY[14]) = (1.000, 1.000);
    if (D[14] == 1'b1 && TD[14] == 1'b0)
       (TEN => DY[14]) = (1.000, 1.000);
    if (D[13] == 1'b0 && TD[13] == 1'b1)
       (TEN => DY[13]) = (1.000, 1.000);
    if (D[13] == 1'b1 && TD[13] == 1'b0)
       (TEN => DY[13]) = (1.000, 1.000);
    if (D[12] == 1'b0 && TD[12] == 1'b1)
       (TEN => DY[12]) = (1.000, 1.000);
    if (D[12] == 1'b1 && TD[12] == 1'b0)
       (TEN => DY[12]) = (1.000, 1.000);
    if (D[11] == 1'b0 && TD[11] == 1'b1)
       (TEN => DY[11]) = (1.000, 1.000);
    if (D[11] == 1'b1 && TD[11] == 1'b0)
       (TEN => DY[11]) = (1.000, 1.000);
    if (D[10] == 1'b0 && TD[10] == 1'b1)
       (TEN => DY[10]) = (1.000, 1.000);
    if (D[10] == 1'b1 && TD[10] == 1'b0)
       (TEN => DY[10]) = (1.000, 1.000);
    if (D[9] == 1'b0 && TD[9] == 1'b1)
       (TEN => DY[9]) = (1.000, 1.000);
    if (D[9] == 1'b1 && TD[9] == 1'b0)
       (TEN => DY[9]) = (1.000, 1.000);
    if (D[8] == 1'b0 && TD[8] == 1'b1)
       (TEN => DY[8]) = (1.000, 1.000);
    if (D[8] == 1'b1 && TD[8] == 1'b0)
       (TEN => DY[8]) = (1.000, 1.000);
    if (D[7] == 1'b0 && TD[7] == 1'b1)
       (TEN => DY[7]) = (1.000, 1.000);
    if (D[7] == 1'b1 && TD[7] == 1'b0)
       (TEN => DY[7]) = (1.000, 1.000);
    if (D[6] == 1'b0 && TD[6] == 1'b1)
       (TEN => DY[6]) = (1.000, 1.000);
    if (D[6] == 1'b1 && TD[6] == 1'b0)
       (TEN => DY[6]) = (1.000, 1.000);
    if (D[5] == 1'b0 && TD[5] == 1'b1)
       (TEN => DY[5]) = (1.000, 1.000);
    if (D[5] == 1'b1 && TD[5] == 1'b0)
       (TEN => DY[5]) = (1.000, 1.000);
    if (D[4] == 1'b0 && TD[4] == 1'b1)
       (TEN => DY[4]) = (1.000, 1.000);
    if (D[4] == 1'b1 && TD[4] == 1'b0)
       (TEN => DY[4]) = (1.000, 1.000);
    if (D[3] == 1'b0 && TD[3] == 1'b1)
       (TEN => DY[3]) = (1.000, 1.000);
    if (D[3] == 1'b1 && TD[3] == 1'b0)
       (TEN => DY[3]) = (1.000, 1.000);
    if (D[2] == 1'b0 && TD[2] == 1'b1)
       (TEN => DY[2]) = (1.000, 1.000);
    if (D[2] == 1'b1 && TD[2] == 1'b0)
       (TEN => DY[2]) = (1.000, 1.000);
    if (D[1] == 1'b0 && TD[1] == 1'b1)
       (TEN => DY[1]) = (1.000, 1.000);
    if (D[1] == 1'b1 && TD[1] == 1'b0)
       (TEN => DY[1]) = (1.000, 1.000);
    if (D[0] == 1'b0 && TD[0] == 1'b1)
       (TEN => DY[0]) = (1.000, 1.000);
    if (D[0] == 1'b1 && TD[0] == 1'b0)
       (TEN => DY[0]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[79] => DY[79]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[78] => DY[78]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[77] => DY[77]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[76] => DY[76]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[75] => DY[75]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[74] => DY[74]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[73] => DY[73]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[72] => DY[72]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[71] => DY[71]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[70] => DY[70]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[69] => DY[69]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[68] => DY[68]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[67] => DY[67]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[66] => DY[66]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[65] => DY[65]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[64] => DY[64]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[63] => DY[63]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[62] => DY[62]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[61] => DY[61]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[60] => DY[60]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[59] => DY[59]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[58] => DY[58]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[57] => DY[57]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[56] => DY[56]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[55] => DY[55]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[54] => DY[54]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[53] => DY[53]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[52] => DY[52]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[51] => DY[51]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[50] => DY[50]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[49] => DY[49]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[48] => DY[48]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[47] => DY[47]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[46] => DY[46]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[45] => DY[45]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[44] => DY[44]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[43] => DY[43]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[42] => DY[42]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[41] => DY[41]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[40] => DY[40]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[39] => DY[39]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[38] => DY[38]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[37] => DY[37]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[36] => DY[36]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[35] => DY[35]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[34] => DY[34]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[33] => DY[33]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[32] => DY[32]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[31] => DY[31]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[30] => DY[30]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[29] => DY[29]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[28] => DY[28]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[27] => DY[27]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[26] => DY[26]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[25] => DY[25]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[24] => DY[24]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[23] => DY[23]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[22] => DY[22]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[21] => DY[21]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[20] => DY[20]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[19] => DY[19]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[18] => DY[18]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[17] => DY[17]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[16] => DY[16]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[15] => DY[15]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[14] => DY[14]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[13] => DY[13]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[12] => DY[12]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[11] => DY[11]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[10] => DY[10]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[9] => DY[9]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[8] => DY[8]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[7] => DY[7]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[6] => DY[6]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[5] => DY[5]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[4] => DY[4]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[3] => DY[3]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[2] => DY[2]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[1] => DY[1]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (D[0] => DY[0]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[79] => DY[79]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[78] => DY[78]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[77] => DY[77]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[76] => DY[76]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[75] => DY[75]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[74] => DY[74]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[73] => DY[73]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[72] => DY[72]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[71] => DY[71]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[70] => DY[70]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[69] => DY[69]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[68] => DY[68]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[67] => DY[67]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[66] => DY[66]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[65] => DY[65]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[64] => DY[64]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[63] => DY[63]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[62] => DY[62]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[61] => DY[61]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[60] => DY[60]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[59] => DY[59]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[58] => DY[58]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[57] => DY[57]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[56] => DY[56]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[55] => DY[55]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[54] => DY[54]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[53] => DY[53]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[52] => DY[52]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[51] => DY[51]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[50] => DY[50]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[49] => DY[49]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[48] => DY[48]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[47] => DY[47]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[46] => DY[46]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[45] => DY[45]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[44] => DY[44]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[43] => DY[43]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[42] => DY[42]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[41] => DY[41]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[40] => DY[40]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[39] => DY[39]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[38] => DY[38]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[37] => DY[37]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[36] => DY[36]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[35] => DY[35]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[34] => DY[34]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[33] => DY[33]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[32] => DY[32]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[31] => DY[31]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[30] => DY[30]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[29] => DY[29]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[28] => DY[28]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[27] => DY[27]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[26] => DY[26]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[25] => DY[25]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[24] => DY[24]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[23] => DY[23]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[22] => DY[22]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[21] => DY[21]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[20] => DY[20]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[19] => DY[19]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[18] => DY[18]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[17] => DY[17]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[16] => DY[16]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[15] => DY[15]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[14] => DY[14]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[13] => DY[13]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[12] => DY[12]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[11] => DY[11]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[10] => DY[10]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[9] => DY[9]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[8] => DY[8]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[7] => DY[7]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[6] => DY[6]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[5] => DY[5]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[4] => DY[4]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[3] => DY[3]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[2] => DY[2]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[1] => DY[1]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TD[0] => DY[0]) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b1) || (TEN == 1'b0 && TWEN == 1'b1)))
       (negedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b0 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BEN == 1'b1 && STOV == 1'b1 && ((TEN == 1'b1 && WEN == 1'b0) || (TEN == 1'b0 && TWEN == 1'b0)))
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (TQ[79] == 1'b1)
       (BEN => Q[79]) = (1.000, 1.000);
    if (TQ[79] == 1'b0)
       (BEN => Q[79]) = (1.000, 1.000);
    if (TQ[78] == 1'b1)
       (BEN => Q[78]) = (1.000, 1.000);
    if (TQ[78] == 1'b0)
       (BEN => Q[78]) = (1.000, 1.000);
    if (TQ[77] == 1'b1)
       (BEN => Q[77]) = (1.000, 1.000);
    if (TQ[77] == 1'b0)
       (BEN => Q[77]) = (1.000, 1.000);
    if (TQ[76] == 1'b1)
       (BEN => Q[76]) = (1.000, 1.000);
    if (TQ[76] == 1'b0)
       (BEN => Q[76]) = (1.000, 1.000);
    if (TQ[75] == 1'b1)
       (BEN => Q[75]) = (1.000, 1.000);
    if (TQ[75] == 1'b0)
       (BEN => Q[75]) = (1.000, 1.000);
    if (TQ[74] == 1'b1)
       (BEN => Q[74]) = (1.000, 1.000);
    if (TQ[74] == 1'b0)
       (BEN => Q[74]) = (1.000, 1.000);
    if (TQ[73] == 1'b1)
       (BEN => Q[73]) = (1.000, 1.000);
    if (TQ[73] == 1'b0)
       (BEN => Q[73]) = (1.000, 1.000);
    if (TQ[72] == 1'b1)
       (BEN => Q[72]) = (1.000, 1.000);
    if (TQ[72] == 1'b0)
       (BEN => Q[72]) = (1.000, 1.000);
    if (TQ[71] == 1'b1)
       (BEN => Q[71]) = (1.000, 1.000);
    if (TQ[71] == 1'b0)
       (BEN => Q[71]) = (1.000, 1.000);
    if (TQ[70] == 1'b1)
       (BEN => Q[70]) = (1.000, 1.000);
    if (TQ[70] == 1'b0)
       (BEN => Q[70]) = (1.000, 1.000);
    if (TQ[69] == 1'b1)
       (BEN => Q[69]) = (1.000, 1.000);
    if (TQ[69] == 1'b0)
       (BEN => Q[69]) = (1.000, 1.000);
    if (TQ[68] == 1'b1)
       (BEN => Q[68]) = (1.000, 1.000);
    if (TQ[68] == 1'b0)
       (BEN => Q[68]) = (1.000, 1.000);
    if (TQ[67] == 1'b1)
       (BEN => Q[67]) = (1.000, 1.000);
    if (TQ[67] == 1'b0)
       (BEN => Q[67]) = (1.000, 1.000);
    if (TQ[66] == 1'b1)
       (BEN => Q[66]) = (1.000, 1.000);
    if (TQ[66] == 1'b0)
       (BEN => Q[66]) = (1.000, 1.000);
    if (TQ[65] == 1'b1)
       (BEN => Q[65]) = (1.000, 1.000);
    if (TQ[65] == 1'b0)
       (BEN => Q[65]) = (1.000, 1.000);
    if (TQ[64] == 1'b1)
       (BEN => Q[64]) = (1.000, 1.000);
    if (TQ[64] == 1'b0)
       (BEN => Q[64]) = (1.000, 1.000);
    if (TQ[63] == 1'b1)
       (BEN => Q[63]) = (1.000, 1.000);
    if (TQ[63] == 1'b0)
       (BEN => Q[63]) = (1.000, 1.000);
    if (TQ[62] == 1'b1)
       (BEN => Q[62]) = (1.000, 1.000);
    if (TQ[62] == 1'b0)
       (BEN => Q[62]) = (1.000, 1.000);
    if (TQ[61] == 1'b1)
       (BEN => Q[61]) = (1.000, 1.000);
    if (TQ[61] == 1'b0)
       (BEN => Q[61]) = (1.000, 1.000);
    if (TQ[60] == 1'b1)
       (BEN => Q[60]) = (1.000, 1.000);
    if (TQ[60] == 1'b0)
       (BEN => Q[60]) = (1.000, 1.000);
    if (TQ[59] == 1'b1)
       (BEN => Q[59]) = (1.000, 1.000);
    if (TQ[59] == 1'b0)
       (BEN => Q[59]) = (1.000, 1.000);
    if (TQ[58] == 1'b1)
       (BEN => Q[58]) = (1.000, 1.000);
    if (TQ[58] == 1'b0)
       (BEN => Q[58]) = (1.000, 1.000);
    if (TQ[57] == 1'b1)
       (BEN => Q[57]) = (1.000, 1.000);
    if (TQ[57] == 1'b0)
       (BEN => Q[57]) = (1.000, 1.000);
    if (TQ[56] == 1'b1)
       (BEN => Q[56]) = (1.000, 1.000);
    if (TQ[56] == 1'b0)
       (BEN => Q[56]) = (1.000, 1.000);
    if (TQ[55] == 1'b1)
       (BEN => Q[55]) = (1.000, 1.000);
    if (TQ[55] == 1'b0)
       (BEN => Q[55]) = (1.000, 1.000);
    if (TQ[54] == 1'b1)
       (BEN => Q[54]) = (1.000, 1.000);
    if (TQ[54] == 1'b0)
       (BEN => Q[54]) = (1.000, 1.000);
    if (TQ[53] == 1'b1)
       (BEN => Q[53]) = (1.000, 1.000);
    if (TQ[53] == 1'b0)
       (BEN => Q[53]) = (1.000, 1.000);
    if (TQ[52] == 1'b1)
       (BEN => Q[52]) = (1.000, 1.000);
    if (TQ[52] == 1'b0)
       (BEN => Q[52]) = (1.000, 1.000);
    if (TQ[51] == 1'b1)
       (BEN => Q[51]) = (1.000, 1.000);
    if (TQ[51] == 1'b0)
       (BEN => Q[51]) = (1.000, 1.000);
    if (TQ[50] == 1'b1)
       (BEN => Q[50]) = (1.000, 1.000);
    if (TQ[50] == 1'b0)
       (BEN => Q[50]) = (1.000, 1.000);
    if (TQ[49] == 1'b1)
       (BEN => Q[49]) = (1.000, 1.000);
    if (TQ[49] == 1'b0)
       (BEN => Q[49]) = (1.000, 1.000);
    if (TQ[48] == 1'b1)
       (BEN => Q[48]) = (1.000, 1.000);
    if (TQ[48] == 1'b0)
       (BEN => Q[48]) = (1.000, 1.000);
    if (TQ[47] == 1'b1)
       (BEN => Q[47]) = (1.000, 1.000);
    if (TQ[47] == 1'b0)
       (BEN => Q[47]) = (1.000, 1.000);
    if (TQ[46] == 1'b1)
       (BEN => Q[46]) = (1.000, 1.000);
    if (TQ[46] == 1'b0)
       (BEN => Q[46]) = (1.000, 1.000);
    if (TQ[45] == 1'b1)
       (BEN => Q[45]) = (1.000, 1.000);
    if (TQ[45] == 1'b0)
       (BEN => Q[45]) = (1.000, 1.000);
    if (TQ[44] == 1'b1)
       (BEN => Q[44]) = (1.000, 1.000);
    if (TQ[44] == 1'b0)
       (BEN => Q[44]) = (1.000, 1.000);
    if (TQ[43] == 1'b1)
       (BEN => Q[43]) = (1.000, 1.000);
    if (TQ[43] == 1'b0)
       (BEN => Q[43]) = (1.000, 1.000);
    if (TQ[42] == 1'b1)
       (BEN => Q[42]) = (1.000, 1.000);
    if (TQ[42] == 1'b0)
       (BEN => Q[42]) = (1.000, 1.000);
    if (TQ[41] == 1'b1)
       (BEN => Q[41]) = (1.000, 1.000);
    if (TQ[41] == 1'b0)
       (BEN => Q[41]) = (1.000, 1.000);
    if (TQ[40] == 1'b1)
       (BEN => Q[40]) = (1.000, 1.000);
    if (TQ[40] == 1'b0)
       (BEN => Q[40]) = (1.000, 1.000);
    if (TQ[39] == 1'b1)
       (BEN => Q[39]) = (1.000, 1.000);
    if (TQ[39] == 1'b0)
       (BEN => Q[39]) = (1.000, 1.000);
    if (TQ[38] == 1'b1)
       (BEN => Q[38]) = (1.000, 1.000);
    if (TQ[38] == 1'b0)
       (BEN => Q[38]) = (1.000, 1.000);
    if (TQ[37] == 1'b1)
       (BEN => Q[37]) = (1.000, 1.000);
    if (TQ[37] == 1'b0)
       (BEN => Q[37]) = (1.000, 1.000);
    if (TQ[36] == 1'b1)
       (BEN => Q[36]) = (1.000, 1.000);
    if (TQ[36] == 1'b0)
       (BEN => Q[36]) = (1.000, 1.000);
    if (TQ[35] == 1'b1)
       (BEN => Q[35]) = (1.000, 1.000);
    if (TQ[35] == 1'b0)
       (BEN => Q[35]) = (1.000, 1.000);
    if (TQ[34] == 1'b1)
       (BEN => Q[34]) = (1.000, 1.000);
    if (TQ[34] == 1'b0)
       (BEN => Q[34]) = (1.000, 1.000);
    if (TQ[33] == 1'b1)
       (BEN => Q[33]) = (1.000, 1.000);
    if (TQ[33] == 1'b0)
       (BEN => Q[33]) = (1.000, 1.000);
    if (TQ[32] == 1'b1)
       (BEN => Q[32]) = (1.000, 1.000);
    if (TQ[32] == 1'b0)
       (BEN => Q[32]) = (1.000, 1.000);
    if (TQ[31] == 1'b1)
       (BEN => Q[31]) = (1.000, 1.000);
    if (TQ[31] == 1'b0)
       (BEN => Q[31]) = (1.000, 1.000);
    if (TQ[30] == 1'b1)
       (BEN => Q[30]) = (1.000, 1.000);
    if (TQ[30] == 1'b0)
       (BEN => Q[30]) = (1.000, 1.000);
    if (TQ[29] == 1'b1)
       (BEN => Q[29]) = (1.000, 1.000);
    if (TQ[29] == 1'b0)
       (BEN => Q[29]) = (1.000, 1.000);
    if (TQ[28] == 1'b1)
       (BEN => Q[28]) = (1.000, 1.000);
    if (TQ[28] == 1'b0)
       (BEN => Q[28]) = (1.000, 1.000);
    if (TQ[27] == 1'b1)
       (BEN => Q[27]) = (1.000, 1.000);
    if (TQ[27] == 1'b0)
       (BEN => Q[27]) = (1.000, 1.000);
    if (TQ[26] == 1'b1)
       (BEN => Q[26]) = (1.000, 1.000);
    if (TQ[26] == 1'b0)
       (BEN => Q[26]) = (1.000, 1.000);
    if (TQ[25] == 1'b1)
       (BEN => Q[25]) = (1.000, 1.000);
    if (TQ[25] == 1'b0)
       (BEN => Q[25]) = (1.000, 1.000);
    if (TQ[24] == 1'b1)
       (BEN => Q[24]) = (1.000, 1.000);
    if (TQ[24] == 1'b0)
       (BEN => Q[24]) = (1.000, 1.000);
    if (TQ[23] == 1'b1)
       (BEN => Q[23]) = (1.000, 1.000);
    if (TQ[23] == 1'b0)
       (BEN => Q[23]) = (1.000, 1.000);
    if (TQ[22] == 1'b1)
       (BEN => Q[22]) = (1.000, 1.000);
    if (TQ[22] == 1'b0)
       (BEN => Q[22]) = (1.000, 1.000);
    if (TQ[21] == 1'b1)
       (BEN => Q[21]) = (1.000, 1.000);
    if (TQ[21] == 1'b0)
       (BEN => Q[21]) = (1.000, 1.000);
    if (TQ[20] == 1'b1)
       (BEN => Q[20]) = (1.000, 1.000);
    if (TQ[20] == 1'b0)
       (BEN => Q[20]) = (1.000, 1.000);
    if (TQ[19] == 1'b1)
       (BEN => Q[19]) = (1.000, 1.000);
    if (TQ[19] == 1'b0)
       (BEN => Q[19]) = (1.000, 1.000);
    if (TQ[18] == 1'b1)
       (BEN => Q[18]) = (1.000, 1.000);
    if (TQ[18] == 1'b0)
       (BEN => Q[18]) = (1.000, 1.000);
    if (TQ[17] == 1'b1)
       (BEN => Q[17]) = (1.000, 1.000);
    if (TQ[17] == 1'b0)
       (BEN => Q[17]) = (1.000, 1.000);
    if (TQ[16] == 1'b1)
       (BEN => Q[16]) = (1.000, 1.000);
    if (TQ[16] == 1'b0)
       (BEN => Q[16]) = (1.000, 1.000);
    if (TQ[15] == 1'b1)
       (BEN => Q[15]) = (1.000, 1.000);
    if (TQ[15] == 1'b0)
       (BEN => Q[15]) = (1.000, 1.000);
    if (TQ[14] == 1'b1)
       (BEN => Q[14]) = (1.000, 1.000);
    if (TQ[14] == 1'b0)
       (BEN => Q[14]) = (1.000, 1.000);
    if (TQ[13] == 1'b1)
       (BEN => Q[13]) = (1.000, 1.000);
    if (TQ[13] == 1'b0)
       (BEN => Q[13]) = (1.000, 1.000);
    if (TQ[12] == 1'b1)
       (BEN => Q[12]) = (1.000, 1.000);
    if (TQ[12] == 1'b0)
       (BEN => Q[12]) = (1.000, 1.000);
    if (TQ[11] == 1'b1)
       (BEN => Q[11]) = (1.000, 1.000);
    if (TQ[11] == 1'b0)
       (BEN => Q[11]) = (1.000, 1.000);
    if (TQ[10] == 1'b1)
       (BEN => Q[10]) = (1.000, 1.000);
    if (TQ[10] == 1'b0)
       (BEN => Q[10]) = (1.000, 1.000);
    if (TQ[9] == 1'b1)
       (BEN => Q[9]) = (1.000, 1.000);
    if (TQ[9] == 1'b0)
       (BEN => Q[9]) = (1.000, 1.000);
    if (TQ[8] == 1'b1)
       (BEN => Q[8]) = (1.000, 1.000);
    if (TQ[8] == 1'b0)
       (BEN => Q[8]) = (1.000, 1.000);
    if (TQ[7] == 1'b1)
       (BEN => Q[7]) = (1.000, 1.000);
    if (TQ[7] == 1'b0)
       (BEN => Q[7]) = (1.000, 1.000);
    if (TQ[6] == 1'b1)
       (BEN => Q[6]) = (1.000, 1.000);
    if (TQ[6] == 1'b0)
       (BEN => Q[6]) = (1.000, 1.000);
    if (TQ[5] == 1'b1)
       (BEN => Q[5]) = (1.000, 1.000);
    if (TQ[5] == 1'b0)
       (BEN => Q[5]) = (1.000, 1.000);
    if (TQ[4] == 1'b1)
       (BEN => Q[4]) = (1.000, 1.000);
    if (TQ[4] == 1'b0)
       (BEN => Q[4]) = (1.000, 1.000);
    if (TQ[3] == 1'b1)
       (BEN => Q[3]) = (1.000, 1.000);
    if (TQ[3] == 1'b0)
       (BEN => Q[3]) = (1.000, 1.000);
    if (TQ[2] == 1'b1)
       (BEN => Q[2]) = (1.000, 1.000);
    if (TQ[2] == 1'b0)
       (BEN => Q[2]) = (1.000, 1.000);
    if (TQ[1] == 1'b1)
       (BEN => Q[1]) = (1.000, 1.000);
    if (TQ[1] == 1'b0)
       (BEN => Q[1]) = (1.000, 1.000);
    if (TQ[0] == 1'b1)
       (BEN => Q[0]) = (1.000, 1.000);
    if (TQ[0] == 1'b0)
       (BEN => Q[0]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[79] => Q[79]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[78] => Q[78]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[77] => Q[77]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[76] => Q[76]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[75] => Q[75]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[74] => Q[74]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[73] => Q[73]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[72] => Q[72]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[71] => Q[71]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[70] => Q[70]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[69] => Q[69]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[68] => Q[68]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[67] => Q[67]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[66] => Q[66]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[65] => Q[65]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[64] => Q[64]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[63] => Q[63]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[62] => Q[62]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[61] => Q[61]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[60] => Q[60]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[59] => Q[59]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[58] => Q[58]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[57] => Q[57]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[56] => Q[56]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[55] => Q[55]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[54] => Q[54]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[53] => Q[53]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[52] => Q[52]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[51] => Q[51]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[50] => Q[50]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[49] => Q[49]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[48] => Q[48]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[47] => Q[47]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[46] => Q[46]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[45] => Q[45]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[44] => Q[44]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[43] => Q[43]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[42] => Q[42]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[41] => Q[41]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[40] => Q[40]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[39] => Q[39]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[38] => Q[38]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[37] => Q[37]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[36] => Q[36]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[35] => Q[35]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[34] => Q[34]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[33] => Q[33]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[32] => Q[32]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[31] => Q[31]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[30] => Q[30]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[29] => Q[29]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[28] => Q[28]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[27] => Q[27]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[26] => Q[26]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[25] => Q[25]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[24] => Q[24]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[23] => Q[23]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[22] => Q[22]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[21] => Q[21]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[20] => Q[20]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[19] => Q[19]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[18] => Q[18]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[17] => Q[17]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[16] => Q[16]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[15] => Q[15]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[14] => Q[14]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[13] => Q[13]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[12] => Q[12]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[11] => Q[11]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[10] => Q[10]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[9] => Q[9]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[8] => Q[8]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[7] => Q[7]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[6] => Q[6]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[5] => Q[5]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[4] => Q[4]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[3] => Q[3]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[2] => Q[2]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[1] => Q[1]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[0] => Q[0]) = (1.000, 1.000);

// Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge CLK, 3.000, NOT_CLK_PER);
   `else
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(negedge CLK &&& STOVeq1andEMASeq0andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(negedge CLK &&& STOVeq1andEMASeq1andopopTENeq1andWENeq1cporopTENeq0andTWENeq1cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMAW1eq0andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMAW1eq0andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMAW1eq1andEMAW0eq0andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andEMAW1eq1andEMAW0eq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq1andopopTENeq1andWENeq0cporopTENeq0andTWENeq0cpcp, 3.000, NOT_CLK_PER);
   `endif

// Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge CLK, 1.000, 0, NOT_CLK_MINH);
       $width(negedge CLK, 1.000, 0, NOT_CLK_MINL);
   `else
       $width(posedge CLK &&& STOVeq0, 1.000, 0, NOT_CLK_MINH);
       $width(negedge CLK &&& STOVeq0, 1.000, 0, NOT_CLK_MINL);
       $width(posedge CLK &&& STOVeq1andEMASeq0, 1.000, 0, NOT_CLK_MINH);
       $width(negedge CLK &&& STOVeq1andEMASeq0, 1.000, 0, NOT_CLK_MINL);
       $width(posedge CLK &&& STOVeq1andEMASeq1, 1.000, 0, NOT_CLK_MINH);
       $width(negedge CLK &&& STOVeq1andEMASeq1, 1.000, 0, NOT_CLK_MINL);
   `endif

    $setuphold(posedge CLK &&& TENeq1, posedge CEN, 1.000, 0.500, NOT_CEN);
    $setuphold(posedge CLK &&& TENeq1, negedge CEN, 1.000, 0.500, NOT_CEN);
    $setuphold(posedge RET1N &&& TENeq1, negedge CEN, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge WEN, 1.000, 0.500, NOT_WEN);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge WEN, 1.000, 0.500, NOT_WEN);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[7], 1.000, 0.500, NOT_A7);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[6], 1.000, 0.500, NOT_A6);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[5], 1.000, 0.500, NOT_A5);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[4], 1.000, 0.500, NOT_A4);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[3], 1.000, 0.500, NOT_A3);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[2], 1.000, 0.500, NOT_A2);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[1], 1.000, 0.500, NOT_A1);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[0], 1.000, 0.500, NOT_A0);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[7], 1.000, 0.500, NOT_A7);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[6], 1.000, 0.500, NOT_A6);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[5], 1.000, 0.500, NOT_A5);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[4], 1.000, 0.500, NOT_A4);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[3], 1.000, 0.500, NOT_A3);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[2], 1.000, 0.500, NOT_A2);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[1], 1.000, 0.500, NOT_A1);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[0], 1.000, 0.500, NOT_A0);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[79], 1.000, 0.500, NOT_D79);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[78], 1.000, 0.500, NOT_D78);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[77], 1.000, 0.500, NOT_D77);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[76], 1.000, 0.500, NOT_D76);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[75], 1.000, 0.500, NOT_D75);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[74], 1.000, 0.500, NOT_D74);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[73], 1.000, 0.500, NOT_D73);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[72], 1.000, 0.500, NOT_D72);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[71], 1.000, 0.500, NOT_D71);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[70], 1.000, 0.500, NOT_D70);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[69], 1.000, 0.500, NOT_D69);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[68], 1.000, 0.500, NOT_D68);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[67], 1.000, 0.500, NOT_D67);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[66], 1.000, 0.500, NOT_D66);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[65], 1.000, 0.500, NOT_D65);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[64], 1.000, 0.500, NOT_D64);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[63], 1.000, 0.500, NOT_D63);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[62], 1.000, 0.500, NOT_D62);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[61], 1.000, 0.500, NOT_D61);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[60], 1.000, 0.500, NOT_D60);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[59], 1.000, 0.500, NOT_D59);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[58], 1.000, 0.500, NOT_D58);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[57], 1.000, 0.500, NOT_D57);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[56], 1.000, 0.500, NOT_D56);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[55], 1.000, 0.500, NOT_D55);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[54], 1.000, 0.500, NOT_D54);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[53], 1.000, 0.500, NOT_D53);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[52], 1.000, 0.500, NOT_D52);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[51], 1.000, 0.500, NOT_D51);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[50], 1.000, 0.500, NOT_D50);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[49], 1.000, 0.500, NOT_D49);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[48], 1.000, 0.500, NOT_D48);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[47], 1.000, 0.500, NOT_D47);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[46], 1.000, 0.500, NOT_D46);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[45], 1.000, 0.500, NOT_D45);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[44], 1.000, 0.500, NOT_D44);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[43], 1.000, 0.500, NOT_D43);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[42], 1.000, 0.500, NOT_D42);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[41], 1.000, 0.500, NOT_D41);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[40], 1.000, 0.500, NOT_D40);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[39], 1.000, 0.500, NOT_D39);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[38], 1.000, 0.500, NOT_D38);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[37], 1.000, 0.500, NOT_D37);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[36], 1.000, 0.500, NOT_D36);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[35], 1.000, 0.500, NOT_D35);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[34], 1.000, 0.500, NOT_D34);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[33], 1.000, 0.500, NOT_D33);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[32], 1.000, 0.500, NOT_D32);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[31], 1.000, 0.500, NOT_D31);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[30], 1.000, 0.500, NOT_D30);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[29], 1.000, 0.500, NOT_D29);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[28], 1.000, 0.500, NOT_D28);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[27], 1.000, 0.500, NOT_D27);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[26], 1.000, 0.500, NOT_D26);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[25], 1.000, 0.500, NOT_D25);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[24], 1.000, 0.500, NOT_D24);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[23], 1.000, 0.500, NOT_D23);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[22], 1.000, 0.500, NOT_D22);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[21], 1.000, 0.500, NOT_D21);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[20], 1.000, 0.500, NOT_D20);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[19], 1.000, 0.500, NOT_D19);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[18], 1.000, 0.500, NOT_D18);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[17], 1.000, 0.500, NOT_D17);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[16], 1.000, 0.500, NOT_D16);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[15], 1.000, 0.500, NOT_D15);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[14], 1.000, 0.500, NOT_D14);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[13], 1.000, 0.500, NOT_D13);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[12], 1.000, 0.500, NOT_D12);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[11], 1.000, 0.500, NOT_D11);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[10], 1.000, 0.500, NOT_D10);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[9], 1.000, 0.500, NOT_D9);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[8], 1.000, 0.500, NOT_D8);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[7], 1.000, 0.500, NOT_D7);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[6], 1.000, 0.500, NOT_D6);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[5], 1.000, 0.500, NOT_D5);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[4], 1.000, 0.500, NOT_D4);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[3], 1.000, 0.500, NOT_D3);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[2], 1.000, 0.500, NOT_D2);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[1], 1.000, 0.500, NOT_D1);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, posedge D[0], 1.000, 0.500, NOT_D0);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[79], 1.000, 0.500, NOT_D79);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[78], 1.000, 0.500, NOT_D78);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[77], 1.000, 0.500, NOT_D77);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[76], 1.000, 0.500, NOT_D76);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[75], 1.000, 0.500, NOT_D75);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[74], 1.000, 0.500, NOT_D74);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[73], 1.000, 0.500, NOT_D73);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[72], 1.000, 0.500, NOT_D72);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[71], 1.000, 0.500, NOT_D71);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[70], 1.000, 0.500, NOT_D70);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[69], 1.000, 0.500, NOT_D69);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[68], 1.000, 0.500, NOT_D68);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[67], 1.000, 0.500, NOT_D67);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[66], 1.000, 0.500, NOT_D66);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[65], 1.000, 0.500, NOT_D65);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[64], 1.000, 0.500, NOT_D64);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[63], 1.000, 0.500, NOT_D63);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[62], 1.000, 0.500, NOT_D62);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[61], 1.000, 0.500, NOT_D61);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[60], 1.000, 0.500, NOT_D60);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[59], 1.000, 0.500, NOT_D59);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[58], 1.000, 0.500, NOT_D58);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[57], 1.000, 0.500, NOT_D57);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[56], 1.000, 0.500, NOT_D56);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[55], 1.000, 0.500, NOT_D55);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[54], 1.000, 0.500, NOT_D54);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[53], 1.000, 0.500, NOT_D53);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[52], 1.000, 0.500, NOT_D52);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[51], 1.000, 0.500, NOT_D51);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[50], 1.000, 0.500, NOT_D50);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[49], 1.000, 0.500, NOT_D49);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[48], 1.000, 0.500, NOT_D48);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[47], 1.000, 0.500, NOT_D47);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[46], 1.000, 0.500, NOT_D46);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[45], 1.000, 0.500, NOT_D45);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[44], 1.000, 0.500, NOT_D44);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[43], 1.000, 0.500, NOT_D43);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[42], 1.000, 0.500, NOT_D42);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[41], 1.000, 0.500, NOT_D41);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[40], 1.000, 0.500, NOT_D40);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[39], 1.000, 0.500, NOT_D39);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[38], 1.000, 0.500, NOT_D38);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[37], 1.000, 0.500, NOT_D37);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[36], 1.000, 0.500, NOT_D36);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[35], 1.000, 0.500, NOT_D35);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[34], 1.000, 0.500, NOT_D34);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[33], 1.000, 0.500, NOT_D33);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[32], 1.000, 0.500, NOT_D32);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[31], 1.000, 0.500, NOT_D31);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[30], 1.000, 0.500, NOT_D30);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[29], 1.000, 0.500, NOT_D29);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[28], 1.000, 0.500, NOT_D28);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[27], 1.000, 0.500, NOT_D27);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[26], 1.000, 0.500, NOT_D26);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[25], 1.000, 0.500, NOT_D25);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[24], 1.000, 0.500, NOT_D24);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[23], 1.000, 0.500, NOT_D23);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[22], 1.000, 0.500, NOT_D22);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[21], 1.000, 0.500, NOT_D21);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[20], 1.000, 0.500, NOT_D20);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[19], 1.000, 0.500, NOT_D19);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[18], 1.000, 0.500, NOT_D18);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[17], 1.000, 0.500, NOT_D17);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[16], 1.000, 0.500, NOT_D16);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[15], 1.000, 0.500, NOT_D15);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[14], 1.000, 0.500, NOT_D14);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[13], 1.000, 0.500, NOT_D13);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[12], 1.000, 0.500, NOT_D12);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[11], 1.000, 0.500, NOT_D11);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[10], 1.000, 0.500, NOT_D10);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[9], 1.000, 0.500, NOT_D9);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[8], 1.000, 0.500, NOT_D8);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[7], 1.000, 0.500, NOT_D7);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[6], 1.000, 0.500, NOT_D6);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[5], 1.000, 0.500, NOT_D5);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[4], 1.000, 0.500, NOT_D4);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[3], 1.000, 0.500, NOT_D3);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[2], 1.000, 0.500, NOT_D2);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[1], 1.000, 0.500, NOT_D1);
    $setuphold(posedge CLK &&& TENeq1andCENeq0andWENeq0, negedge D[0], 1.000, 0.500, NOT_D0);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge EMA[2], 1.000, 0.500, NOT_EMA2);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge EMA[1], 1.000, 0.500, NOT_EMA1);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge EMA[0], 1.000, 0.500, NOT_EMA0);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge EMA[2], 1.000, 0.500, NOT_EMA2);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge EMA[1], 1.000, 0.500, NOT_EMA1);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge EMA[0], 1.000, 0.500, NOT_EMA0);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge EMAW[1], 1.000, 0.500, NOT_EMAW1);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge EMAW[0], 1.000, 0.500, NOT_EMAW0);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge EMAW[1], 1.000, 0.500, NOT_EMAW1);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge EMAW[0], 1.000, 0.500, NOT_EMAW0);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge EMAS, 1.000, 0.500, NOT_EMAS);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge EMAS, 1.000, 0.500, NOT_EMAS);
    $setuphold(posedge CLK, posedge TEN, 1.000, 0.500, NOT_TEN);
    $setuphold(posedge CLK, negedge TEN, 1.000, 0.500, NOT_TEN);
    $setuphold(posedge CLK &&& TENeq0, posedge TCEN, 1.000, 0.500, NOT_TCEN);
    $setuphold(posedge CLK &&& TENeq0, negedge TCEN, 1.000, 0.500, NOT_TCEN);
    $setuphold(posedge RET1N &&& TENeq0, negedge TCEN, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TWEN, 1.000, 0.500, NOT_TWEN);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TWEN, 1.000, 0.500, NOT_TWEN);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[7], 1.000, 0.500, NOT_TA7);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[6], 1.000, 0.500, NOT_TA6);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[5], 1.000, 0.500, NOT_TA5);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[4], 1.000, 0.500, NOT_TA4);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[3], 1.000, 0.500, NOT_TA3);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[2], 1.000, 0.500, NOT_TA2);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[1], 1.000, 0.500, NOT_TA1);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[0], 1.000, 0.500, NOT_TA0);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[7], 1.000, 0.500, NOT_TA7);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[6], 1.000, 0.500, NOT_TA6);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[5], 1.000, 0.500, NOT_TA5);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[4], 1.000, 0.500, NOT_TA4);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[3], 1.000, 0.500, NOT_TA3);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[2], 1.000, 0.500, NOT_TA2);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[1], 1.000, 0.500, NOT_TA1);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[0], 1.000, 0.500, NOT_TA0);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[79], 1.000, 0.500, NOT_TD79);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[78], 1.000, 0.500, NOT_TD78);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[77], 1.000, 0.500, NOT_TD77);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[76], 1.000, 0.500, NOT_TD76);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[75], 1.000, 0.500, NOT_TD75);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[74], 1.000, 0.500, NOT_TD74);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[73], 1.000, 0.500, NOT_TD73);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[72], 1.000, 0.500, NOT_TD72);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[71], 1.000, 0.500, NOT_TD71);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[70], 1.000, 0.500, NOT_TD70);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[69], 1.000, 0.500, NOT_TD69);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[68], 1.000, 0.500, NOT_TD68);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[67], 1.000, 0.500, NOT_TD67);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[66], 1.000, 0.500, NOT_TD66);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[65], 1.000, 0.500, NOT_TD65);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[64], 1.000, 0.500, NOT_TD64);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[63], 1.000, 0.500, NOT_TD63);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[62], 1.000, 0.500, NOT_TD62);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[61], 1.000, 0.500, NOT_TD61);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[60], 1.000, 0.500, NOT_TD60);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[59], 1.000, 0.500, NOT_TD59);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[58], 1.000, 0.500, NOT_TD58);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[57], 1.000, 0.500, NOT_TD57);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[56], 1.000, 0.500, NOT_TD56);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[55], 1.000, 0.500, NOT_TD55);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[54], 1.000, 0.500, NOT_TD54);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[53], 1.000, 0.500, NOT_TD53);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[52], 1.000, 0.500, NOT_TD52);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[51], 1.000, 0.500, NOT_TD51);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[50], 1.000, 0.500, NOT_TD50);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[49], 1.000, 0.500, NOT_TD49);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[48], 1.000, 0.500, NOT_TD48);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[47], 1.000, 0.500, NOT_TD47);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[46], 1.000, 0.500, NOT_TD46);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[45], 1.000, 0.500, NOT_TD45);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[44], 1.000, 0.500, NOT_TD44);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[43], 1.000, 0.500, NOT_TD43);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[42], 1.000, 0.500, NOT_TD42);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[41], 1.000, 0.500, NOT_TD41);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[40], 1.000, 0.500, NOT_TD40);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[39], 1.000, 0.500, NOT_TD39);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[38], 1.000, 0.500, NOT_TD38);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[37], 1.000, 0.500, NOT_TD37);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[36], 1.000, 0.500, NOT_TD36);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[35], 1.000, 0.500, NOT_TD35);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[34], 1.000, 0.500, NOT_TD34);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[33], 1.000, 0.500, NOT_TD33);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[32], 1.000, 0.500, NOT_TD32);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[31], 1.000, 0.500, NOT_TD31);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[30], 1.000, 0.500, NOT_TD30);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[29], 1.000, 0.500, NOT_TD29);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[28], 1.000, 0.500, NOT_TD28);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[27], 1.000, 0.500, NOT_TD27);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[26], 1.000, 0.500, NOT_TD26);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[25], 1.000, 0.500, NOT_TD25);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[24], 1.000, 0.500, NOT_TD24);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[23], 1.000, 0.500, NOT_TD23);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[22], 1.000, 0.500, NOT_TD22);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[21], 1.000, 0.500, NOT_TD21);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[20], 1.000, 0.500, NOT_TD20);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[19], 1.000, 0.500, NOT_TD19);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[18], 1.000, 0.500, NOT_TD18);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[17], 1.000, 0.500, NOT_TD17);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[16], 1.000, 0.500, NOT_TD16);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[15], 1.000, 0.500, NOT_TD15);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[14], 1.000, 0.500, NOT_TD14);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[13], 1.000, 0.500, NOT_TD13);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[12], 1.000, 0.500, NOT_TD12);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[11], 1.000, 0.500, NOT_TD11);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[10], 1.000, 0.500, NOT_TD10);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[9], 1.000, 0.500, NOT_TD9);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[8], 1.000, 0.500, NOT_TD8);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[7], 1.000, 0.500, NOT_TD7);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[6], 1.000, 0.500, NOT_TD6);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[5], 1.000, 0.500, NOT_TD5);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[4], 1.000, 0.500, NOT_TD4);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[3], 1.000, 0.500, NOT_TD3);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[2], 1.000, 0.500, NOT_TD2);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[1], 1.000, 0.500, NOT_TD1);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, posedge TD[0], 1.000, 0.500, NOT_TD0);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[79], 1.000, 0.500, NOT_TD79);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[78], 1.000, 0.500, NOT_TD78);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[77], 1.000, 0.500, NOT_TD77);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[76], 1.000, 0.500, NOT_TD76);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[75], 1.000, 0.500, NOT_TD75);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[74], 1.000, 0.500, NOT_TD74);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[73], 1.000, 0.500, NOT_TD73);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[72], 1.000, 0.500, NOT_TD72);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[71], 1.000, 0.500, NOT_TD71);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[70], 1.000, 0.500, NOT_TD70);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[69], 1.000, 0.500, NOT_TD69);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[68], 1.000, 0.500, NOT_TD68);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[67], 1.000, 0.500, NOT_TD67);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[66], 1.000, 0.500, NOT_TD66);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[65], 1.000, 0.500, NOT_TD65);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[64], 1.000, 0.500, NOT_TD64);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[63], 1.000, 0.500, NOT_TD63);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[62], 1.000, 0.500, NOT_TD62);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[61], 1.000, 0.500, NOT_TD61);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[60], 1.000, 0.500, NOT_TD60);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[59], 1.000, 0.500, NOT_TD59);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[58], 1.000, 0.500, NOT_TD58);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[57], 1.000, 0.500, NOT_TD57);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[56], 1.000, 0.500, NOT_TD56);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[55], 1.000, 0.500, NOT_TD55);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[54], 1.000, 0.500, NOT_TD54);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[53], 1.000, 0.500, NOT_TD53);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[52], 1.000, 0.500, NOT_TD52);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[51], 1.000, 0.500, NOT_TD51);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[50], 1.000, 0.500, NOT_TD50);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[49], 1.000, 0.500, NOT_TD49);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[48], 1.000, 0.500, NOT_TD48);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[47], 1.000, 0.500, NOT_TD47);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[46], 1.000, 0.500, NOT_TD46);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[45], 1.000, 0.500, NOT_TD45);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[44], 1.000, 0.500, NOT_TD44);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[43], 1.000, 0.500, NOT_TD43);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[42], 1.000, 0.500, NOT_TD42);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[41], 1.000, 0.500, NOT_TD41);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[40], 1.000, 0.500, NOT_TD40);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[39], 1.000, 0.500, NOT_TD39);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[38], 1.000, 0.500, NOT_TD38);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[37], 1.000, 0.500, NOT_TD37);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[36], 1.000, 0.500, NOT_TD36);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[35], 1.000, 0.500, NOT_TD35);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[34], 1.000, 0.500, NOT_TD34);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[33], 1.000, 0.500, NOT_TD33);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[32], 1.000, 0.500, NOT_TD32);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[31], 1.000, 0.500, NOT_TD31);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[30], 1.000, 0.500, NOT_TD30);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[29], 1.000, 0.500, NOT_TD29);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[28], 1.000, 0.500, NOT_TD28);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[27], 1.000, 0.500, NOT_TD27);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[26], 1.000, 0.500, NOT_TD26);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[25], 1.000, 0.500, NOT_TD25);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[24], 1.000, 0.500, NOT_TD24);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[23], 1.000, 0.500, NOT_TD23);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[22], 1.000, 0.500, NOT_TD22);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[21], 1.000, 0.500, NOT_TD21);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[20], 1.000, 0.500, NOT_TD20);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[19], 1.000, 0.500, NOT_TD19);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[18], 1.000, 0.500, NOT_TD18);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[17], 1.000, 0.500, NOT_TD17);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[16], 1.000, 0.500, NOT_TD16);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[15], 1.000, 0.500, NOT_TD15);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[14], 1.000, 0.500, NOT_TD14);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[13], 1.000, 0.500, NOT_TD13);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[12], 1.000, 0.500, NOT_TD12);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[11], 1.000, 0.500, NOT_TD11);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[10], 1.000, 0.500, NOT_TD10);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[9], 1.000, 0.500, NOT_TD9);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[8], 1.000, 0.500, NOT_TD8);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[7], 1.000, 0.500, NOT_TD7);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[6], 1.000, 0.500, NOT_TD6);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[5], 1.000, 0.500, NOT_TD5);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[4], 1.000, 0.500, NOT_TD4);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[3], 1.000, 0.500, NOT_TD3);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[2], 1.000, 0.500, NOT_TD2);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[1], 1.000, 0.500, NOT_TD1);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0andTWENeq0, negedge TD[0], 1.000, 0.500, NOT_TD0);
    $setuphold(posedge CLK &&& opopTENeq1andCENeq0cporopTENeq0andTCENeq0cpcp, posedge RET1N, 1.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLK &&& opopTENeq1andCENeq0cporopTENeq0andTCENeq0cpcp, negedge RET1N, 1.000, 0.500, NOT_RET1N);
    $setuphold(posedge CEN &&& TENeq1, negedge RET1N, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge TCEN &&& TENeq0, negedge RET1N, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge STOV, 1.000, 0.500, NOT_STOV);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge STOV, 1.000, 0.500, NOT_STOV);
  endspecify


endmodule
`endcelldefine
`endif
`timescale 1ns/1ps
module sram_sp_hde_error_injection (Q_out, Q_in, CLK, A, CEN, WEN, BEN, TQ);
   output [79:0] Q_out;
   input [79:0] Q_in;
   input CLK;
   input [7:0] A;
   input CEN;
   input WEN;
   input BEN;
   input [79:0] TQ;
   parameter LEFT_RED_COLUMN_FAULT = 2'd1;
   parameter RIGHT_RED_COLUMN_FAULT = 2'd2;
   parameter NO_RED_FAULT = 2'd0;
   reg [79:0] Q_out;
   reg entry_found;
   reg list_complete;
   reg [19:0] fault_table [31:0];
   reg [19:0] fault_entry;
initial
begin
   `ifdef DUT
      `define pre_pend_path TB.DUT_inst.CHIP
   `else
       `define pre_pend_path TB.CHIP
   `endif
   `ifdef ARM_NONREPAIRABLE_FAULT
      `pre_pend_path.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST.u1.add_fault(8'd163,7'd6,2'd1,2'd0);
   `endif
end
   task add_fault;
   //This task injects fault in memory
   //In order to inject fault in redundant column for Bit 0 to 39, column address
   //should have value in range of 4 to 7
   //In order to inject fault in redundant column for Bit 40 to 79, column address
   //should have value in range of 0 to 3
      input [7:0] address;
      input [6:0] bitPlace;
      input [1:0] fault_type;
      input [1:0] red_fault;
 
      integer i;
      reg done;
   begin
      done = 1'b0;
      i = 0;
      while ((!done) && i < 31)
      begin
         fault_entry = fault_table[i];
         if (fault_entry[0] === 1'b0 || fault_entry[0] === 1'bx)
         begin
            fault_entry[0] = 1'b1;
            fault_entry[2:1] = red_fault;
            fault_entry[4:3] = fault_type;
            fault_entry[11:5] = bitPlace;
            fault_entry[19:12] = address;
            fault_table[i] = fault_entry;
            done = 1'b1;
         end
         i = i+1;
      end
   end
   endtask
//This task removes all fault entries injected by user
task remove_all_faults;
   integer i;
begin
   for (i = 0; i < 32; i=i+1)
   begin
      fault_entry = fault_table[i];
      fault_entry[0] = 1'b0;
      fault_table[i] = fault_entry;
   end
end
endtask
task bit_error;
// This task is used to inject error in memory and should be called
// only from current module.
//
// This task injects error depending upon fault type to particular bit
// of the output
   inout [79:0] q_int;
   input [1:0] fault_type;
   input [6:0] bitLoc;
begin
   if (fault_type === 2'd0)
      q_int[bitLoc] = 1'b0;
   else if (fault_type === 2'd1)
      q_int[bitLoc] = 1'b1;
   else
      q_int[bitLoc] = ~q_int[bitLoc];
end
endtask
task error_injection_on_output;
// This function goes through error injection table for every
// read cycle and corrupts Q output if fault for the particular
// address is present in fault table
//
// If fault is redundant column is detected, this task corrupts
// Q output in read cycle
//
// If fault is repaired using repair bus, this task does not
// courrpt Q output in read cycle
//
   output [79:0] Q_output;
   reg list_complete;
   integer i;
   reg [4:0] row_address;
   reg [2:0] column_address;
   reg [6:0] bitPlace;
   reg [1:0] fault_type;
   reg [1:0] red_fault;
   reg valid;
begin
   entry_found = 1'b0;
   list_complete = 1'b0;
   i = 0;
   Q_output = Q_in;
   while(!list_complete)
   begin
      fault_entry = fault_table[i];
      {row_address, column_address, bitPlace, fault_type, red_fault, valid} = fault_entry;
      i = i + 1;
      if (valid == 1'b1)
      begin
         if (red_fault === NO_RED_FAULT)
         begin
            if (row_address == A[7:3] && column_address == A[2:0])
            begin
               if (bitPlace < 40)
                  bit_error(Q_output,fault_type, bitPlace);
               else if (bitPlace >= 40 )
                  bit_error(Q_output,fault_type, bitPlace);
            end
         end
      end
      else
         list_complete = 1'b1;
      end
   end
   endtask
   always @ (Q_in or CLK or A or CEN or WEN or BEN or TQ)
   begin
   if (CEN === 1'b0 && &WEN === 1'b1 && BEN === 1'b1)
      error_injection_on_output(Q_out);
   else if (BEN === 1'b0)
      Q_out = TQ;
   else
      Q_out = Q_in;
   end
endmodule
