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
//      Verilog model for Synchronous Dual-Port Ram
//
//       Instance Name:              sram_dp_hde
//       Words:                      2048
//       Bits:                       80
//       Mux:                        4
//       Drive:                      6
//       Write Mask:                 Off
//       Write Thru:                 Off
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
//       Creation Date:  Thu Jul  2 00:30:16 2020
//       Version: 	r5p0
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
module sram_dp_hde (VDDCE, VDDPE, VSSE, CENYA, WENYA, AYA, DYA, CENYB, WENYB, AYB,
    DYB, QA, QB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA, EMASA,
    EMAB, EMAWB, EMASB, TENA, BENA, TCENA, TWENA, TAA, TDA, TQA, TENB, BENB, TCENB,
    TWENB, TAB, TDB, TQB, RET1N, STOVA, STOVB, COLLDISN);
`else
module sram_dp_hde (CENYA, WENYA, AYA, DYA, CENYB, WENYB, AYB, DYB, QA, QB, CLKA, CENA,
    WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA, EMASA, EMAB, EMAWB, EMASB,
    TENA, BENA, TCENA, TWENA, TAA, TDA, TQA, TENB, BENB, TCENB, TWENB, TAB, TDB, TQB,
    RET1N, STOVA, STOVB, COLLDISN);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 80;
  parameter WORDS = 2048;
  parameter MUX = 4;
  parameter MEM_WIDTH = 320; // redun block size 4, 160 on left, 160 on right
  parameter MEM_HEIGHT = 512;
  parameter WP_SIZE = 80 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENYA;
  output  WENYA;
  output [10:0] AYA;
  output [79:0] DYA;
  output  CENYB;
  output  WENYB;
  output [10:0] AYB;
  output [79:0] DYB;
  output [79:0] QA;
  output [79:0] QB;
  input  CLKA;
  input  CENA;
  input  WENA;
  input [10:0] AA;
  input [79:0] DA;
  input  CLKB;
  input  CENB;
  input  WENB;
  input [10:0] AB;
  input [79:0] DB;
  input [2:0] EMAA;
  input [1:0] EMAWA;
  input  EMASA;
  input [2:0] EMAB;
  input [1:0] EMAWB;
  input  EMASB;
  input  TENA;
  input  BENA;
  input  TCENA;
  input  TWENA;
  input [10:0] TAA;
  input [79:0] TDA;
  input [79:0] TQA;
  input  TENB;
  input  BENB;
  input  TCENB;
  input  TWENB;
  input [10:0] TAB;
  input [79:0] TDB;
  input [79:0] TQB;
  input  RET1N;
  input  STOVA;
  input  STOVB;
  input  COLLDISN;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

  integer row_address;
  integer mux_address;
  reg [319:0] mem [0:511];
  reg [319:0] row;
  reg LAST_CLKA;
  reg [319:0] row_mask;
  reg [319:0] new_data;
  reg [319:0] data_out;
  reg [79:0] readLatch0;
  reg [79:0] shifted_readLatch0;
  reg [79:0] readLatch1;
  reg [79:0] shifted_readLatch1;
  reg LAST_CLKB;
  reg [79:0] QA_int;
  reg [79:0] QA_int_delayed;
  reg [79:0] QB_int;
  reg [79:0] QB_int_delayed;
  reg [79:0] writeEnable;
  real previous_CLKA;
  real previous_CLKB;
  initial previous_CLKA = 0;
  initial previous_CLKB = 0;
  reg READ_WRITE, WRITE_WRITE, READ_READ, ROW_CC, COL_CC;
  reg READ_WRITE_1, WRITE_WRITE_1, READ_READ_1;
  reg  cont_flag0_int;
  reg  cont_flag1_int;
  initial cont_flag0_int = 1'b0;
  initial cont_flag1_int = 1'b0;

  reg NOT_CENA, NOT_WENA, NOT_AA10, NOT_AA9, NOT_AA8, NOT_AA7, NOT_AA6, NOT_AA5, NOT_AA4;
  reg NOT_AA3, NOT_AA2, NOT_AA1, NOT_AA0, NOT_DA79, NOT_DA78, NOT_DA77, NOT_DA76, NOT_DA75;
  reg NOT_DA74, NOT_DA73, NOT_DA72, NOT_DA71, NOT_DA70, NOT_DA69, NOT_DA68, NOT_DA67;
  reg NOT_DA66, NOT_DA65, NOT_DA64, NOT_DA63, NOT_DA62, NOT_DA61, NOT_DA60, NOT_DA59;
  reg NOT_DA58, NOT_DA57, NOT_DA56, NOT_DA55, NOT_DA54, NOT_DA53, NOT_DA52, NOT_DA51;
  reg NOT_DA50, NOT_DA49, NOT_DA48, NOT_DA47, NOT_DA46, NOT_DA45, NOT_DA44, NOT_DA43;
  reg NOT_DA42, NOT_DA41, NOT_DA40, NOT_DA39, NOT_DA38, NOT_DA37, NOT_DA36, NOT_DA35;
  reg NOT_DA34, NOT_DA33, NOT_DA32, NOT_DA31, NOT_DA30, NOT_DA29, NOT_DA28, NOT_DA27;
  reg NOT_DA26, NOT_DA25, NOT_DA24, NOT_DA23, NOT_DA22, NOT_DA21, NOT_DA20, NOT_DA19;
  reg NOT_DA18, NOT_DA17, NOT_DA16, NOT_DA15, NOT_DA14, NOT_DA13, NOT_DA12, NOT_DA11;
  reg NOT_DA10, NOT_DA9, NOT_DA8, NOT_DA7, NOT_DA6, NOT_DA5, NOT_DA4, NOT_DA3, NOT_DA2;
  reg NOT_DA1, NOT_DA0, NOT_CENB, NOT_WENB, NOT_AB10, NOT_AB9, NOT_AB8, NOT_AB7, NOT_AB6;
  reg NOT_AB5, NOT_AB4, NOT_AB3, NOT_AB2, NOT_AB1, NOT_AB0, NOT_DB79, NOT_DB78, NOT_DB77;
  reg NOT_DB76, NOT_DB75, NOT_DB74, NOT_DB73, NOT_DB72, NOT_DB71, NOT_DB70, NOT_DB69;
  reg NOT_DB68, NOT_DB67, NOT_DB66, NOT_DB65, NOT_DB64, NOT_DB63, NOT_DB62, NOT_DB61;
  reg NOT_DB60, NOT_DB59, NOT_DB58, NOT_DB57, NOT_DB56, NOT_DB55, NOT_DB54, NOT_DB53;
  reg NOT_DB52, NOT_DB51, NOT_DB50, NOT_DB49, NOT_DB48, NOT_DB47, NOT_DB46, NOT_DB45;
  reg NOT_DB44, NOT_DB43, NOT_DB42, NOT_DB41, NOT_DB40, NOT_DB39, NOT_DB38, NOT_DB37;
  reg NOT_DB36, NOT_DB35, NOT_DB34, NOT_DB33, NOT_DB32, NOT_DB31, NOT_DB30, NOT_DB29;
  reg NOT_DB28, NOT_DB27, NOT_DB26, NOT_DB25, NOT_DB24, NOT_DB23, NOT_DB22, NOT_DB21;
  reg NOT_DB20, NOT_DB19, NOT_DB18, NOT_DB17, NOT_DB16, NOT_DB15, NOT_DB14, NOT_DB13;
  reg NOT_DB12, NOT_DB11, NOT_DB10, NOT_DB9, NOT_DB8, NOT_DB7, NOT_DB6, NOT_DB5, NOT_DB4;
  reg NOT_DB3, NOT_DB2, NOT_DB1, NOT_DB0, NOT_EMAA2, NOT_EMAA1, NOT_EMAA0, NOT_EMAWA1;
  reg NOT_EMAWA0, NOT_EMASA, NOT_EMAB2, NOT_EMAB1, NOT_EMAB0, NOT_EMAWB1, NOT_EMAWB0;
  reg NOT_EMASB, NOT_TENA, NOT_TCENA, NOT_TWENA, NOT_TAA10, NOT_TAA9, NOT_TAA8, NOT_TAA7;
  reg NOT_TAA6, NOT_TAA5, NOT_TAA4, NOT_TAA3, NOT_TAA2, NOT_TAA1, NOT_TAA0, NOT_TDA79;
  reg NOT_TDA78, NOT_TDA77, NOT_TDA76, NOT_TDA75, NOT_TDA74, NOT_TDA73, NOT_TDA72;
  reg NOT_TDA71, NOT_TDA70, NOT_TDA69, NOT_TDA68, NOT_TDA67, NOT_TDA66, NOT_TDA65;
  reg NOT_TDA64, NOT_TDA63, NOT_TDA62, NOT_TDA61, NOT_TDA60, NOT_TDA59, NOT_TDA58;
  reg NOT_TDA57, NOT_TDA56, NOT_TDA55, NOT_TDA54, NOT_TDA53, NOT_TDA52, NOT_TDA51;
  reg NOT_TDA50, NOT_TDA49, NOT_TDA48, NOT_TDA47, NOT_TDA46, NOT_TDA45, NOT_TDA44;
  reg NOT_TDA43, NOT_TDA42, NOT_TDA41, NOT_TDA40, NOT_TDA39, NOT_TDA38, NOT_TDA37;
  reg NOT_TDA36, NOT_TDA35, NOT_TDA34, NOT_TDA33, NOT_TDA32, NOT_TDA31, NOT_TDA30;
  reg NOT_TDA29, NOT_TDA28, NOT_TDA27, NOT_TDA26, NOT_TDA25, NOT_TDA24, NOT_TDA23;
  reg NOT_TDA22, NOT_TDA21, NOT_TDA20, NOT_TDA19, NOT_TDA18, NOT_TDA17, NOT_TDA16;
  reg NOT_TDA15, NOT_TDA14, NOT_TDA13, NOT_TDA12, NOT_TDA11, NOT_TDA10, NOT_TDA9, NOT_TDA8;
  reg NOT_TDA7, NOT_TDA6, NOT_TDA5, NOT_TDA4, NOT_TDA3, NOT_TDA2, NOT_TDA1, NOT_TDA0;
  reg NOT_TENB, NOT_TCENB, NOT_TWENB, NOT_TAB10, NOT_TAB9, NOT_TAB8, NOT_TAB7, NOT_TAB6;
  reg NOT_TAB5, NOT_TAB4, NOT_TAB3, NOT_TAB2, NOT_TAB1, NOT_TAB0, NOT_TDB79, NOT_TDB78;
  reg NOT_TDB77, NOT_TDB76, NOT_TDB75, NOT_TDB74, NOT_TDB73, NOT_TDB72, NOT_TDB71;
  reg NOT_TDB70, NOT_TDB69, NOT_TDB68, NOT_TDB67, NOT_TDB66, NOT_TDB65, NOT_TDB64;
  reg NOT_TDB63, NOT_TDB62, NOT_TDB61, NOT_TDB60, NOT_TDB59, NOT_TDB58, NOT_TDB57;
  reg NOT_TDB56, NOT_TDB55, NOT_TDB54, NOT_TDB53, NOT_TDB52, NOT_TDB51, NOT_TDB50;
  reg NOT_TDB49, NOT_TDB48, NOT_TDB47, NOT_TDB46, NOT_TDB45, NOT_TDB44, NOT_TDB43;
  reg NOT_TDB42, NOT_TDB41, NOT_TDB40, NOT_TDB39, NOT_TDB38, NOT_TDB37, NOT_TDB36;
  reg NOT_TDB35, NOT_TDB34, NOT_TDB33, NOT_TDB32, NOT_TDB31, NOT_TDB30, NOT_TDB29;
  reg NOT_TDB28, NOT_TDB27, NOT_TDB26, NOT_TDB25, NOT_TDB24, NOT_TDB23, NOT_TDB22;
  reg NOT_TDB21, NOT_TDB20, NOT_TDB19, NOT_TDB18, NOT_TDB17, NOT_TDB16, NOT_TDB15;
  reg NOT_TDB14, NOT_TDB13, NOT_TDB12, NOT_TDB11, NOT_TDB10, NOT_TDB9, NOT_TDB8, NOT_TDB7;
  reg NOT_TDB6, NOT_TDB5, NOT_TDB4, NOT_TDB3, NOT_TDB2, NOT_TDB1, NOT_TDB0, NOT_RET1N;
  reg NOT_STOVA, NOT_STOVB, NOT_COLLDISN;
  reg NOT_CONTA, NOT_CLKA_PER, NOT_CLKA_MINH, NOT_CLKA_MINL, NOT_CONTB, NOT_CLKB_PER;
  reg NOT_CLKB_MINH, NOT_CLKB_MINL;
  reg clk0_int;
  reg clk1_int;

  wire  CENYA_;
  wire  WENYA_;
  wire [10:0] AYA_;
  wire [79:0] DYA_;
  wire  CENYB_;
  wire  WENYB_;
  wire [10:0] AYB_;
  wire [79:0] DYB_;
  wire [79:0] QA_;
  wire [79:0] QB_;
 wire  CLKA_;
  wire  CENA_;
  reg  CENA_int;
  reg  CENA_p2;
  wire  WENA_;
  reg  WENA_int;
  wire [10:0] AA_;
  reg [10:0] AA_int;
  wire [79:0] DA_;
  reg [79:0] DA_int;
 wire  CLKB_;
  wire  CENB_;
  reg  CENB_int;
  reg  CENB_p2;
  wire  WENB_;
  reg  WENB_int;
  wire [10:0] AB_;
  reg [10:0] AB_int;
  wire [79:0] DB_;
  reg [79:0] DB_int;
  wire [2:0] EMAA_;
  reg [2:0] EMAA_int;
  wire [1:0] EMAWA_;
  reg [1:0] EMAWA_int;
  wire  EMASA_;
  reg  EMASA_int;
  wire [2:0] EMAB_;
  reg [2:0] EMAB_int;
  wire [1:0] EMAWB_;
  reg [1:0] EMAWB_int;
  wire  EMASB_;
  reg  EMASB_int;
  wire  TENA_;
  reg  TENA_int;
  wire  BENA_;
  reg  BENA_int;
  wire  TCENA_;
  reg  TCENA_int;
  reg  TCENA_p2;
  wire  TWENA_;
  reg  TWENA_int;
  wire [10:0] TAA_;
  reg [10:0] TAA_int;
  wire [79:0] TDA_;
  reg [79:0] TDA_int;
  wire [79:0] TQA_;
  reg [79:0] TQA_int;
  wire  TENB_;
  reg  TENB_int;
  wire  BENB_;
  reg  BENB_int;
  wire  TCENB_;
  reg  TCENB_int;
  reg  TCENB_p2;
  wire  TWENB_;
  reg  TWENB_int;
  wire [10:0] TAB_;
  reg [10:0] TAB_int;
  wire [79:0] TDB_;
  reg [79:0] TDB_int;
  wire [79:0] TQB_;
  reg [79:0] TQB_int;
  wire  RET1N_;
  reg  RET1N_int;
  wire  STOVA_;
  reg  STOVA_int;
  wire  STOVB_;
  reg  STOVB_int;
  wire  COLLDISN_;
  reg  COLLDISN_int;

  assign CENYA = CENYA_; 
  assign WENYA = WENYA_; 
  assign AYA[0] = AYA_[0]; 
  assign AYA[1] = AYA_[1]; 
  assign AYA[2] = AYA_[2]; 
  assign AYA[3] = AYA_[3]; 
  assign AYA[4] = AYA_[4]; 
  assign AYA[5] = AYA_[5]; 
  assign AYA[6] = AYA_[6]; 
  assign AYA[7] = AYA_[7]; 
  assign AYA[8] = AYA_[8]; 
  assign AYA[9] = AYA_[9]; 
  assign AYA[10] = AYA_[10]; 
  assign DYA[0] = DYA_[0]; 
  assign DYA[1] = DYA_[1]; 
  assign DYA[2] = DYA_[2]; 
  assign DYA[3] = DYA_[3]; 
  assign DYA[4] = DYA_[4]; 
  assign DYA[5] = DYA_[5]; 
  assign DYA[6] = DYA_[6]; 
  assign DYA[7] = DYA_[7]; 
  assign DYA[8] = DYA_[8]; 
  assign DYA[9] = DYA_[9]; 
  assign DYA[10] = DYA_[10]; 
  assign DYA[11] = DYA_[11]; 
  assign DYA[12] = DYA_[12]; 
  assign DYA[13] = DYA_[13]; 
  assign DYA[14] = DYA_[14]; 
  assign DYA[15] = DYA_[15]; 
  assign DYA[16] = DYA_[16]; 
  assign DYA[17] = DYA_[17]; 
  assign DYA[18] = DYA_[18]; 
  assign DYA[19] = DYA_[19]; 
  assign DYA[20] = DYA_[20]; 
  assign DYA[21] = DYA_[21]; 
  assign DYA[22] = DYA_[22]; 
  assign DYA[23] = DYA_[23]; 
  assign DYA[24] = DYA_[24]; 
  assign DYA[25] = DYA_[25]; 
  assign DYA[26] = DYA_[26]; 
  assign DYA[27] = DYA_[27]; 
  assign DYA[28] = DYA_[28]; 
  assign DYA[29] = DYA_[29]; 
  assign DYA[30] = DYA_[30]; 
  assign DYA[31] = DYA_[31]; 
  assign DYA[32] = DYA_[32]; 
  assign DYA[33] = DYA_[33]; 
  assign DYA[34] = DYA_[34]; 
  assign DYA[35] = DYA_[35]; 
  assign DYA[36] = DYA_[36]; 
  assign DYA[37] = DYA_[37]; 
  assign DYA[38] = DYA_[38]; 
  assign DYA[39] = DYA_[39]; 
  assign DYA[40] = DYA_[40]; 
  assign DYA[41] = DYA_[41]; 
  assign DYA[42] = DYA_[42]; 
  assign DYA[43] = DYA_[43]; 
  assign DYA[44] = DYA_[44]; 
  assign DYA[45] = DYA_[45]; 
  assign DYA[46] = DYA_[46]; 
  assign DYA[47] = DYA_[47]; 
  assign DYA[48] = DYA_[48]; 
  assign DYA[49] = DYA_[49]; 
  assign DYA[50] = DYA_[50]; 
  assign DYA[51] = DYA_[51]; 
  assign DYA[52] = DYA_[52]; 
  assign DYA[53] = DYA_[53]; 
  assign DYA[54] = DYA_[54]; 
  assign DYA[55] = DYA_[55]; 
  assign DYA[56] = DYA_[56]; 
  assign DYA[57] = DYA_[57]; 
  assign DYA[58] = DYA_[58]; 
  assign DYA[59] = DYA_[59]; 
  assign DYA[60] = DYA_[60]; 
  assign DYA[61] = DYA_[61]; 
  assign DYA[62] = DYA_[62]; 
  assign DYA[63] = DYA_[63]; 
  assign DYA[64] = DYA_[64]; 
  assign DYA[65] = DYA_[65]; 
  assign DYA[66] = DYA_[66]; 
  assign DYA[67] = DYA_[67]; 
  assign DYA[68] = DYA_[68]; 
  assign DYA[69] = DYA_[69]; 
  assign DYA[70] = DYA_[70]; 
  assign DYA[71] = DYA_[71]; 
  assign DYA[72] = DYA_[72]; 
  assign DYA[73] = DYA_[73]; 
  assign DYA[74] = DYA_[74]; 
  assign DYA[75] = DYA_[75]; 
  assign DYA[76] = DYA_[76]; 
  assign DYA[77] = DYA_[77]; 
  assign DYA[78] = DYA_[78]; 
  assign DYA[79] = DYA_[79]; 
  assign CENYB = CENYB_; 
  assign WENYB = WENYB_; 
  assign AYB[0] = AYB_[0]; 
  assign AYB[1] = AYB_[1]; 
  assign AYB[2] = AYB_[2]; 
  assign AYB[3] = AYB_[3]; 
  assign AYB[4] = AYB_[4]; 
  assign AYB[5] = AYB_[5]; 
  assign AYB[6] = AYB_[6]; 
  assign AYB[7] = AYB_[7]; 
  assign AYB[8] = AYB_[8]; 
  assign AYB[9] = AYB_[9]; 
  assign AYB[10] = AYB_[10]; 
  assign DYB[0] = DYB_[0]; 
  assign DYB[1] = DYB_[1]; 
  assign DYB[2] = DYB_[2]; 
  assign DYB[3] = DYB_[3]; 
  assign DYB[4] = DYB_[4]; 
  assign DYB[5] = DYB_[5]; 
  assign DYB[6] = DYB_[6]; 
  assign DYB[7] = DYB_[7]; 
  assign DYB[8] = DYB_[8]; 
  assign DYB[9] = DYB_[9]; 
  assign DYB[10] = DYB_[10]; 
  assign DYB[11] = DYB_[11]; 
  assign DYB[12] = DYB_[12]; 
  assign DYB[13] = DYB_[13]; 
  assign DYB[14] = DYB_[14]; 
  assign DYB[15] = DYB_[15]; 
  assign DYB[16] = DYB_[16]; 
  assign DYB[17] = DYB_[17]; 
  assign DYB[18] = DYB_[18]; 
  assign DYB[19] = DYB_[19]; 
  assign DYB[20] = DYB_[20]; 
  assign DYB[21] = DYB_[21]; 
  assign DYB[22] = DYB_[22]; 
  assign DYB[23] = DYB_[23]; 
  assign DYB[24] = DYB_[24]; 
  assign DYB[25] = DYB_[25]; 
  assign DYB[26] = DYB_[26]; 
  assign DYB[27] = DYB_[27]; 
  assign DYB[28] = DYB_[28]; 
  assign DYB[29] = DYB_[29]; 
  assign DYB[30] = DYB_[30]; 
  assign DYB[31] = DYB_[31]; 
  assign DYB[32] = DYB_[32]; 
  assign DYB[33] = DYB_[33]; 
  assign DYB[34] = DYB_[34]; 
  assign DYB[35] = DYB_[35]; 
  assign DYB[36] = DYB_[36]; 
  assign DYB[37] = DYB_[37]; 
  assign DYB[38] = DYB_[38]; 
  assign DYB[39] = DYB_[39]; 
  assign DYB[40] = DYB_[40]; 
  assign DYB[41] = DYB_[41]; 
  assign DYB[42] = DYB_[42]; 
  assign DYB[43] = DYB_[43]; 
  assign DYB[44] = DYB_[44]; 
  assign DYB[45] = DYB_[45]; 
  assign DYB[46] = DYB_[46]; 
  assign DYB[47] = DYB_[47]; 
  assign DYB[48] = DYB_[48]; 
  assign DYB[49] = DYB_[49]; 
  assign DYB[50] = DYB_[50]; 
  assign DYB[51] = DYB_[51]; 
  assign DYB[52] = DYB_[52]; 
  assign DYB[53] = DYB_[53]; 
  assign DYB[54] = DYB_[54]; 
  assign DYB[55] = DYB_[55]; 
  assign DYB[56] = DYB_[56]; 
  assign DYB[57] = DYB_[57]; 
  assign DYB[58] = DYB_[58]; 
  assign DYB[59] = DYB_[59]; 
  assign DYB[60] = DYB_[60]; 
  assign DYB[61] = DYB_[61]; 
  assign DYB[62] = DYB_[62]; 
  assign DYB[63] = DYB_[63]; 
  assign DYB[64] = DYB_[64]; 
  assign DYB[65] = DYB_[65]; 
  assign DYB[66] = DYB_[66]; 
  assign DYB[67] = DYB_[67]; 
  assign DYB[68] = DYB_[68]; 
  assign DYB[69] = DYB_[69]; 
  assign DYB[70] = DYB_[70]; 
  assign DYB[71] = DYB_[71]; 
  assign DYB[72] = DYB_[72]; 
  assign DYB[73] = DYB_[73]; 
  assign DYB[74] = DYB_[74]; 
  assign DYB[75] = DYB_[75]; 
  assign DYB[76] = DYB_[76]; 
  assign DYB[77] = DYB_[77]; 
  assign DYB[78] = DYB_[78]; 
  assign DYB[79] = DYB_[79]; 
  assign QA[0] = QA_[0]; 
  assign QA[1] = QA_[1]; 
  assign QA[2] = QA_[2]; 
  assign QA[3] = QA_[3]; 
  assign QA[4] = QA_[4]; 
  assign QA[5] = QA_[5]; 
  assign QA[6] = QA_[6]; 
  assign QA[7] = QA_[7]; 
  assign QA[8] = QA_[8]; 
  assign QA[9] = QA_[9]; 
  assign QA[10] = QA_[10]; 
  assign QA[11] = QA_[11]; 
  assign QA[12] = QA_[12]; 
  assign QA[13] = QA_[13]; 
  assign QA[14] = QA_[14]; 
  assign QA[15] = QA_[15]; 
  assign QA[16] = QA_[16]; 
  assign QA[17] = QA_[17]; 
  assign QA[18] = QA_[18]; 
  assign QA[19] = QA_[19]; 
  assign QA[20] = QA_[20]; 
  assign QA[21] = QA_[21]; 
  assign QA[22] = QA_[22]; 
  assign QA[23] = QA_[23]; 
  assign QA[24] = QA_[24]; 
  assign QA[25] = QA_[25]; 
  assign QA[26] = QA_[26]; 
  assign QA[27] = QA_[27]; 
  assign QA[28] = QA_[28]; 
  assign QA[29] = QA_[29]; 
  assign QA[30] = QA_[30]; 
  assign QA[31] = QA_[31]; 
  assign QA[32] = QA_[32]; 
  assign QA[33] = QA_[33]; 
  assign QA[34] = QA_[34]; 
  assign QA[35] = QA_[35]; 
  assign QA[36] = QA_[36]; 
  assign QA[37] = QA_[37]; 
  assign QA[38] = QA_[38]; 
  assign QA[39] = QA_[39]; 
  assign QA[40] = QA_[40]; 
  assign QA[41] = QA_[41]; 
  assign QA[42] = QA_[42]; 
  assign QA[43] = QA_[43]; 
  assign QA[44] = QA_[44]; 
  assign QA[45] = QA_[45]; 
  assign QA[46] = QA_[46]; 
  assign QA[47] = QA_[47]; 
  assign QA[48] = QA_[48]; 
  assign QA[49] = QA_[49]; 
  assign QA[50] = QA_[50]; 
  assign QA[51] = QA_[51]; 
  assign QA[52] = QA_[52]; 
  assign QA[53] = QA_[53]; 
  assign QA[54] = QA_[54]; 
  assign QA[55] = QA_[55]; 
  assign QA[56] = QA_[56]; 
  assign QA[57] = QA_[57]; 
  assign QA[58] = QA_[58]; 
  assign QA[59] = QA_[59]; 
  assign QA[60] = QA_[60]; 
  assign QA[61] = QA_[61]; 
  assign QA[62] = QA_[62]; 
  assign QA[63] = QA_[63]; 
  assign QA[64] = QA_[64]; 
  assign QA[65] = QA_[65]; 
  assign QA[66] = QA_[66]; 
  assign QA[67] = QA_[67]; 
  assign QA[68] = QA_[68]; 
  assign QA[69] = QA_[69]; 
  assign QA[70] = QA_[70]; 
  assign QA[71] = QA_[71]; 
  assign QA[72] = QA_[72]; 
  assign QA[73] = QA_[73]; 
  assign QA[74] = QA_[74]; 
  assign QA[75] = QA_[75]; 
  assign QA[76] = QA_[76]; 
  assign QA[77] = QA_[77]; 
  assign QA[78] = QA_[78]; 
  assign QA[79] = QA_[79]; 
  assign QB[0] = QB_[0]; 
  assign QB[1] = QB_[1]; 
  assign QB[2] = QB_[2]; 
  assign QB[3] = QB_[3]; 
  assign QB[4] = QB_[4]; 
  assign QB[5] = QB_[5]; 
  assign QB[6] = QB_[6]; 
  assign QB[7] = QB_[7]; 
  assign QB[8] = QB_[8]; 
  assign QB[9] = QB_[9]; 
  assign QB[10] = QB_[10]; 
  assign QB[11] = QB_[11]; 
  assign QB[12] = QB_[12]; 
  assign QB[13] = QB_[13]; 
  assign QB[14] = QB_[14]; 
  assign QB[15] = QB_[15]; 
  assign QB[16] = QB_[16]; 
  assign QB[17] = QB_[17]; 
  assign QB[18] = QB_[18]; 
  assign QB[19] = QB_[19]; 
  assign QB[20] = QB_[20]; 
  assign QB[21] = QB_[21]; 
  assign QB[22] = QB_[22]; 
  assign QB[23] = QB_[23]; 
  assign QB[24] = QB_[24]; 
  assign QB[25] = QB_[25]; 
  assign QB[26] = QB_[26]; 
  assign QB[27] = QB_[27]; 
  assign QB[28] = QB_[28]; 
  assign QB[29] = QB_[29]; 
  assign QB[30] = QB_[30]; 
  assign QB[31] = QB_[31]; 
  assign QB[32] = QB_[32]; 
  assign QB[33] = QB_[33]; 
  assign QB[34] = QB_[34]; 
  assign QB[35] = QB_[35]; 
  assign QB[36] = QB_[36]; 
  assign QB[37] = QB_[37]; 
  assign QB[38] = QB_[38]; 
  assign QB[39] = QB_[39]; 
  assign QB[40] = QB_[40]; 
  assign QB[41] = QB_[41]; 
  assign QB[42] = QB_[42]; 
  assign QB[43] = QB_[43]; 
  assign QB[44] = QB_[44]; 
  assign QB[45] = QB_[45]; 
  assign QB[46] = QB_[46]; 
  assign QB[47] = QB_[47]; 
  assign QB[48] = QB_[48]; 
  assign QB[49] = QB_[49]; 
  assign QB[50] = QB_[50]; 
  assign QB[51] = QB_[51]; 
  assign QB[52] = QB_[52]; 
  assign QB[53] = QB_[53]; 
  assign QB[54] = QB_[54]; 
  assign QB[55] = QB_[55]; 
  assign QB[56] = QB_[56]; 
  assign QB[57] = QB_[57]; 
  assign QB[58] = QB_[58]; 
  assign QB[59] = QB_[59]; 
  assign QB[60] = QB_[60]; 
  assign QB[61] = QB_[61]; 
  assign QB[62] = QB_[62]; 
  assign QB[63] = QB_[63]; 
  assign QB[64] = QB_[64]; 
  assign QB[65] = QB_[65]; 
  assign QB[66] = QB_[66]; 
  assign QB[67] = QB_[67]; 
  assign QB[68] = QB_[68]; 
  assign QB[69] = QB_[69]; 
  assign QB[70] = QB_[70]; 
  assign QB[71] = QB_[71]; 
  assign QB[72] = QB_[72]; 
  assign QB[73] = QB_[73]; 
  assign QB[74] = QB_[74]; 
  assign QB[75] = QB_[75]; 
  assign QB[76] = QB_[76]; 
  assign QB[77] = QB_[77]; 
  assign QB[78] = QB_[78]; 
  assign QB[79] = QB_[79]; 
  assign CLKA_ = CLKA;
  assign CENA_ = CENA;
  assign WENA_ = WENA;
  assign AA_[0] = AA[0];
  assign AA_[1] = AA[1];
  assign AA_[2] = AA[2];
  assign AA_[3] = AA[3];
  assign AA_[4] = AA[4];
  assign AA_[5] = AA[5];
  assign AA_[6] = AA[6];
  assign AA_[7] = AA[7];
  assign AA_[8] = AA[8];
  assign AA_[9] = AA[9];
  assign AA_[10] = AA[10];
  assign DA_[0] = DA[0];
  assign DA_[1] = DA[1];
  assign DA_[2] = DA[2];
  assign DA_[3] = DA[3];
  assign DA_[4] = DA[4];
  assign DA_[5] = DA[5];
  assign DA_[6] = DA[6];
  assign DA_[7] = DA[7];
  assign DA_[8] = DA[8];
  assign DA_[9] = DA[9];
  assign DA_[10] = DA[10];
  assign DA_[11] = DA[11];
  assign DA_[12] = DA[12];
  assign DA_[13] = DA[13];
  assign DA_[14] = DA[14];
  assign DA_[15] = DA[15];
  assign DA_[16] = DA[16];
  assign DA_[17] = DA[17];
  assign DA_[18] = DA[18];
  assign DA_[19] = DA[19];
  assign DA_[20] = DA[20];
  assign DA_[21] = DA[21];
  assign DA_[22] = DA[22];
  assign DA_[23] = DA[23];
  assign DA_[24] = DA[24];
  assign DA_[25] = DA[25];
  assign DA_[26] = DA[26];
  assign DA_[27] = DA[27];
  assign DA_[28] = DA[28];
  assign DA_[29] = DA[29];
  assign DA_[30] = DA[30];
  assign DA_[31] = DA[31];
  assign DA_[32] = DA[32];
  assign DA_[33] = DA[33];
  assign DA_[34] = DA[34];
  assign DA_[35] = DA[35];
  assign DA_[36] = DA[36];
  assign DA_[37] = DA[37];
  assign DA_[38] = DA[38];
  assign DA_[39] = DA[39];
  assign DA_[40] = DA[40];
  assign DA_[41] = DA[41];
  assign DA_[42] = DA[42];
  assign DA_[43] = DA[43];
  assign DA_[44] = DA[44];
  assign DA_[45] = DA[45];
  assign DA_[46] = DA[46];
  assign DA_[47] = DA[47];
  assign DA_[48] = DA[48];
  assign DA_[49] = DA[49];
  assign DA_[50] = DA[50];
  assign DA_[51] = DA[51];
  assign DA_[52] = DA[52];
  assign DA_[53] = DA[53];
  assign DA_[54] = DA[54];
  assign DA_[55] = DA[55];
  assign DA_[56] = DA[56];
  assign DA_[57] = DA[57];
  assign DA_[58] = DA[58];
  assign DA_[59] = DA[59];
  assign DA_[60] = DA[60];
  assign DA_[61] = DA[61];
  assign DA_[62] = DA[62];
  assign DA_[63] = DA[63];
  assign DA_[64] = DA[64];
  assign DA_[65] = DA[65];
  assign DA_[66] = DA[66];
  assign DA_[67] = DA[67];
  assign DA_[68] = DA[68];
  assign DA_[69] = DA[69];
  assign DA_[70] = DA[70];
  assign DA_[71] = DA[71];
  assign DA_[72] = DA[72];
  assign DA_[73] = DA[73];
  assign DA_[74] = DA[74];
  assign DA_[75] = DA[75];
  assign DA_[76] = DA[76];
  assign DA_[77] = DA[77];
  assign DA_[78] = DA[78];
  assign DA_[79] = DA[79];
  assign CLKB_ = CLKB;
  assign CENB_ = CENB;
  assign WENB_ = WENB;
  assign AB_[0] = AB[0];
  assign AB_[1] = AB[1];
  assign AB_[2] = AB[2];
  assign AB_[3] = AB[3];
  assign AB_[4] = AB[4];
  assign AB_[5] = AB[5];
  assign AB_[6] = AB[6];
  assign AB_[7] = AB[7];
  assign AB_[8] = AB[8];
  assign AB_[9] = AB[9];
  assign AB_[10] = AB[10];
  assign DB_[0] = DB[0];
  assign DB_[1] = DB[1];
  assign DB_[2] = DB[2];
  assign DB_[3] = DB[3];
  assign DB_[4] = DB[4];
  assign DB_[5] = DB[5];
  assign DB_[6] = DB[6];
  assign DB_[7] = DB[7];
  assign DB_[8] = DB[8];
  assign DB_[9] = DB[9];
  assign DB_[10] = DB[10];
  assign DB_[11] = DB[11];
  assign DB_[12] = DB[12];
  assign DB_[13] = DB[13];
  assign DB_[14] = DB[14];
  assign DB_[15] = DB[15];
  assign DB_[16] = DB[16];
  assign DB_[17] = DB[17];
  assign DB_[18] = DB[18];
  assign DB_[19] = DB[19];
  assign DB_[20] = DB[20];
  assign DB_[21] = DB[21];
  assign DB_[22] = DB[22];
  assign DB_[23] = DB[23];
  assign DB_[24] = DB[24];
  assign DB_[25] = DB[25];
  assign DB_[26] = DB[26];
  assign DB_[27] = DB[27];
  assign DB_[28] = DB[28];
  assign DB_[29] = DB[29];
  assign DB_[30] = DB[30];
  assign DB_[31] = DB[31];
  assign DB_[32] = DB[32];
  assign DB_[33] = DB[33];
  assign DB_[34] = DB[34];
  assign DB_[35] = DB[35];
  assign DB_[36] = DB[36];
  assign DB_[37] = DB[37];
  assign DB_[38] = DB[38];
  assign DB_[39] = DB[39];
  assign DB_[40] = DB[40];
  assign DB_[41] = DB[41];
  assign DB_[42] = DB[42];
  assign DB_[43] = DB[43];
  assign DB_[44] = DB[44];
  assign DB_[45] = DB[45];
  assign DB_[46] = DB[46];
  assign DB_[47] = DB[47];
  assign DB_[48] = DB[48];
  assign DB_[49] = DB[49];
  assign DB_[50] = DB[50];
  assign DB_[51] = DB[51];
  assign DB_[52] = DB[52];
  assign DB_[53] = DB[53];
  assign DB_[54] = DB[54];
  assign DB_[55] = DB[55];
  assign DB_[56] = DB[56];
  assign DB_[57] = DB[57];
  assign DB_[58] = DB[58];
  assign DB_[59] = DB[59];
  assign DB_[60] = DB[60];
  assign DB_[61] = DB[61];
  assign DB_[62] = DB[62];
  assign DB_[63] = DB[63];
  assign DB_[64] = DB[64];
  assign DB_[65] = DB[65];
  assign DB_[66] = DB[66];
  assign DB_[67] = DB[67];
  assign DB_[68] = DB[68];
  assign DB_[69] = DB[69];
  assign DB_[70] = DB[70];
  assign DB_[71] = DB[71];
  assign DB_[72] = DB[72];
  assign DB_[73] = DB[73];
  assign DB_[74] = DB[74];
  assign DB_[75] = DB[75];
  assign DB_[76] = DB[76];
  assign DB_[77] = DB[77];
  assign DB_[78] = DB[78];
  assign DB_[79] = DB[79];
  assign EMAA_[0] = EMAA[0];
  assign EMAA_[1] = EMAA[1];
  assign EMAA_[2] = EMAA[2];
  assign EMAWA_[0] = EMAWA[0];
  assign EMAWA_[1] = EMAWA[1];
  assign EMASA_ = EMASA;
  assign EMAB_[0] = EMAB[0];
  assign EMAB_[1] = EMAB[1];
  assign EMAB_[2] = EMAB[2];
  assign EMAWB_[0] = EMAWB[0];
  assign EMAWB_[1] = EMAWB[1];
  assign EMASB_ = EMASB;
  assign TENA_ = TENA;
  assign BENA_ = BENA;
  assign TCENA_ = TCENA;
  assign TWENA_ = TWENA;
  assign TAA_[0] = TAA[0];
  assign TAA_[1] = TAA[1];
  assign TAA_[2] = TAA[2];
  assign TAA_[3] = TAA[3];
  assign TAA_[4] = TAA[4];
  assign TAA_[5] = TAA[5];
  assign TAA_[6] = TAA[6];
  assign TAA_[7] = TAA[7];
  assign TAA_[8] = TAA[8];
  assign TAA_[9] = TAA[9];
  assign TAA_[10] = TAA[10];
  assign TDA_[0] = TDA[0];
  assign TDA_[1] = TDA[1];
  assign TDA_[2] = TDA[2];
  assign TDA_[3] = TDA[3];
  assign TDA_[4] = TDA[4];
  assign TDA_[5] = TDA[5];
  assign TDA_[6] = TDA[6];
  assign TDA_[7] = TDA[7];
  assign TDA_[8] = TDA[8];
  assign TDA_[9] = TDA[9];
  assign TDA_[10] = TDA[10];
  assign TDA_[11] = TDA[11];
  assign TDA_[12] = TDA[12];
  assign TDA_[13] = TDA[13];
  assign TDA_[14] = TDA[14];
  assign TDA_[15] = TDA[15];
  assign TDA_[16] = TDA[16];
  assign TDA_[17] = TDA[17];
  assign TDA_[18] = TDA[18];
  assign TDA_[19] = TDA[19];
  assign TDA_[20] = TDA[20];
  assign TDA_[21] = TDA[21];
  assign TDA_[22] = TDA[22];
  assign TDA_[23] = TDA[23];
  assign TDA_[24] = TDA[24];
  assign TDA_[25] = TDA[25];
  assign TDA_[26] = TDA[26];
  assign TDA_[27] = TDA[27];
  assign TDA_[28] = TDA[28];
  assign TDA_[29] = TDA[29];
  assign TDA_[30] = TDA[30];
  assign TDA_[31] = TDA[31];
  assign TDA_[32] = TDA[32];
  assign TDA_[33] = TDA[33];
  assign TDA_[34] = TDA[34];
  assign TDA_[35] = TDA[35];
  assign TDA_[36] = TDA[36];
  assign TDA_[37] = TDA[37];
  assign TDA_[38] = TDA[38];
  assign TDA_[39] = TDA[39];
  assign TDA_[40] = TDA[40];
  assign TDA_[41] = TDA[41];
  assign TDA_[42] = TDA[42];
  assign TDA_[43] = TDA[43];
  assign TDA_[44] = TDA[44];
  assign TDA_[45] = TDA[45];
  assign TDA_[46] = TDA[46];
  assign TDA_[47] = TDA[47];
  assign TDA_[48] = TDA[48];
  assign TDA_[49] = TDA[49];
  assign TDA_[50] = TDA[50];
  assign TDA_[51] = TDA[51];
  assign TDA_[52] = TDA[52];
  assign TDA_[53] = TDA[53];
  assign TDA_[54] = TDA[54];
  assign TDA_[55] = TDA[55];
  assign TDA_[56] = TDA[56];
  assign TDA_[57] = TDA[57];
  assign TDA_[58] = TDA[58];
  assign TDA_[59] = TDA[59];
  assign TDA_[60] = TDA[60];
  assign TDA_[61] = TDA[61];
  assign TDA_[62] = TDA[62];
  assign TDA_[63] = TDA[63];
  assign TDA_[64] = TDA[64];
  assign TDA_[65] = TDA[65];
  assign TDA_[66] = TDA[66];
  assign TDA_[67] = TDA[67];
  assign TDA_[68] = TDA[68];
  assign TDA_[69] = TDA[69];
  assign TDA_[70] = TDA[70];
  assign TDA_[71] = TDA[71];
  assign TDA_[72] = TDA[72];
  assign TDA_[73] = TDA[73];
  assign TDA_[74] = TDA[74];
  assign TDA_[75] = TDA[75];
  assign TDA_[76] = TDA[76];
  assign TDA_[77] = TDA[77];
  assign TDA_[78] = TDA[78];
  assign TDA_[79] = TDA[79];
  assign TQA_[0] = TQA[0];
  assign TQA_[1] = TQA[1];
  assign TQA_[2] = TQA[2];
  assign TQA_[3] = TQA[3];
  assign TQA_[4] = TQA[4];
  assign TQA_[5] = TQA[5];
  assign TQA_[6] = TQA[6];
  assign TQA_[7] = TQA[7];
  assign TQA_[8] = TQA[8];
  assign TQA_[9] = TQA[9];
  assign TQA_[10] = TQA[10];
  assign TQA_[11] = TQA[11];
  assign TQA_[12] = TQA[12];
  assign TQA_[13] = TQA[13];
  assign TQA_[14] = TQA[14];
  assign TQA_[15] = TQA[15];
  assign TQA_[16] = TQA[16];
  assign TQA_[17] = TQA[17];
  assign TQA_[18] = TQA[18];
  assign TQA_[19] = TQA[19];
  assign TQA_[20] = TQA[20];
  assign TQA_[21] = TQA[21];
  assign TQA_[22] = TQA[22];
  assign TQA_[23] = TQA[23];
  assign TQA_[24] = TQA[24];
  assign TQA_[25] = TQA[25];
  assign TQA_[26] = TQA[26];
  assign TQA_[27] = TQA[27];
  assign TQA_[28] = TQA[28];
  assign TQA_[29] = TQA[29];
  assign TQA_[30] = TQA[30];
  assign TQA_[31] = TQA[31];
  assign TQA_[32] = TQA[32];
  assign TQA_[33] = TQA[33];
  assign TQA_[34] = TQA[34];
  assign TQA_[35] = TQA[35];
  assign TQA_[36] = TQA[36];
  assign TQA_[37] = TQA[37];
  assign TQA_[38] = TQA[38];
  assign TQA_[39] = TQA[39];
  assign TQA_[40] = TQA[40];
  assign TQA_[41] = TQA[41];
  assign TQA_[42] = TQA[42];
  assign TQA_[43] = TQA[43];
  assign TQA_[44] = TQA[44];
  assign TQA_[45] = TQA[45];
  assign TQA_[46] = TQA[46];
  assign TQA_[47] = TQA[47];
  assign TQA_[48] = TQA[48];
  assign TQA_[49] = TQA[49];
  assign TQA_[50] = TQA[50];
  assign TQA_[51] = TQA[51];
  assign TQA_[52] = TQA[52];
  assign TQA_[53] = TQA[53];
  assign TQA_[54] = TQA[54];
  assign TQA_[55] = TQA[55];
  assign TQA_[56] = TQA[56];
  assign TQA_[57] = TQA[57];
  assign TQA_[58] = TQA[58];
  assign TQA_[59] = TQA[59];
  assign TQA_[60] = TQA[60];
  assign TQA_[61] = TQA[61];
  assign TQA_[62] = TQA[62];
  assign TQA_[63] = TQA[63];
  assign TQA_[64] = TQA[64];
  assign TQA_[65] = TQA[65];
  assign TQA_[66] = TQA[66];
  assign TQA_[67] = TQA[67];
  assign TQA_[68] = TQA[68];
  assign TQA_[69] = TQA[69];
  assign TQA_[70] = TQA[70];
  assign TQA_[71] = TQA[71];
  assign TQA_[72] = TQA[72];
  assign TQA_[73] = TQA[73];
  assign TQA_[74] = TQA[74];
  assign TQA_[75] = TQA[75];
  assign TQA_[76] = TQA[76];
  assign TQA_[77] = TQA[77];
  assign TQA_[78] = TQA[78];
  assign TQA_[79] = TQA[79];
  assign TENB_ = TENB;
  assign BENB_ = BENB;
  assign TCENB_ = TCENB;
  assign TWENB_ = TWENB;
  assign TAB_[0] = TAB[0];
  assign TAB_[1] = TAB[1];
  assign TAB_[2] = TAB[2];
  assign TAB_[3] = TAB[3];
  assign TAB_[4] = TAB[4];
  assign TAB_[5] = TAB[5];
  assign TAB_[6] = TAB[6];
  assign TAB_[7] = TAB[7];
  assign TAB_[8] = TAB[8];
  assign TAB_[9] = TAB[9];
  assign TAB_[10] = TAB[10];
  assign TDB_[0] = TDB[0];
  assign TDB_[1] = TDB[1];
  assign TDB_[2] = TDB[2];
  assign TDB_[3] = TDB[3];
  assign TDB_[4] = TDB[4];
  assign TDB_[5] = TDB[5];
  assign TDB_[6] = TDB[6];
  assign TDB_[7] = TDB[7];
  assign TDB_[8] = TDB[8];
  assign TDB_[9] = TDB[9];
  assign TDB_[10] = TDB[10];
  assign TDB_[11] = TDB[11];
  assign TDB_[12] = TDB[12];
  assign TDB_[13] = TDB[13];
  assign TDB_[14] = TDB[14];
  assign TDB_[15] = TDB[15];
  assign TDB_[16] = TDB[16];
  assign TDB_[17] = TDB[17];
  assign TDB_[18] = TDB[18];
  assign TDB_[19] = TDB[19];
  assign TDB_[20] = TDB[20];
  assign TDB_[21] = TDB[21];
  assign TDB_[22] = TDB[22];
  assign TDB_[23] = TDB[23];
  assign TDB_[24] = TDB[24];
  assign TDB_[25] = TDB[25];
  assign TDB_[26] = TDB[26];
  assign TDB_[27] = TDB[27];
  assign TDB_[28] = TDB[28];
  assign TDB_[29] = TDB[29];
  assign TDB_[30] = TDB[30];
  assign TDB_[31] = TDB[31];
  assign TDB_[32] = TDB[32];
  assign TDB_[33] = TDB[33];
  assign TDB_[34] = TDB[34];
  assign TDB_[35] = TDB[35];
  assign TDB_[36] = TDB[36];
  assign TDB_[37] = TDB[37];
  assign TDB_[38] = TDB[38];
  assign TDB_[39] = TDB[39];
  assign TDB_[40] = TDB[40];
  assign TDB_[41] = TDB[41];
  assign TDB_[42] = TDB[42];
  assign TDB_[43] = TDB[43];
  assign TDB_[44] = TDB[44];
  assign TDB_[45] = TDB[45];
  assign TDB_[46] = TDB[46];
  assign TDB_[47] = TDB[47];
  assign TDB_[48] = TDB[48];
  assign TDB_[49] = TDB[49];
  assign TDB_[50] = TDB[50];
  assign TDB_[51] = TDB[51];
  assign TDB_[52] = TDB[52];
  assign TDB_[53] = TDB[53];
  assign TDB_[54] = TDB[54];
  assign TDB_[55] = TDB[55];
  assign TDB_[56] = TDB[56];
  assign TDB_[57] = TDB[57];
  assign TDB_[58] = TDB[58];
  assign TDB_[59] = TDB[59];
  assign TDB_[60] = TDB[60];
  assign TDB_[61] = TDB[61];
  assign TDB_[62] = TDB[62];
  assign TDB_[63] = TDB[63];
  assign TDB_[64] = TDB[64];
  assign TDB_[65] = TDB[65];
  assign TDB_[66] = TDB[66];
  assign TDB_[67] = TDB[67];
  assign TDB_[68] = TDB[68];
  assign TDB_[69] = TDB[69];
  assign TDB_[70] = TDB[70];
  assign TDB_[71] = TDB[71];
  assign TDB_[72] = TDB[72];
  assign TDB_[73] = TDB[73];
  assign TDB_[74] = TDB[74];
  assign TDB_[75] = TDB[75];
  assign TDB_[76] = TDB[76];
  assign TDB_[77] = TDB[77];
  assign TDB_[78] = TDB[78];
  assign TDB_[79] = TDB[79];
  assign TQB_[0] = TQB[0];
  assign TQB_[1] = TQB[1];
  assign TQB_[2] = TQB[2];
  assign TQB_[3] = TQB[3];
  assign TQB_[4] = TQB[4];
  assign TQB_[5] = TQB[5];
  assign TQB_[6] = TQB[6];
  assign TQB_[7] = TQB[7];
  assign TQB_[8] = TQB[8];
  assign TQB_[9] = TQB[9];
  assign TQB_[10] = TQB[10];
  assign TQB_[11] = TQB[11];
  assign TQB_[12] = TQB[12];
  assign TQB_[13] = TQB[13];
  assign TQB_[14] = TQB[14];
  assign TQB_[15] = TQB[15];
  assign TQB_[16] = TQB[16];
  assign TQB_[17] = TQB[17];
  assign TQB_[18] = TQB[18];
  assign TQB_[19] = TQB[19];
  assign TQB_[20] = TQB[20];
  assign TQB_[21] = TQB[21];
  assign TQB_[22] = TQB[22];
  assign TQB_[23] = TQB[23];
  assign TQB_[24] = TQB[24];
  assign TQB_[25] = TQB[25];
  assign TQB_[26] = TQB[26];
  assign TQB_[27] = TQB[27];
  assign TQB_[28] = TQB[28];
  assign TQB_[29] = TQB[29];
  assign TQB_[30] = TQB[30];
  assign TQB_[31] = TQB[31];
  assign TQB_[32] = TQB[32];
  assign TQB_[33] = TQB[33];
  assign TQB_[34] = TQB[34];
  assign TQB_[35] = TQB[35];
  assign TQB_[36] = TQB[36];
  assign TQB_[37] = TQB[37];
  assign TQB_[38] = TQB[38];
  assign TQB_[39] = TQB[39];
  assign TQB_[40] = TQB[40];
  assign TQB_[41] = TQB[41];
  assign TQB_[42] = TQB[42];
  assign TQB_[43] = TQB[43];
  assign TQB_[44] = TQB[44];
  assign TQB_[45] = TQB[45];
  assign TQB_[46] = TQB[46];
  assign TQB_[47] = TQB[47];
  assign TQB_[48] = TQB[48];
  assign TQB_[49] = TQB[49];
  assign TQB_[50] = TQB[50];
  assign TQB_[51] = TQB[51];
  assign TQB_[52] = TQB[52];
  assign TQB_[53] = TQB[53];
  assign TQB_[54] = TQB[54];
  assign TQB_[55] = TQB[55];
  assign TQB_[56] = TQB[56];
  assign TQB_[57] = TQB[57];
  assign TQB_[58] = TQB[58];
  assign TQB_[59] = TQB[59];
  assign TQB_[60] = TQB[60];
  assign TQB_[61] = TQB[61];
  assign TQB_[62] = TQB[62];
  assign TQB_[63] = TQB[63];
  assign TQB_[64] = TQB[64];
  assign TQB_[65] = TQB[65];
  assign TQB_[66] = TQB[66];
  assign TQB_[67] = TQB[67];
  assign TQB_[68] = TQB[68];
  assign TQB_[69] = TQB[69];
  assign TQB_[70] = TQB[70];
  assign TQB_[71] = TQB[71];
  assign TQB_[72] = TQB[72];
  assign TQB_[73] = TQB[73];
  assign TQB_[74] = TQB[74];
  assign TQB_[75] = TQB[75];
  assign TQB_[76] = TQB[76];
  assign TQB_[77] = TQB[77];
  assign TQB_[78] = TQB[78];
  assign TQB_[79] = TQB[79];
  assign RET1N_ = RET1N;
  assign STOVA_ = STOVA;
  assign STOVB_ = STOVB;
  assign COLLDISN_ = COLLDISN;

  assign `ARM_UD_DP CENYA_ = RET1N_ ? (TENA_ ? CENA_ : TCENA_) : 1'bx;
  assign `ARM_UD_DP WENYA_ = RET1N_ ? (TENA_ ? WENA_ : TWENA_) : 1'bx;
  assign `ARM_UD_DP AYA_ = RET1N_ ? (TENA_ ? AA_ : TAA_) : {11{1'bx}};
  assign `ARM_UD_DP DYA_ = RET1N_ ? (TENA_ ? DA_ : TDA_) : {80{1'bx}};
  assign `ARM_UD_DP CENYB_ = RET1N_ ? (TENB_ ? CENB_ : TCENB_) : 1'bx;
  assign `ARM_UD_DP WENYB_ = RET1N_ ? (TENB_ ? WENB_ : TWENB_) : 1'bx;
  assign `ARM_UD_DP AYB_ = RET1N_ ? (TENB_ ? AB_ : TAB_) : {11{1'bx}};
  assign `ARM_UD_DP DYB_ = RET1N_ ? (TENB_ ? DB_ : TDB_) : {80{1'bx}};
  assign `ARM_UD_SEQ QA_ = RET1N_ ? (BENA_ ? ((STOVA_ ? (QA_int_delayed) : (QA_int))) : TQA_) : {80{1'bx}};
  assign `ARM_UD_SEQ QB_ = RET1N_ ? (BENB_ ? ((STOVB_ ? (QB_int_delayed) : (QB_int))) : TQB_) : {80{1'bx}};

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
	reg [10:0] Atemp;
  begin
	$readmemb(filename, memld);
     if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {80{1'b1}};
        row_mask =  ( {3'b000, writeEnable[79], 3'b000, writeEnable[78], 3'b000, writeEnable[77],
          3'b000, writeEnable[76], 3'b000, writeEnable[75], 3'b000, writeEnable[74],
          3'b000, writeEnable[73], 3'b000, writeEnable[72], 3'b000, writeEnable[71],
          3'b000, writeEnable[70], 3'b000, writeEnable[69], 3'b000, writeEnable[68],
          3'b000, writeEnable[67], 3'b000, writeEnable[66], 3'b000, writeEnable[65],
          3'b000, writeEnable[64], 3'b000, writeEnable[63], 3'b000, writeEnable[62],
          3'b000, writeEnable[61], 3'b000, writeEnable[60], 3'b000, writeEnable[59],
          3'b000, writeEnable[58], 3'b000, writeEnable[57], 3'b000, writeEnable[56],
          3'b000, writeEnable[55], 3'b000, writeEnable[54], 3'b000, writeEnable[53],
          3'b000, writeEnable[52], 3'b000, writeEnable[51], 3'b000, writeEnable[50],
          3'b000, writeEnable[49], 3'b000, writeEnable[48], 3'b000, writeEnable[47],
          3'b000, writeEnable[46], 3'b000, writeEnable[45], 3'b000, writeEnable[44],
          3'b000, writeEnable[43], 3'b000, writeEnable[42], 3'b000, writeEnable[41],
          3'b000, writeEnable[40], 3'b000, writeEnable[39], 3'b000, writeEnable[38],
          3'b000, writeEnable[37], 3'b000, writeEnable[36], 3'b000, writeEnable[35],
          3'b000, writeEnable[34], 3'b000, writeEnable[33], 3'b000, writeEnable[32],
          3'b000, writeEnable[31], 3'b000, writeEnable[30], 3'b000, writeEnable[29],
          3'b000, writeEnable[28], 3'b000, writeEnable[27], 3'b000, writeEnable[26],
          3'b000, writeEnable[25], 3'b000, writeEnable[24], 3'b000, writeEnable[23],
          3'b000, writeEnable[22], 3'b000, writeEnable[21], 3'b000, writeEnable[20],
          3'b000, writeEnable[19], 3'b000, writeEnable[18], 3'b000, writeEnable[17],
          3'b000, writeEnable[16], 3'b000, writeEnable[15], 3'b000, writeEnable[14],
          3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[79], 3'b000, wordtemp[78], 3'b000, wordtemp[77],
          3'b000, wordtemp[76], 3'b000, wordtemp[75], 3'b000, wordtemp[74], 3'b000, wordtemp[73],
          3'b000, wordtemp[72], 3'b000, wordtemp[71], 3'b000, wordtemp[70], 3'b000, wordtemp[69],
          3'b000, wordtemp[68], 3'b000, wordtemp[67], 3'b000, wordtemp[66], 3'b000, wordtemp[65],
          3'b000, wordtemp[64], 3'b000, wordtemp[63], 3'b000, wordtemp[62], 3'b000, wordtemp[61],
          3'b000, wordtemp[60], 3'b000, wordtemp[59], 3'b000, wordtemp[58], 3'b000, wordtemp[57],
          3'b000, wordtemp[56], 3'b000, wordtemp[55], 3'b000, wordtemp[54], 3'b000, wordtemp[53],
          3'b000, wordtemp[52], 3'b000, wordtemp[51], 3'b000, wordtemp[50], 3'b000, wordtemp[49],
          3'b000, wordtemp[48], 3'b000, wordtemp[47], 3'b000, wordtemp[46], 3'b000, wordtemp[45],
          3'b000, wordtemp[44], 3'b000, wordtemp[43], 3'b000, wordtemp[42], 3'b000, wordtemp[41],
          3'b000, wordtemp[40], 3'b000, wordtemp[39], 3'b000, wordtemp[38], 3'b000, wordtemp[37],
          3'b000, wordtemp[36], 3'b000, wordtemp[35], 3'b000, wordtemp[34], 3'b000, wordtemp[33],
          3'b000, wordtemp[32], 3'b000, wordtemp[31], 3'b000, wordtemp[30], 3'b000, wordtemp[29],
          3'b000, wordtemp[28], 3'b000, wordtemp[27], 3'b000, wordtemp[26], 3'b000, wordtemp[25],
          3'b000, wordtemp[24], 3'b000, wordtemp[23], 3'b000, wordtemp[22], 3'b000, wordtemp[21],
          3'b000, wordtemp[20], 3'b000, wordtemp[19], 3'b000, wordtemp[18], 3'b000, wordtemp[17],
          3'b000, wordtemp[16], 3'b000, wordtemp[15], 3'b000, wordtemp[14], 3'b000, wordtemp[13],
          3'b000, wordtemp[12], 3'b000, wordtemp[11], 3'b000, wordtemp[10], 3'b000, wordtemp[9],
          3'b000, wordtemp[8], 3'b000, wordtemp[7], 3'b000, wordtemp[6], 3'b000, wordtemp[5],
          3'b000, wordtemp[4], 3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
          3'b000, wordtemp[0]} << mux_address);
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
	reg [10:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
     if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {80{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[316], data_out[312], data_out[308], data_out[304], data_out[300],
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
      QA_int = {shifted_readLatch0[79], shifted_readLatch0[78], shifted_readLatch0[77],
        shifted_readLatch0[76], shifted_readLatch0[75], shifted_readLatch0[74], shifted_readLatch0[73],
        shifted_readLatch0[72], shifted_readLatch0[71], shifted_readLatch0[70], shifted_readLatch0[69],
        shifted_readLatch0[68], shifted_readLatch0[67], shifted_readLatch0[66], shifted_readLatch0[65],
        shifted_readLatch0[64], shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
        shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
        shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
        shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
        shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
        shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
        shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
        shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
        shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
        shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
        shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
        shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
        shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
        shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
        shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
        shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
        shifted_readLatch0[0]};
   	$fdisplay(dump_file_desc, "%b", QA_int);
  end
  	end
//    $fclose(filename_dump);
  end
  endtask


  task readWriteA;
  begin
    if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if (RET1N_int === 1'b0 && CENA_int === 1'b0) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{CENA_int, EMAA_int, EMAWA_int, EMASA_int, RET1N_int, (STOVA_int 
     && !CENA_int)} === 1'bx) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if ((AA_int >= WORDS) && (CENA_int === 1'b0)) begin
      QA_int = WENA_int !== 1'b1 ? QA_int : {80{1'bx}};
      QA_int_delayed = WENA_int !== 1'b1 ? QA_int_delayed : {80{1'bx}};
    end else if (CENA_int === 1'b0 && (^AA_int) === 1'bx) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if (CENA_int === 1'b0) begin
      mux_address = (AA_int & 2'b11);
      row_address = (AA_int >> 2);
      if (row_address > 511)
        row = {320{1'bx}};
      else
        row = mem[row_address];
      writeEnable = ~{80{WENA_int}};
      if (WENA_int !== 1'b1) begin
        row_mask =  ( {3'b000, writeEnable[79], 3'b000, writeEnable[78], 3'b000, writeEnable[77],
          3'b000, writeEnable[76], 3'b000, writeEnable[75], 3'b000, writeEnable[74],
          3'b000, writeEnable[73], 3'b000, writeEnable[72], 3'b000, writeEnable[71],
          3'b000, writeEnable[70], 3'b000, writeEnable[69], 3'b000, writeEnable[68],
          3'b000, writeEnable[67], 3'b000, writeEnable[66], 3'b000, writeEnable[65],
          3'b000, writeEnable[64], 3'b000, writeEnable[63], 3'b000, writeEnable[62],
          3'b000, writeEnable[61], 3'b000, writeEnable[60], 3'b000, writeEnable[59],
          3'b000, writeEnable[58], 3'b000, writeEnable[57], 3'b000, writeEnable[56],
          3'b000, writeEnable[55], 3'b000, writeEnable[54], 3'b000, writeEnable[53],
          3'b000, writeEnable[52], 3'b000, writeEnable[51], 3'b000, writeEnable[50],
          3'b000, writeEnable[49], 3'b000, writeEnable[48], 3'b000, writeEnable[47],
          3'b000, writeEnable[46], 3'b000, writeEnable[45], 3'b000, writeEnable[44],
          3'b000, writeEnable[43], 3'b000, writeEnable[42], 3'b000, writeEnable[41],
          3'b000, writeEnable[40], 3'b000, writeEnable[39], 3'b000, writeEnable[38],
          3'b000, writeEnable[37], 3'b000, writeEnable[36], 3'b000, writeEnable[35],
          3'b000, writeEnable[34], 3'b000, writeEnable[33], 3'b000, writeEnable[32],
          3'b000, writeEnable[31], 3'b000, writeEnable[30], 3'b000, writeEnable[29],
          3'b000, writeEnable[28], 3'b000, writeEnable[27], 3'b000, writeEnable[26],
          3'b000, writeEnable[25], 3'b000, writeEnable[24], 3'b000, writeEnable[23],
          3'b000, writeEnable[22], 3'b000, writeEnable[21], 3'b000, writeEnable[20],
          3'b000, writeEnable[19], 3'b000, writeEnable[18], 3'b000, writeEnable[17],
          3'b000, writeEnable[16], 3'b000, writeEnable[15], 3'b000, writeEnable[14],
          3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DA_int[79], 3'b000, DA_int[78], 3'b000, DA_int[77],
          3'b000, DA_int[76], 3'b000, DA_int[75], 3'b000, DA_int[74], 3'b000, DA_int[73],
          3'b000, DA_int[72], 3'b000, DA_int[71], 3'b000, DA_int[70], 3'b000, DA_int[69],
          3'b000, DA_int[68], 3'b000, DA_int[67], 3'b000, DA_int[66], 3'b000, DA_int[65],
          3'b000, DA_int[64], 3'b000, DA_int[63], 3'b000, DA_int[62], 3'b000, DA_int[61],
          3'b000, DA_int[60], 3'b000, DA_int[59], 3'b000, DA_int[58], 3'b000, DA_int[57],
          3'b000, DA_int[56], 3'b000, DA_int[55], 3'b000, DA_int[54], 3'b000, DA_int[53],
          3'b000, DA_int[52], 3'b000, DA_int[51], 3'b000, DA_int[50], 3'b000, DA_int[49],
          3'b000, DA_int[48], 3'b000, DA_int[47], 3'b000, DA_int[46], 3'b000, DA_int[45],
          3'b000, DA_int[44], 3'b000, DA_int[43], 3'b000, DA_int[42], 3'b000, DA_int[41],
          3'b000, DA_int[40], 3'b000, DA_int[39], 3'b000, DA_int[38], 3'b000, DA_int[37],
          3'b000, DA_int[36], 3'b000, DA_int[35], 3'b000, DA_int[34], 3'b000, DA_int[33],
          3'b000, DA_int[32], 3'b000, DA_int[31], 3'b000, DA_int[30], 3'b000, DA_int[29],
          3'b000, DA_int[28], 3'b000, DA_int[27], 3'b000, DA_int[26], 3'b000, DA_int[25],
          3'b000, DA_int[24], 3'b000, DA_int[23], 3'b000, DA_int[22], 3'b000, DA_int[21],
          3'b000, DA_int[20], 3'b000, DA_int[19], 3'b000, DA_int[18], 3'b000, DA_int[17],
          3'b000, DA_int[16], 3'b000, DA_int[15], 3'b000, DA_int[14], 3'b000, DA_int[13],
          3'b000, DA_int[12], 3'b000, DA_int[11], 3'b000, DA_int[10], 3'b000, DA_int[9],
          3'b000, DA_int[8], 3'b000, DA_int[7], 3'b000, DA_int[6], 3'b000, DA_int[5],
          3'b000, DA_int[4], 3'b000, DA_int[3], 3'b000, DA_int[2], 3'b000, DA_int[1],
          3'b000, DA_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[316], data_out[312], data_out[308], data_out[304], data_out[300],
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
      QA_int = {shifted_readLatch0[79], shifted_readLatch0[78], shifted_readLatch0[77],
        shifted_readLatch0[76], shifted_readLatch0[75], shifted_readLatch0[74], shifted_readLatch0[73],
        shifted_readLatch0[72], shifted_readLatch0[71], shifted_readLatch0[70], shifted_readLatch0[69],
        shifted_readLatch0[68], shifted_readLatch0[67], shifted_readLatch0[66], shifted_readLatch0[65],
        shifted_readLatch0[64], shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
        shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
        shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
        shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
        shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
        shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
        shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
        shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
        shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
        shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
        shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
        shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
        shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
        shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
        shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
        shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
        shifted_readLatch0[0]};
      end
    end
  end
  endtask
  always @ (CENA_ or TCENA_ or TENA_ or CLKA_) begin
  	if(CLKA_ == 1'b0) begin
  		CENA_p2 = CENA_;
  		TCENA_p2 = TCENA_;
  	end
  end

  always @ RET1N_ begin
    if (CLKA_ == 1'b1) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CENA_p2 === 1'b0 || TCENA_p2 === 1'b0) ) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CENA_p2 === 1'b0 || TCENA_p2 === 1'b0) ) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end
    if (RET1N_ == 1'b0) begin
      QA_int = {80{1'bx}};
      QA_int_delayed = {80{1'bx}};
      CENA_int = 1'bx;
      WENA_int = 1'bx;
      AA_int = {11{1'bx}};
      DA_int = {80{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      BENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = 1'bx;
      TAA_int = {11{1'bx}};
      TDA_int = {80{1'bx}};
      TQA_int = {80{1'bx}};
      RET1N_int = 1'bx;
      STOVA_int = 1'bx;
      COLLDISN_int = 1'bx;
    end else begin
      QA_int = {80{1'bx}};
      QA_int_delayed = {80{1'bx}};
      CENA_int = 1'bx;
      WENA_int = 1'bx;
      AA_int = {11{1'bx}};
      DA_int = {80{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      BENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = 1'bx;
      TAA_int = {11{1'bx}};
      TDA_int = {80{1'bx}};
      TQA_int = {80{1'bx}};
      RET1N_int = 1'bx;
      STOVA_int = 1'bx;
      COLLDISN_int = 1'bx;
    end
    RET1N_int = RET1N_;
  end


  always @ CLKA_ begin
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
    if ((CLKA_ === 1'bx || CLKA_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if (CLKA_ === 1'b1 && LAST_CLKA === 1'b0) begin
      CENA_int = TENA_ ? CENA_ : TCENA_;
      EMAA_int = EMAA_;
      EMAWA_int = EMAWA_;
      EMASA_int = EMASA_;
      TENA_int = TENA_;
      BENA_int = BENA_;
      TWENA_int = TWENA_;
      TQA_int = TQA_;
      RET1N_int = RET1N_;
      STOVA_int = STOVA_;
      COLLDISN_int = COLLDISN_;
      if (CENA_int != 1'b1) begin
        WENA_int = TENA_ ? WENA_ : TWENA_;
        AA_int = TENA_ ? AA_ : TAA_;
        DA_int = TENA_ ? DA_ : TDA_;
        TCENA_int = TCENA_;
        TAA_int = TAA_;
        TDA_int = TDA_;
      end
      clk0_int = 1'b0;
      if (CENA_int === 1'b0 && WENA_int === 1'b1) 
         QA_int_delayed = {80{1'bx}};
      if (CENA_int === 1'b0) previous_CLKA = $realtime;
    readWriteA;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && COLLDISN_int === 1'b1 && row_contention(AA_int, AB_int,  WENA_int, WENB_int)) 
       begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          DA_int = {80{1'bx}};
          readWriteA;
          DB_int = {80{1'bx}};
          readWriteB;
	      end
        end else if (WENA_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QB_int = {80{1'bx}};
		end
        end else if (WENB_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QA_int = {80{1'bx}};
		end
        end else begin
          readWriteB;
          readWriteA;
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_READ = 1;
        end
		if (!is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          readWriteB;
          readWriteA;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE = 1;
        end else if (!(WENA_int !== 1'b1) && (WENB_int !== 1'b1)) begin
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else if ((WENA_int !== 1'b1) && !(WENB_int !== 1'b1)) begin
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else begin
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
        end
        end
      end else if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && (COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx)  && row_contention(AA_int,
        AB_int,  WENA_int, WENB_int)) begin
          $display("%s row contention: in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (WENB_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DB_int = {80{1'bx}};
          readWriteB;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
          QB_int = {80{1'bx}};
        end else begin
          readWriteB;
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE_1 = 1;
          READ_READ_1 = 1;
        end
        if (WENA_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DA_int = {80{1'bx}};
          readWriteA;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          QA_int = {80{1'bx}};
        end else begin
          readWriteA;
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (CLKA_ === 1'b0 && LAST_CLKA === 1'b1) begin
      QA_int_delayed = QA_int;
    end
    LAST_CLKA = CLKA_;
  end
  end

  task readWriteB;
  begin
    if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if (RET1N_int === 1'b0 && CENB_int === 1'b0) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{CENB_int, EMAB_int, EMAWB_int, EMASB_int, RET1N_int, (STOVB_int 
     && !CENB_int)} === 1'bx) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if ((AB_int >= WORDS) && (CENB_int === 1'b0)) begin
      QB_int = WENB_int !== 1'b1 ? QB_int : {80{1'bx}};
      QB_int_delayed = WENB_int !== 1'b1 ? QB_int_delayed : {80{1'bx}};
    end else if (CENB_int === 1'b0 && (^AB_int) === 1'bx) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if (CENB_int === 1'b0) begin
      mux_address = (AB_int & 2'b11);
      row_address = (AB_int >> 2);
      if (row_address > 511)
        row = {320{1'bx}};
      else
        row = mem[row_address];
      writeEnable = ~{80{WENB_int}};
      if (WENB_int !== 1'b1) begin
        row_mask =  ( {3'b000, writeEnable[79], 3'b000, writeEnable[78], 3'b000, writeEnable[77],
          3'b000, writeEnable[76], 3'b000, writeEnable[75], 3'b000, writeEnable[74],
          3'b000, writeEnable[73], 3'b000, writeEnable[72], 3'b000, writeEnable[71],
          3'b000, writeEnable[70], 3'b000, writeEnable[69], 3'b000, writeEnable[68],
          3'b000, writeEnable[67], 3'b000, writeEnable[66], 3'b000, writeEnable[65],
          3'b000, writeEnable[64], 3'b000, writeEnable[63], 3'b000, writeEnable[62],
          3'b000, writeEnable[61], 3'b000, writeEnable[60], 3'b000, writeEnable[59],
          3'b000, writeEnable[58], 3'b000, writeEnable[57], 3'b000, writeEnable[56],
          3'b000, writeEnable[55], 3'b000, writeEnable[54], 3'b000, writeEnable[53],
          3'b000, writeEnable[52], 3'b000, writeEnable[51], 3'b000, writeEnable[50],
          3'b000, writeEnable[49], 3'b000, writeEnable[48], 3'b000, writeEnable[47],
          3'b000, writeEnable[46], 3'b000, writeEnable[45], 3'b000, writeEnable[44],
          3'b000, writeEnable[43], 3'b000, writeEnable[42], 3'b000, writeEnable[41],
          3'b000, writeEnable[40], 3'b000, writeEnable[39], 3'b000, writeEnable[38],
          3'b000, writeEnable[37], 3'b000, writeEnable[36], 3'b000, writeEnable[35],
          3'b000, writeEnable[34], 3'b000, writeEnable[33], 3'b000, writeEnable[32],
          3'b000, writeEnable[31], 3'b000, writeEnable[30], 3'b000, writeEnable[29],
          3'b000, writeEnable[28], 3'b000, writeEnable[27], 3'b000, writeEnable[26],
          3'b000, writeEnable[25], 3'b000, writeEnable[24], 3'b000, writeEnable[23],
          3'b000, writeEnable[22], 3'b000, writeEnable[21], 3'b000, writeEnable[20],
          3'b000, writeEnable[19], 3'b000, writeEnable[18], 3'b000, writeEnable[17],
          3'b000, writeEnable[16], 3'b000, writeEnable[15], 3'b000, writeEnable[14],
          3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DB_int[79], 3'b000, DB_int[78], 3'b000, DB_int[77],
          3'b000, DB_int[76], 3'b000, DB_int[75], 3'b000, DB_int[74], 3'b000, DB_int[73],
          3'b000, DB_int[72], 3'b000, DB_int[71], 3'b000, DB_int[70], 3'b000, DB_int[69],
          3'b000, DB_int[68], 3'b000, DB_int[67], 3'b000, DB_int[66], 3'b000, DB_int[65],
          3'b000, DB_int[64], 3'b000, DB_int[63], 3'b000, DB_int[62], 3'b000, DB_int[61],
          3'b000, DB_int[60], 3'b000, DB_int[59], 3'b000, DB_int[58], 3'b000, DB_int[57],
          3'b000, DB_int[56], 3'b000, DB_int[55], 3'b000, DB_int[54], 3'b000, DB_int[53],
          3'b000, DB_int[52], 3'b000, DB_int[51], 3'b000, DB_int[50], 3'b000, DB_int[49],
          3'b000, DB_int[48], 3'b000, DB_int[47], 3'b000, DB_int[46], 3'b000, DB_int[45],
          3'b000, DB_int[44], 3'b000, DB_int[43], 3'b000, DB_int[42], 3'b000, DB_int[41],
          3'b000, DB_int[40], 3'b000, DB_int[39], 3'b000, DB_int[38], 3'b000, DB_int[37],
          3'b000, DB_int[36], 3'b000, DB_int[35], 3'b000, DB_int[34], 3'b000, DB_int[33],
          3'b000, DB_int[32], 3'b000, DB_int[31], 3'b000, DB_int[30], 3'b000, DB_int[29],
          3'b000, DB_int[28], 3'b000, DB_int[27], 3'b000, DB_int[26], 3'b000, DB_int[25],
          3'b000, DB_int[24], 3'b000, DB_int[23], 3'b000, DB_int[22], 3'b000, DB_int[21],
          3'b000, DB_int[20], 3'b000, DB_int[19], 3'b000, DB_int[18], 3'b000, DB_int[17],
          3'b000, DB_int[16], 3'b000, DB_int[15], 3'b000, DB_int[14], 3'b000, DB_int[13],
          3'b000, DB_int[12], 3'b000, DB_int[11], 3'b000, DB_int[10], 3'b000, DB_int[9],
          3'b000, DB_int[8], 3'b000, DB_int[7], 3'b000, DB_int[6], 3'b000, DB_int[5],
          3'b000, DB_int[4], 3'b000, DB_int[3], 3'b000, DB_int[2], 3'b000, DB_int[1],
          3'b000, DB_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch1 = {data_out[316], data_out[312], data_out[308], data_out[304], data_out[300],
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
      shifted_readLatch1 = readLatch1;
      QB_int = {shifted_readLatch1[79], shifted_readLatch1[78], shifted_readLatch1[77],
        shifted_readLatch1[76], shifted_readLatch1[75], shifted_readLatch1[74], shifted_readLatch1[73],
        shifted_readLatch1[72], shifted_readLatch1[71], shifted_readLatch1[70], shifted_readLatch1[69],
        shifted_readLatch1[68], shifted_readLatch1[67], shifted_readLatch1[66], shifted_readLatch1[65],
        shifted_readLatch1[64], shifted_readLatch1[63], shifted_readLatch1[62], shifted_readLatch1[61],
        shifted_readLatch1[60], shifted_readLatch1[59], shifted_readLatch1[58], shifted_readLatch1[57],
        shifted_readLatch1[56], shifted_readLatch1[55], shifted_readLatch1[54], shifted_readLatch1[53],
        shifted_readLatch1[52], shifted_readLatch1[51], shifted_readLatch1[50], shifted_readLatch1[49],
        shifted_readLatch1[48], shifted_readLatch1[47], shifted_readLatch1[46], shifted_readLatch1[45],
        shifted_readLatch1[44], shifted_readLatch1[43], shifted_readLatch1[42], shifted_readLatch1[41],
        shifted_readLatch1[40], shifted_readLatch1[39], shifted_readLatch1[38], shifted_readLatch1[37],
        shifted_readLatch1[36], shifted_readLatch1[35], shifted_readLatch1[34], shifted_readLatch1[33],
        shifted_readLatch1[32], shifted_readLatch1[31], shifted_readLatch1[30], shifted_readLatch1[29],
        shifted_readLatch1[28], shifted_readLatch1[27], shifted_readLatch1[26], shifted_readLatch1[25],
        shifted_readLatch1[24], shifted_readLatch1[23], shifted_readLatch1[22], shifted_readLatch1[21],
        shifted_readLatch1[20], shifted_readLatch1[19], shifted_readLatch1[18], shifted_readLatch1[17],
        shifted_readLatch1[16], shifted_readLatch1[15], shifted_readLatch1[14], shifted_readLatch1[13],
        shifted_readLatch1[12], shifted_readLatch1[11], shifted_readLatch1[10], shifted_readLatch1[9],
        shifted_readLatch1[8], shifted_readLatch1[7], shifted_readLatch1[6], shifted_readLatch1[5],
        shifted_readLatch1[4], shifted_readLatch1[3], shifted_readLatch1[2], shifted_readLatch1[1],
        shifted_readLatch1[0]};
      end
    end
  end
  endtask
  always @ (CENB_ or TCENB_ or TENB_ or CLKB_) begin
  	if(CLKB_ == 1'b0) begin
  		CENB_p2 = CENB_;
  		TCENB_p2 = TCENB_;
  	end
  end

  always @ RET1N_ begin
    if (CLKB_ == 1'b1) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CENB_p2 === 1'b0 || TCENB_p2 === 1'b0) ) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CENB_p2 === 1'b0 || TCENB_p2 === 1'b0) ) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end
    if (RET1N_ == 1'b0) begin
      QB_int = {80{1'bx}};
      QB_int_delayed = {80{1'bx}};
      CENB_int = 1'bx;
      WENB_int = 1'bx;
      AB_int = {11{1'bx}};
      DB_int = {80{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      BENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = 1'bx;
      TAB_int = {11{1'bx}};
      TDB_int = {80{1'bx}};
      TQB_int = {80{1'bx}};
      RET1N_int = 1'bx;
      STOVB_int = 1'bx;
      COLLDISN_int = 1'bx;
    end else begin
      QB_int = {80{1'bx}};
      QB_int_delayed = {80{1'bx}};
      CENB_int = 1'bx;
      WENB_int = 1'bx;
      AB_int = {11{1'bx}};
      DB_int = {80{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      BENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = 1'bx;
      TAB_int = {11{1'bx}};
      TDB_int = {80{1'bx}};
      TQB_int = {80{1'bx}};
      RET1N_int = 1'bx;
      STOVB_int = 1'bx;
      COLLDISN_int = 1'bx;
    end
    RET1N_int = RET1N_;
  end


  always @ CLKB_ begin
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
    if ((CLKB_ === 1'bx || CLKB_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if (CLKB_ === 1'b1 && LAST_CLKB === 1'b0) begin
      CENB_int = TENB_ ? CENB_ : TCENB_;
      EMAB_int = EMAB_;
      EMAWB_int = EMAWB_;
      EMASB_int = EMASB_;
      TENB_int = TENB_;
      BENB_int = BENB_;
      TWENB_int = TWENB_;
      TQB_int = TQB_;
      RET1N_int = RET1N_;
      STOVB_int = STOVB_;
      COLLDISN_int = COLLDISN_;
      if (CENB_int != 1'b1) begin
        WENB_int = TENB_ ? WENB_ : TWENB_;
        AB_int = TENB_ ? AB_ : TAB_;
        DB_int = TENB_ ? DB_ : TDB_;
        TCENB_int = TCENB_;
        TAB_int = TAB_;
        TDB_int = TDB_;
      end
      clk1_int = 1'b0;
      if (CENB_int === 1'b0 && WENB_int === 1'b1) 
         QB_int_delayed = {80{1'bx}};
      if (CENB_int === 1'b0) previous_CLKB = $realtime;
    readWriteB;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && COLLDISN_int === 1'b1 && row_contention(AA_int, AB_int,  WENA_int, WENB_int)) 
       begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          DA_int = {80{1'bx}};
          readWriteA;
          DB_int = {80{1'bx}};
          readWriteB;
	      end
        end else if (WENA_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QB_int = {80{1'bx}};
		end
        end else if (WENB_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QA_int = {80{1'bx}};
		end
        end else begin
          readWriteA;
          readWriteB;
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_READ = 1;
        end
		if (!is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          readWriteA;
          readWriteB;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE = 1;
        end else if (!(WENA_int !== 1'b1) && (WENB_int !== 1'b1)) begin
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else if ((WENA_int !== 1'b1) && !(WENB_int !== 1'b1)) begin
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else begin
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
        end
        end
      end else if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && (COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx)  && row_contention(AA_int,
        AB_int,  WENA_int, WENB_int)) begin
          $display("%s row contention: in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (WENA_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DA_int = {80{1'bx}};
          readWriteA;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
          QA_int = {80{1'bx}};
        end else begin
          readWriteA;
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_READ_1 = 1;
          READ_WRITE_1 = 1;
        end
        if (WENB_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DB_int = {80{1'bx}};
          readWriteB;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          QB_int = {80{1'bx}};
        end else begin
          readWriteB;
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (CLKB_ === 1'b0 && LAST_CLKB === 1'b1) begin
      QB_int_delayed = QB_int;
    end
    LAST_CLKB = CLKB_;
  end
  end

  function row_contention;
    input [10:0] aa;
    input [10:0] ab;
    input  wena;
    input  wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) === 1'b1 && (& wenb) === 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[1:0] == ab[1:0]) ? 1'b1 : 1'b0;
    if (aa[10:2] == ab[10:2]) begin
      sameRow = 1'b1;
    end else begin
      sameRow = 1'b0;
    end
    if (sameRow == 1'b1 && anyWrite == 1'b1)
      row_contention = 1'b1;
    else if (sameRow == 1'b1 && sameMux == 1'b1)
      row_contention = 1'b1;
    else
      row_contention = 1'b0;
  end
  endfunction

  function col_contention;
    input [10:0] aa;
    input [10:0] ab;
  begin
    if (aa[1:0] == ab[1:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [10:0] aa;
    input [10:0] ab;
    input  wena;
    input  wenb;
    reg result;
  begin
    if ((& wena) === 1'b1 && (& wenb) === 1'b1) begin
      result = 1'b0;
    end else if (aa == ab) begin
      result = 1'b1;
    end else begin
      result = 1'b0;
    end
    is_contention = result;
  end
  endfunction


endmodule
`endcelldefine
`else
`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module sram_dp_hde (VDDCE, VDDPE, VSSE, CENYA, WENYA, AYA, DYA, CENYB, WENYB, AYB,
    DYB, QA, QB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA, EMASA,
    EMAB, EMAWB, EMASB, TENA, BENA, TCENA, TWENA, TAA, TDA, TQA, TENB, BENB, TCENB,
    TWENB, TAB, TDB, TQB, RET1N, STOVA, STOVB, COLLDISN);
`else
module sram_dp_hde (CENYA, WENYA, AYA, DYA, CENYB, WENYB, AYB, DYB, QA, QB, CLKA, CENA,
    WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA, EMASA, EMAB, EMAWB, EMASB,
    TENA, BENA, TCENA, TWENA, TAA, TDA, TQA, TENB, BENB, TCENB, TWENB, TAB, TDB, TQB,
    RET1N, STOVA, STOVB, COLLDISN);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 80;
  parameter WORDS = 2048;
  parameter MUX = 4;
  parameter MEM_WIDTH = 320; // redun block size 4, 160 on left, 160 on right
  parameter MEM_HEIGHT = 512;
  parameter WP_SIZE = 80 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENYA;
  output  WENYA;
  output [10:0] AYA;
  output [79:0] DYA;
  output  CENYB;
  output  WENYB;
  output [10:0] AYB;
  output [79:0] DYB;
  output [79:0] QA;
  output [79:0] QB;
  input  CLKA;
  input  CENA;
  input  WENA;
  input [10:0] AA;
  input [79:0] DA;
  input  CLKB;
  input  CENB;
  input  WENB;
  input [10:0] AB;
  input [79:0] DB;
  input [2:0] EMAA;
  input [1:0] EMAWA;
  input  EMASA;
  input [2:0] EMAB;
  input [1:0] EMAWB;
  input  EMASB;
  input  TENA;
  input  BENA;
  input  TCENA;
  input  TWENA;
  input [10:0] TAA;
  input [79:0] TDA;
  input [79:0] TQA;
  input  TENB;
  input  BENB;
  input  TCENB;
  input  TWENB;
  input [10:0] TAB;
  input [79:0] TDB;
  input [79:0] TQB;
  input  RET1N;
  input  STOVA;
  input  STOVB;
  input  COLLDISN;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

  integer row_address;
  integer mux_address;
  reg [319:0] mem [0:511];
  reg [319:0] row;
  reg LAST_CLKA;
  reg [319:0] row_mask;
  reg [319:0] new_data;
  reg [319:0] data_out;
  reg [79:0] readLatch0;
  reg [79:0] shifted_readLatch0;
  reg [79:0] readLatch1;
  reg [79:0] shifted_readLatch1;
  reg LAST_CLKB;
  reg [79:0] QA_int;
  reg [79:0] QA_int_delayed;
  reg [79:0] QB_int;
  reg [79:0] QB_int_delayed;
  reg [79:0] writeEnable;
  real previous_CLKA;
  real previous_CLKB;
  initial previous_CLKA = 0;
  initial previous_CLKB = 0;
  reg READ_WRITE, WRITE_WRITE, READ_READ, ROW_CC, COL_CC;
  reg READ_WRITE_1, WRITE_WRITE_1, READ_READ_1;
  reg  cont_flag0_int;
  reg  cont_flag1_int;
  initial cont_flag0_int = 1'b0;
  initial cont_flag1_int = 1'b0;

  reg NOT_CENA, NOT_WENA, NOT_AA10, NOT_AA9, NOT_AA8, NOT_AA7, NOT_AA6, NOT_AA5, NOT_AA4;
  reg NOT_AA3, NOT_AA2, NOT_AA1, NOT_AA0, NOT_DA79, NOT_DA78, NOT_DA77, NOT_DA76, NOT_DA75;
  reg NOT_DA74, NOT_DA73, NOT_DA72, NOT_DA71, NOT_DA70, NOT_DA69, NOT_DA68, NOT_DA67;
  reg NOT_DA66, NOT_DA65, NOT_DA64, NOT_DA63, NOT_DA62, NOT_DA61, NOT_DA60, NOT_DA59;
  reg NOT_DA58, NOT_DA57, NOT_DA56, NOT_DA55, NOT_DA54, NOT_DA53, NOT_DA52, NOT_DA51;
  reg NOT_DA50, NOT_DA49, NOT_DA48, NOT_DA47, NOT_DA46, NOT_DA45, NOT_DA44, NOT_DA43;
  reg NOT_DA42, NOT_DA41, NOT_DA40, NOT_DA39, NOT_DA38, NOT_DA37, NOT_DA36, NOT_DA35;
  reg NOT_DA34, NOT_DA33, NOT_DA32, NOT_DA31, NOT_DA30, NOT_DA29, NOT_DA28, NOT_DA27;
  reg NOT_DA26, NOT_DA25, NOT_DA24, NOT_DA23, NOT_DA22, NOT_DA21, NOT_DA20, NOT_DA19;
  reg NOT_DA18, NOT_DA17, NOT_DA16, NOT_DA15, NOT_DA14, NOT_DA13, NOT_DA12, NOT_DA11;
  reg NOT_DA10, NOT_DA9, NOT_DA8, NOT_DA7, NOT_DA6, NOT_DA5, NOT_DA4, NOT_DA3, NOT_DA2;
  reg NOT_DA1, NOT_DA0, NOT_CENB, NOT_WENB, NOT_AB10, NOT_AB9, NOT_AB8, NOT_AB7, NOT_AB6;
  reg NOT_AB5, NOT_AB4, NOT_AB3, NOT_AB2, NOT_AB1, NOT_AB0, NOT_DB79, NOT_DB78, NOT_DB77;
  reg NOT_DB76, NOT_DB75, NOT_DB74, NOT_DB73, NOT_DB72, NOT_DB71, NOT_DB70, NOT_DB69;
  reg NOT_DB68, NOT_DB67, NOT_DB66, NOT_DB65, NOT_DB64, NOT_DB63, NOT_DB62, NOT_DB61;
  reg NOT_DB60, NOT_DB59, NOT_DB58, NOT_DB57, NOT_DB56, NOT_DB55, NOT_DB54, NOT_DB53;
  reg NOT_DB52, NOT_DB51, NOT_DB50, NOT_DB49, NOT_DB48, NOT_DB47, NOT_DB46, NOT_DB45;
  reg NOT_DB44, NOT_DB43, NOT_DB42, NOT_DB41, NOT_DB40, NOT_DB39, NOT_DB38, NOT_DB37;
  reg NOT_DB36, NOT_DB35, NOT_DB34, NOT_DB33, NOT_DB32, NOT_DB31, NOT_DB30, NOT_DB29;
  reg NOT_DB28, NOT_DB27, NOT_DB26, NOT_DB25, NOT_DB24, NOT_DB23, NOT_DB22, NOT_DB21;
  reg NOT_DB20, NOT_DB19, NOT_DB18, NOT_DB17, NOT_DB16, NOT_DB15, NOT_DB14, NOT_DB13;
  reg NOT_DB12, NOT_DB11, NOT_DB10, NOT_DB9, NOT_DB8, NOT_DB7, NOT_DB6, NOT_DB5, NOT_DB4;
  reg NOT_DB3, NOT_DB2, NOT_DB1, NOT_DB0, NOT_EMAA2, NOT_EMAA1, NOT_EMAA0, NOT_EMAWA1;
  reg NOT_EMAWA0, NOT_EMASA, NOT_EMAB2, NOT_EMAB1, NOT_EMAB0, NOT_EMAWB1, NOT_EMAWB0;
  reg NOT_EMASB, NOT_TENA, NOT_TCENA, NOT_TWENA, NOT_TAA10, NOT_TAA9, NOT_TAA8, NOT_TAA7;
  reg NOT_TAA6, NOT_TAA5, NOT_TAA4, NOT_TAA3, NOT_TAA2, NOT_TAA1, NOT_TAA0, NOT_TDA79;
  reg NOT_TDA78, NOT_TDA77, NOT_TDA76, NOT_TDA75, NOT_TDA74, NOT_TDA73, NOT_TDA72;
  reg NOT_TDA71, NOT_TDA70, NOT_TDA69, NOT_TDA68, NOT_TDA67, NOT_TDA66, NOT_TDA65;
  reg NOT_TDA64, NOT_TDA63, NOT_TDA62, NOT_TDA61, NOT_TDA60, NOT_TDA59, NOT_TDA58;
  reg NOT_TDA57, NOT_TDA56, NOT_TDA55, NOT_TDA54, NOT_TDA53, NOT_TDA52, NOT_TDA51;
  reg NOT_TDA50, NOT_TDA49, NOT_TDA48, NOT_TDA47, NOT_TDA46, NOT_TDA45, NOT_TDA44;
  reg NOT_TDA43, NOT_TDA42, NOT_TDA41, NOT_TDA40, NOT_TDA39, NOT_TDA38, NOT_TDA37;
  reg NOT_TDA36, NOT_TDA35, NOT_TDA34, NOT_TDA33, NOT_TDA32, NOT_TDA31, NOT_TDA30;
  reg NOT_TDA29, NOT_TDA28, NOT_TDA27, NOT_TDA26, NOT_TDA25, NOT_TDA24, NOT_TDA23;
  reg NOT_TDA22, NOT_TDA21, NOT_TDA20, NOT_TDA19, NOT_TDA18, NOT_TDA17, NOT_TDA16;
  reg NOT_TDA15, NOT_TDA14, NOT_TDA13, NOT_TDA12, NOT_TDA11, NOT_TDA10, NOT_TDA9, NOT_TDA8;
  reg NOT_TDA7, NOT_TDA6, NOT_TDA5, NOT_TDA4, NOT_TDA3, NOT_TDA2, NOT_TDA1, NOT_TDA0;
  reg NOT_TENB, NOT_TCENB, NOT_TWENB, NOT_TAB10, NOT_TAB9, NOT_TAB8, NOT_TAB7, NOT_TAB6;
  reg NOT_TAB5, NOT_TAB4, NOT_TAB3, NOT_TAB2, NOT_TAB1, NOT_TAB0, NOT_TDB79, NOT_TDB78;
  reg NOT_TDB77, NOT_TDB76, NOT_TDB75, NOT_TDB74, NOT_TDB73, NOT_TDB72, NOT_TDB71;
  reg NOT_TDB70, NOT_TDB69, NOT_TDB68, NOT_TDB67, NOT_TDB66, NOT_TDB65, NOT_TDB64;
  reg NOT_TDB63, NOT_TDB62, NOT_TDB61, NOT_TDB60, NOT_TDB59, NOT_TDB58, NOT_TDB57;
  reg NOT_TDB56, NOT_TDB55, NOT_TDB54, NOT_TDB53, NOT_TDB52, NOT_TDB51, NOT_TDB50;
  reg NOT_TDB49, NOT_TDB48, NOT_TDB47, NOT_TDB46, NOT_TDB45, NOT_TDB44, NOT_TDB43;
  reg NOT_TDB42, NOT_TDB41, NOT_TDB40, NOT_TDB39, NOT_TDB38, NOT_TDB37, NOT_TDB36;
  reg NOT_TDB35, NOT_TDB34, NOT_TDB33, NOT_TDB32, NOT_TDB31, NOT_TDB30, NOT_TDB29;
  reg NOT_TDB28, NOT_TDB27, NOT_TDB26, NOT_TDB25, NOT_TDB24, NOT_TDB23, NOT_TDB22;
  reg NOT_TDB21, NOT_TDB20, NOT_TDB19, NOT_TDB18, NOT_TDB17, NOT_TDB16, NOT_TDB15;
  reg NOT_TDB14, NOT_TDB13, NOT_TDB12, NOT_TDB11, NOT_TDB10, NOT_TDB9, NOT_TDB8, NOT_TDB7;
  reg NOT_TDB6, NOT_TDB5, NOT_TDB4, NOT_TDB3, NOT_TDB2, NOT_TDB1, NOT_TDB0, NOT_RET1N;
  reg NOT_STOVA, NOT_STOVB, NOT_COLLDISN;
  reg NOT_CONTA, NOT_CLKA_PER, NOT_CLKA_MINH, NOT_CLKA_MINL, NOT_CONTB, NOT_CLKB_PER;
  reg NOT_CLKB_MINH, NOT_CLKB_MINL;
  reg clk0_int;
  reg clk1_int;

  wire  CENYA_;
  wire  WENYA_;
  wire [10:0] AYA_;
  wire [79:0] DYA_;
  wire  CENYB_;
  wire  WENYB_;
  wire [10:0] AYB_;
  wire [79:0] DYB_;
  wire [79:0] QA_;
  wire [79:0] QB_;
 wire  CLKA_;
  wire  CENA_;
  reg  CENA_int;
  reg  CENA_p2;
  wire  WENA_;
  reg  WENA_int;
  wire [10:0] AA_;
  reg [10:0] AA_int;
  wire [79:0] DA_;
  reg [79:0] DA_int;
 wire  CLKB_;
  wire  CENB_;
  reg  CENB_int;
  reg  CENB_p2;
  wire  WENB_;
  reg  WENB_int;
  wire [10:0] AB_;
  reg [10:0] AB_int;
  wire [79:0] DB_;
  reg [79:0] DB_int;
  wire [2:0] EMAA_;
  reg [2:0] EMAA_int;
  wire [1:0] EMAWA_;
  reg [1:0] EMAWA_int;
  wire  EMASA_;
  reg  EMASA_int;
  wire [2:0] EMAB_;
  reg [2:0] EMAB_int;
  wire [1:0] EMAWB_;
  reg [1:0] EMAWB_int;
  wire  EMASB_;
  reg  EMASB_int;
  wire  TENA_;
  reg  TENA_int;
  wire  BENA_;
  reg  BENA_int;
  wire  TCENA_;
  reg  TCENA_int;
  reg  TCENA_p2;
  wire  TWENA_;
  reg  TWENA_int;
  wire [10:0] TAA_;
  reg [10:0] TAA_int;
  wire [79:0] TDA_;
  reg [79:0] TDA_int;
  wire [79:0] TQA_;
  reg [79:0] TQA_int;
  wire  TENB_;
  reg  TENB_int;
  wire  BENB_;
  reg  BENB_int;
  wire  TCENB_;
  reg  TCENB_int;
  reg  TCENB_p2;
  wire  TWENB_;
  reg  TWENB_int;
  wire [10:0] TAB_;
  reg [10:0] TAB_int;
  wire [79:0] TDB_;
  reg [79:0] TDB_int;
  wire [79:0] TQB_;
  reg [79:0] TQB_int;
  wire  RET1N_;
  reg  RET1N_int;
  wire  STOVA_;
  reg  STOVA_int;
  wire  STOVB_;
  reg  STOVB_int;
  wire  COLLDISN_;
  reg  COLLDISN_int;

  buf B0(CENYA, CENYA_);
  buf B1(WENYA, WENYA_);
  buf B2(AYA[0], AYA_[0]);
  buf B3(AYA[1], AYA_[1]);
  buf B4(AYA[2], AYA_[2]);
  buf B5(AYA[3], AYA_[3]);
  buf B6(AYA[4], AYA_[4]);
  buf B7(AYA[5], AYA_[5]);
  buf B8(AYA[6], AYA_[6]);
  buf B9(AYA[7], AYA_[7]);
  buf B10(AYA[8], AYA_[8]);
  buf B11(AYA[9], AYA_[9]);
  buf B12(AYA[10], AYA_[10]);
  buf B13(DYA[0], DYA_[0]);
  buf B14(DYA[1], DYA_[1]);
  buf B15(DYA[2], DYA_[2]);
  buf B16(DYA[3], DYA_[3]);
  buf B17(DYA[4], DYA_[4]);
  buf B18(DYA[5], DYA_[5]);
  buf B19(DYA[6], DYA_[6]);
  buf B20(DYA[7], DYA_[7]);
  buf B21(DYA[8], DYA_[8]);
  buf B22(DYA[9], DYA_[9]);
  buf B23(DYA[10], DYA_[10]);
  buf B24(DYA[11], DYA_[11]);
  buf B25(DYA[12], DYA_[12]);
  buf B26(DYA[13], DYA_[13]);
  buf B27(DYA[14], DYA_[14]);
  buf B28(DYA[15], DYA_[15]);
  buf B29(DYA[16], DYA_[16]);
  buf B30(DYA[17], DYA_[17]);
  buf B31(DYA[18], DYA_[18]);
  buf B32(DYA[19], DYA_[19]);
  buf B33(DYA[20], DYA_[20]);
  buf B34(DYA[21], DYA_[21]);
  buf B35(DYA[22], DYA_[22]);
  buf B36(DYA[23], DYA_[23]);
  buf B37(DYA[24], DYA_[24]);
  buf B38(DYA[25], DYA_[25]);
  buf B39(DYA[26], DYA_[26]);
  buf B40(DYA[27], DYA_[27]);
  buf B41(DYA[28], DYA_[28]);
  buf B42(DYA[29], DYA_[29]);
  buf B43(DYA[30], DYA_[30]);
  buf B44(DYA[31], DYA_[31]);
  buf B45(DYA[32], DYA_[32]);
  buf B46(DYA[33], DYA_[33]);
  buf B47(DYA[34], DYA_[34]);
  buf B48(DYA[35], DYA_[35]);
  buf B49(DYA[36], DYA_[36]);
  buf B50(DYA[37], DYA_[37]);
  buf B51(DYA[38], DYA_[38]);
  buf B52(DYA[39], DYA_[39]);
  buf B53(DYA[40], DYA_[40]);
  buf B54(DYA[41], DYA_[41]);
  buf B55(DYA[42], DYA_[42]);
  buf B56(DYA[43], DYA_[43]);
  buf B57(DYA[44], DYA_[44]);
  buf B58(DYA[45], DYA_[45]);
  buf B59(DYA[46], DYA_[46]);
  buf B60(DYA[47], DYA_[47]);
  buf B61(DYA[48], DYA_[48]);
  buf B62(DYA[49], DYA_[49]);
  buf B63(DYA[50], DYA_[50]);
  buf B64(DYA[51], DYA_[51]);
  buf B65(DYA[52], DYA_[52]);
  buf B66(DYA[53], DYA_[53]);
  buf B67(DYA[54], DYA_[54]);
  buf B68(DYA[55], DYA_[55]);
  buf B69(DYA[56], DYA_[56]);
  buf B70(DYA[57], DYA_[57]);
  buf B71(DYA[58], DYA_[58]);
  buf B72(DYA[59], DYA_[59]);
  buf B73(DYA[60], DYA_[60]);
  buf B74(DYA[61], DYA_[61]);
  buf B75(DYA[62], DYA_[62]);
  buf B76(DYA[63], DYA_[63]);
  buf B77(DYA[64], DYA_[64]);
  buf B78(DYA[65], DYA_[65]);
  buf B79(DYA[66], DYA_[66]);
  buf B80(DYA[67], DYA_[67]);
  buf B81(DYA[68], DYA_[68]);
  buf B82(DYA[69], DYA_[69]);
  buf B83(DYA[70], DYA_[70]);
  buf B84(DYA[71], DYA_[71]);
  buf B85(DYA[72], DYA_[72]);
  buf B86(DYA[73], DYA_[73]);
  buf B87(DYA[74], DYA_[74]);
  buf B88(DYA[75], DYA_[75]);
  buf B89(DYA[76], DYA_[76]);
  buf B90(DYA[77], DYA_[77]);
  buf B91(DYA[78], DYA_[78]);
  buf B92(DYA[79], DYA_[79]);
  buf B93(CENYB, CENYB_);
  buf B94(WENYB, WENYB_);
  buf B95(AYB[0], AYB_[0]);
  buf B96(AYB[1], AYB_[1]);
  buf B97(AYB[2], AYB_[2]);
  buf B98(AYB[3], AYB_[3]);
  buf B99(AYB[4], AYB_[4]);
  buf B100(AYB[5], AYB_[5]);
  buf B101(AYB[6], AYB_[6]);
  buf B102(AYB[7], AYB_[7]);
  buf B103(AYB[8], AYB_[8]);
  buf B104(AYB[9], AYB_[9]);
  buf B105(AYB[10], AYB_[10]);
  buf B106(DYB[0], DYB_[0]);
  buf B107(DYB[1], DYB_[1]);
  buf B108(DYB[2], DYB_[2]);
  buf B109(DYB[3], DYB_[3]);
  buf B110(DYB[4], DYB_[4]);
  buf B111(DYB[5], DYB_[5]);
  buf B112(DYB[6], DYB_[6]);
  buf B113(DYB[7], DYB_[7]);
  buf B114(DYB[8], DYB_[8]);
  buf B115(DYB[9], DYB_[9]);
  buf B116(DYB[10], DYB_[10]);
  buf B117(DYB[11], DYB_[11]);
  buf B118(DYB[12], DYB_[12]);
  buf B119(DYB[13], DYB_[13]);
  buf B120(DYB[14], DYB_[14]);
  buf B121(DYB[15], DYB_[15]);
  buf B122(DYB[16], DYB_[16]);
  buf B123(DYB[17], DYB_[17]);
  buf B124(DYB[18], DYB_[18]);
  buf B125(DYB[19], DYB_[19]);
  buf B126(DYB[20], DYB_[20]);
  buf B127(DYB[21], DYB_[21]);
  buf B128(DYB[22], DYB_[22]);
  buf B129(DYB[23], DYB_[23]);
  buf B130(DYB[24], DYB_[24]);
  buf B131(DYB[25], DYB_[25]);
  buf B132(DYB[26], DYB_[26]);
  buf B133(DYB[27], DYB_[27]);
  buf B134(DYB[28], DYB_[28]);
  buf B135(DYB[29], DYB_[29]);
  buf B136(DYB[30], DYB_[30]);
  buf B137(DYB[31], DYB_[31]);
  buf B138(DYB[32], DYB_[32]);
  buf B139(DYB[33], DYB_[33]);
  buf B140(DYB[34], DYB_[34]);
  buf B141(DYB[35], DYB_[35]);
  buf B142(DYB[36], DYB_[36]);
  buf B143(DYB[37], DYB_[37]);
  buf B144(DYB[38], DYB_[38]);
  buf B145(DYB[39], DYB_[39]);
  buf B146(DYB[40], DYB_[40]);
  buf B147(DYB[41], DYB_[41]);
  buf B148(DYB[42], DYB_[42]);
  buf B149(DYB[43], DYB_[43]);
  buf B150(DYB[44], DYB_[44]);
  buf B151(DYB[45], DYB_[45]);
  buf B152(DYB[46], DYB_[46]);
  buf B153(DYB[47], DYB_[47]);
  buf B154(DYB[48], DYB_[48]);
  buf B155(DYB[49], DYB_[49]);
  buf B156(DYB[50], DYB_[50]);
  buf B157(DYB[51], DYB_[51]);
  buf B158(DYB[52], DYB_[52]);
  buf B159(DYB[53], DYB_[53]);
  buf B160(DYB[54], DYB_[54]);
  buf B161(DYB[55], DYB_[55]);
  buf B162(DYB[56], DYB_[56]);
  buf B163(DYB[57], DYB_[57]);
  buf B164(DYB[58], DYB_[58]);
  buf B165(DYB[59], DYB_[59]);
  buf B166(DYB[60], DYB_[60]);
  buf B167(DYB[61], DYB_[61]);
  buf B168(DYB[62], DYB_[62]);
  buf B169(DYB[63], DYB_[63]);
  buf B170(DYB[64], DYB_[64]);
  buf B171(DYB[65], DYB_[65]);
  buf B172(DYB[66], DYB_[66]);
  buf B173(DYB[67], DYB_[67]);
  buf B174(DYB[68], DYB_[68]);
  buf B175(DYB[69], DYB_[69]);
  buf B176(DYB[70], DYB_[70]);
  buf B177(DYB[71], DYB_[71]);
  buf B178(DYB[72], DYB_[72]);
  buf B179(DYB[73], DYB_[73]);
  buf B180(DYB[74], DYB_[74]);
  buf B181(DYB[75], DYB_[75]);
  buf B182(DYB[76], DYB_[76]);
  buf B183(DYB[77], DYB_[77]);
  buf B184(DYB[78], DYB_[78]);
  buf B185(DYB[79], DYB_[79]);
  buf B186(QA[0], QA_[0]);
  buf B187(QA[1], QA_[1]);
  buf B188(QA[2], QA_[2]);
  buf B189(QA[3], QA_[3]);
  buf B190(QA[4], QA_[4]);
  buf B191(QA[5], QA_[5]);
  buf B192(QA[6], QA_[6]);
  buf B193(QA[7], QA_[7]);
  buf B194(QA[8], QA_[8]);
  buf B195(QA[9], QA_[9]);
  buf B196(QA[10], QA_[10]);
  buf B197(QA[11], QA_[11]);
  buf B198(QA[12], QA_[12]);
  buf B199(QA[13], QA_[13]);
  buf B200(QA[14], QA_[14]);
  buf B201(QA[15], QA_[15]);
  buf B202(QA[16], QA_[16]);
  buf B203(QA[17], QA_[17]);
  buf B204(QA[18], QA_[18]);
  buf B205(QA[19], QA_[19]);
  buf B206(QA[20], QA_[20]);
  buf B207(QA[21], QA_[21]);
  buf B208(QA[22], QA_[22]);
  buf B209(QA[23], QA_[23]);
  buf B210(QA[24], QA_[24]);
  buf B211(QA[25], QA_[25]);
  buf B212(QA[26], QA_[26]);
  buf B213(QA[27], QA_[27]);
  buf B214(QA[28], QA_[28]);
  buf B215(QA[29], QA_[29]);
  buf B216(QA[30], QA_[30]);
  buf B217(QA[31], QA_[31]);
  buf B218(QA[32], QA_[32]);
  buf B219(QA[33], QA_[33]);
  buf B220(QA[34], QA_[34]);
  buf B221(QA[35], QA_[35]);
  buf B222(QA[36], QA_[36]);
  buf B223(QA[37], QA_[37]);
  buf B224(QA[38], QA_[38]);
  buf B225(QA[39], QA_[39]);
  buf B226(QA[40], QA_[40]);
  buf B227(QA[41], QA_[41]);
  buf B228(QA[42], QA_[42]);
  buf B229(QA[43], QA_[43]);
  buf B230(QA[44], QA_[44]);
  buf B231(QA[45], QA_[45]);
  buf B232(QA[46], QA_[46]);
  buf B233(QA[47], QA_[47]);
  buf B234(QA[48], QA_[48]);
  buf B235(QA[49], QA_[49]);
  buf B236(QA[50], QA_[50]);
  buf B237(QA[51], QA_[51]);
  buf B238(QA[52], QA_[52]);
  buf B239(QA[53], QA_[53]);
  buf B240(QA[54], QA_[54]);
  buf B241(QA[55], QA_[55]);
  buf B242(QA[56], QA_[56]);
  buf B243(QA[57], QA_[57]);
  buf B244(QA[58], QA_[58]);
  buf B245(QA[59], QA_[59]);
  buf B246(QA[60], QA_[60]);
  buf B247(QA[61], QA_[61]);
  buf B248(QA[62], QA_[62]);
  buf B249(QA[63], QA_[63]);
  buf B250(QA[64], QA_[64]);
  buf B251(QA[65], QA_[65]);
  buf B252(QA[66], QA_[66]);
  buf B253(QA[67], QA_[67]);
  buf B254(QA[68], QA_[68]);
  buf B255(QA[69], QA_[69]);
  buf B256(QA[70], QA_[70]);
  buf B257(QA[71], QA_[71]);
  buf B258(QA[72], QA_[72]);
  buf B259(QA[73], QA_[73]);
  buf B260(QA[74], QA_[74]);
  buf B261(QA[75], QA_[75]);
  buf B262(QA[76], QA_[76]);
  buf B263(QA[77], QA_[77]);
  buf B264(QA[78], QA_[78]);
  buf B265(QA[79], QA_[79]);
  buf B266(QB[0], QB_[0]);
  buf B267(QB[1], QB_[1]);
  buf B268(QB[2], QB_[2]);
  buf B269(QB[3], QB_[3]);
  buf B270(QB[4], QB_[4]);
  buf B271(QB[5], QB_[5]);
  buf B272(QB[6], QB_[6]);
  buf B273(QB[7], QB_[7]);
  buf B274(QB[8], QB_[8]);
  buf B275(QB[9], QB_[9]);
  buf B276(QB[10], QB_[10]);
  buf B277(QB[11], QB_[11]);
  buf B278(QB[12], QB_[12]);
  buf B279(QB[13], QB_[13]);
  buf B280(QB[14], QB_[14]);
  buf B281(QB[15], QB_[15]);
  buf B282(QB[16], QB_[16]);
  buf B283(QB[17], QB_[17]);
  buf B284(QB[18], QB_[18]);
  buf B285(QB[19], QB_[19]);
  buf B286(QB[20], QB_[20]);
  buf B287(QB[21], QB_[21]);
  buf B288(QB[22], QB_[22]);
  buf B289(QB[23], QB_[23]);
  buf B290(QB[24], QB_[24]);
  buf B291(QB[25], QB_[25]);
  buf B292(QB[26], QB_[26]);
  buf B293(QB[27], QB_[27]);
  buf B294(QB[28], QB_[28]);
  buf B295(QB[29], QB_[29]);
  buf B296(QB[30], QB_[30]);
  buf B297(QB[31], QB_[31]);
  buf B298(QB[32], QB_[32]);
  buf B299(QB[33], QB_[33]);
  buf B300(QB[34], QB_[34]);
  buf B301(QB[35], QB_[35]);
  buf B302(QB[36], QB_[36]);
  buf B303(QB[37], QB_[37]);
  buf B304(QB[38], QB_[38]);
  buf B305(QB[39], QB_[39]);
  buf B306(QB[40], QB_[40]);
  buf B307(QB[41], QB_[41]);
  buf B308(QB[42], QB_[42]);
  buf B309(QB[43], QB_[43]);
  buf B310(QB[44], QB_[44]);
  buf B311(QB[45], QB_[45]);
  buf B312(QB[46], QB_[46]);
  buf B313(QB[47], QB_[47]);
  buf B314(QB[48], QB_[48]);
  buf B315(QB[49], QB_[49]);
  buf B316(QB[50], QB_[50]);
  buf B317(QB[51], QB_[51]);
  buf B318(QB[52], QB_[52]);
  buf B319(QB[53], QB_[53]);
  buf B320(QB[54], QB_[54]);
  buf B321(QB[55], QB_[55]);
  buf B322(QB[56], QB_[56]);
  buf B323(QB[57], QB_[57]);
  buf B324(QB[58], QB_[58]);
  buf B325(QB[59], QB_[59]);
  buf B326(QB[60], QB_[60]);
  buf B327(QB[61], QB_[61]);
  buf B328(QB[62], QB_[62]);
  buf B329(QB[63], QB_[63]);
  buf B330(QB[64], QB_[64]);
  buf B331(QB[65], QB_[65]);
  buf B332(QB[66], QB_[66]);
  buf B333(QB[67], QB_[67]);
  buf B334(QB[68], QB_[68]);
  buf B335(QB[69], QB_[69]);
  buf B336(QB[70], QB_[70]);
  buf B337(QB[71], QB_[71]);
  buf B338(QB[72], QB_[72]);
  buf B339(QB[73], QB_[73]);
  buf B340(QB[74], QB_[74]);
  buf B341(QB[75], QB_[75]);
  buf B342(QB[76], QB_[76]);
  buf B343(QB[77], QB_[77]);
  buf B344(QB[78], QB_[78]);
  buf B345(QB[79], QB_[79]);
  buf B346(CLKA_, CLKA);
  buf B347(CENA_, CENA);
  buf B348(WENA_, WENA);
  buf B349(AA_[0], AA[0]);
  buf B350(AA_[1], AA[1]);
  buf B351(AA_[2], AA[2]);
  buf B352(AA_[3], AA[3]);
  buf B353(AA_[4], AA[4]);
  buf B354(AA_[5], AA[5]);
  buf B355(AA_[6], AA[6]);
  buf B356(AA_[7], AA[7]);
  buf B357(AA_[8], AA[8]);
  buf B358(AA_[9], AA[9]);
  buf B359(AA_[10], AA[10]);
  buf B360(DA_[0], DA[0]);
  buf B361(DA_[1], DA[1]);
  buf B362(DA_[2], DA[2]);
  buf B363(DA_[3], DA[3]);
  buf B364(DA_[4], DA[4]);
  buf B365(DA_[5], DA[5]);
  buf B366(DA_[6], DA[6]);
  buf B367(DA_[7], DA[7]);
  buf B368(DA_[8], DA[8]);
  buf B369(DA_[9], DA[9]);
  buf B370(DA_[10], DA[10]);
  buf B371(DA_[11], DA[11]);
  buf B372(DA_[12], DA[12]);
  buf B373(DA_[13], DA[13]);
  buf B374(DA_[14], DA[14]);
  buf B375(DA_[15], DA[15]);
  buf B376(DA_[16], DA[16]);
  buf B377(DA_[17], DA[17]);
  buf B378(DA_[18], DA[18]);
  buf B379(DA_[19], DA[19]);
  buf B380(DA_[20], DA[20]);
  buf B381(DA_[21], DA[21]);
  buf B382(DA_[22], DA[22]);
  buf B383(DA_[23], DA[23]);
  buf B384(DA_[24], DA[24]);
  buf B385(DA_[25], DA[25]);
  buf B386(DA_[26], DA[26]);
  buf B387(DA_[27], DA[27]);
  buf B388(DA_[28], DA[28]);
  buf B389(DA_[29], DA[29]);
  buf B390(DA_[30], DA[30]);
  buf B391(DA_[31], DA[31]);
  buf B392(DA_[32], DA[32]);
  buf B393(DA_[33], DA[33]);
  buf B394(DA_[34], DA[34]);
  buf B395(DA_[35], DA[35]);
  buf B396(DA_[36], DA[36]);
  buf B397(DA_[37], DA[37]);
  buf B398(DA_[38], DA[38]);
  buf B399(DA_[39], DA[39]);
  buf B400(DA_[40], DA[40]);
  buf B401(DA_[41], DA[41]);
  buf B402(DA_[42], DA[42]);
  buf B403(DA_[43], DA[43]);
  buf B404(DA_[44], DA[44]);
  buf B405(DA_[45], DA[45]);
  buf B406(DA_[46], DA[46]);
  buf B407(DA_[47], DA[47]);
  buf B408(DA_[48], DA[48]);
  buf B409(DA_[49], DA[49]);
  buf B410(DA_[50], DA[50]);
  buf B411(DA_[51], DA[51]);
  buf B412(DA_[52], DA[52]);
  buf B413(DA_[53], DA[53]);
  buf B414(DA_[54], DA[54]);
  buf B415(DA_[55], DA[55]);
  buf B416(DA_[56], DA[56]);
  buf B417(DA_[57], DA[57]);
  buf B418(DA_[58], DA[58]);
  buf B419(DA_[59], DA[59]);
  buf B420(DA_[60], DA[60]);
  buf B421(DA_[61], DA[61]);
  buf B422(DA_[62], DA[62]);
  buf B423(DA_[63], DA[63]);
  buf B424(DA_[64], DA[64]);
  buf B425(DA_[65], DA[65]);
  buf B426(DA_[66], DA[66]);
  buf B427(DA_[67], DA[67]);
  buf B428(DA_[68], DA[68]);
  buf B429(DA_[69], DA[69]);
  buf B430(DA_[70], DA[70]);
  buf B431(DA_[71], DA[71]);
  buf B432(DA_[72], DA[72]);
  buf B433(DA_[73], DA[73]);
  buf B434(DA_[74], DA[74]);
  buf B435(DA_[75], DA[75]);
  buf B436(DA_[76], DA[76]);
  buf B437(DA_[77], DA[77]);
  buf B438(DA_[78], DA[78]);
  buf B439(DA_[79], DA[79]);
  buf B440(CLKB_, CLKB);
  buf B441(CENB_, CENB);
  buf B442(WENB_, WENB);
  buf B443(AB_[0], AB[0]);
  buf B444(AB_[1], AB[1]);
  buf B445(AB_[2], AB[2]);
  buf B446(AB_[3], AB[3]);
  buf B447(AB_[4], AB[4]);
  buf B448(AB_[5], AB[5]);
  buf B449(AB_[6], AB[6]);
  buf B450(AB_[7], AB[7]);
  buf B451(AB_[8], AB[8]);
  buf B452(AB_[9], AB[9]);
  buf B453(AB_[10], AB[10]);
  buf B454(DB_[0], DB[0]);
  buf B455(DB_[1], DB[1]);
  buf B456(DB_[2], DB[2]);
  buf B457(DB_[3], DB[3]);
  buf B458(DB_[4], DB[4]);
  buf B459(DB_[5], DB[5]);
  buf B460(DB_[6], DB[6]);
  buf B461(DB_[7], DB[7]);
  buf B462(DB_[8], DB[8]);
  buf B463(DB_[9], DB[9]);
  buf B464(DB_[10], DB[10]);
  buf B465(DB_[11], DB[11]);
  buf B466(DB_[12], DB[12]);
  buf B467(DB_[13], DB[13]);
  buf B468(DB_[14], DB[14]);
  buf B469(DB_[15], DB[15]);
  buf B470(DB_[16], DB[16]);
  buf B471(DB_[17], DB[17]);
  buf B472(DB_[18], DB[18]);
  buf B473(DB_[19], DB[19]);
  buf B474(DB_[20], DB[20]);
  buf B475(DB_[21], DB[21]);
  buf B476(DB_[22], DB[22]);
  buf B477(DB_[23], DB[23]);
  buf B478(DB_[24], DB[24]);
  buf B479(DB_[25], DB[25]);
  buf B480(DB_[26], DB[26]);
  buf B481(DB_[27], DB[27]);
  buf B482(DB_[28], DB[28]);
  buf B483(DB_[29], DB[29]);
  buf B484(DB_[30], DB[30]);
  buf B485(DB_[31], DB[31]);
  buf B486(DB_[32], DB[32]);
  buf B487(DB_[33], DB[33]);
  buf B488(DB_[34], DB[34]);
  buf B489(DB_[35], DB[35]);
  buf B490(DB_[36], DB[36]);
  buf B491(DB_[37], DB[37]);
  buf B492(DB_[38], DB[38]);
  buf B493(DB_[39], DB[39]);
  buf B494(DB_[40], DB[40]);
  buf B495(DB_[41], DB[41]);
  buf B496(DB_[42], DB[42]);
  buf B497(DB_[43], DB[43]);
  buf B498(DB_[44], DB[44]);
  buf B499(DB_[45], DB[45]);
  buf B500(DB_[46], DB[46]);
  buf B501(DB_[47], DB[47]);
  buf B502(DB_[48], DB[48]);
  buf B503(DB_[49], DB[49]);
  buf B504(DB_[50], DB[50]);
  buf B505(DB_[51], DB[51]);
  buf B506(DB_[52], DB[52]);
  buf B507(DB_[53], DB[53]);
  buf B508(DB_[54], DB[54]);
  buf B509(DB_[55], DB[55]);
  buf B510(DB_[56], DB[56]);
  buf B511(DB_[57], DB[57]);
  buf B512(DB_[58], DB[58]);
  buf B513(DB_[59], DB[59]);
  buf B514(DB_[60], DB[60]);
  buf B515(DB_[61], DB[61]);
  buf B516(DB_[62], DB[62]);
  buf B517(DB_[63], DB[63]);
  buf B518(DB_[64], DB[64]);
  buf B519(DB_[65], DB[65]);
  buf B520(DB_[66], DB[66]);
  buf B521(DB_[67], DB[67]);
  buf B522(DB_[68], DB[68]);
  buf B523(DB_[69], DB[69]);
  buf B524(DB_[70], DB[70]);
  buf B525(DB_[71], DB[71]);
  buf B526(DB_[72], DB[72]);
  buf B527(DB_[73], DB[73]);
  buf B528(DB_[74], DB[74]);
  buf B529(DB_[75], DB[75]);
  buf B530(DB_[76], DB[76]);
  buf B531(DB_[77], DB[77]);
  buf B532(DB_[78], DB[78]);
  buf B533(DB_[79], DB[79]);
  buf B534(EMAA_[0], EMAA[0]);
  buf B535(EMAA_[1], EMAA[1]);
  buf B536(EMAA_[2], EMAA[2]);
  buf B537(EMAWA_[0], EMAWA[0]);
  buf B538(EMAWA_[1], EMAWA[1]);
  buf B539(EMASA_, EMASA);
  buf B540(EMAB_[0], EMAB[0]);
  buf B541(EMAB_[1], EMAB[1]);
  buf B542(EMAB_[2], EMAB[2]);
  buf B543(EMAWB_[0], EMAWB[0]);
  buf B544(EMAWB_[1], EMAWB[1]);
  buf B545(EMASB_, EMASB);
  buf B546(TENA_, TENA);
  buf B547(BENA_, BENA);
  buf B548(TCENA_, TCENA);
  buf B549(TWENA_, TWENA);
  buf B550(TAA_[0], TAA[0]);
  buf B551(TAA_[1], TAA[1]);
  buf B552(TAA_[2], TAA[2]);
  buf B553(TAA_[3], TAA[3]);
  buf B554(TAA_[4], TAA[4]);
  buf B555(TAA_[5], TAA[5]);
  buf B556(TAA_[6], TAA[6]);
  buf B557(TAA_[7], TAA[7]);
  buf B558(TAA_[8], TAA[8]);
  buf B559(TAA_[9], TAA[9]);
  buf B560(TAA_[10], TAA[10]);
  buf B561(TDA_[0], TDA[0]);
  buf B562(TDA_[1], TDA[1]);
  buf B563(TDA_[2], TDA[2]);
  buf B564(TDA_[3], TDA[3]);
  buf B565(TDA_[4], TDA[4]);
  buf B566(TDA_[5], TDA[5]);
  buf B567(TDA_[6], TDA[6]);
  buf B568(TDA_[7], TDA[7]);
  buf B569(TDA_[8], TDA[8]);
  buf B570(TDA_[9], TDA[9]);
  buf B571(TDA_[10], TDA[10]);
  buf B572(TDA_[11], TDA[11]);
  buf B573(TDA_[12], TDA[12]);
  buf B574(TDA_[13], TDA[13]);
  buf B575(TDA_[14], TDA[14]);
  buf B576(TDA_[15], TDA[15]);
  buf B577(TDA_[16], TDA[16]);
  buf B578(TDA_[17], TDA[17]);
  buf B579(TDA_[18], TDA[18]);
  buf B580(TDA_[19], TDA[19]);
  buf B581(TDA_[20], TDA[20]);
  buf B582(TDA_[21], TDA[21]);
  buf B583(TDA_[22], TDA[22]);
  buf B584(TDA_[23], TDA[23]);
  buf B585(TDA_[24], TDA[24]);
  buf B586(TDA_[25], TDA[25]);
  buf B587(TDA_[26], TDA[26]);
  buf B588(TDA_[27], TDA[27]);
  buf B589(TDA_[28], TDA[28]);
  buf B590(TDA_[29], TDA[29]);
  buf B591(TDA_[30], TDA[30]);
  buf B592(TDA_[31], TDA[31]);
  buf B593(TDA_[32], TDA[32]);
  buf B594(TDA_[33], TDA[33]);
  buf B595(TDA_[34], TDA[34]);
  buf B596(TDA_[35], TDA[35]);
  buf B597(TDA_[36], TDA[36]);
  buf B598(TDA_[37], TDA[37]);
  buf B599(TDA_[38], TDA[38]);
  buf B600(TDA_[39], TDA[39]);
  buf B601(TDA_[40], TDA[40]);
  buf B602(TDA_[41], TDA[41]);
  buf B603(TDA_[42], TDA[42]);
  buf B604(TDA_[43], TDA[43]);
  buf B605(TDA_[44], TDA[44]);
  buf B606(TDA_[45], TDA[45]);
  buf B607(TDA_[46], TDA[46]);
  buf B608(TDA_[47], TDA[47]);
  buf B609(TDA_[48], TDA[48]);
  buf B610(TDA_[49], TDA[49]);
  buf B611(TDA_[50], TDA[50]);
  buf B612(TDA_[51], TDA[51]);
  buf B613(TDA_[52], TDA[52]);
  buf B614(TDA_[53], TDA[53]);
  buf B615(TDA_[54], TDA[54]);
  buf B616(TDA_[55], TDA[55]);
  buf B617(TDA_[56], TDA[56]);
  buf B618(TDA_[57], TDA[57]);
  buf B619(TDA_[58], TDA[58]);
  buf B620(TDA_[59], TDA[59]);
  buf B621(TDA_[60], TDA[60]);
  buf B622(TDA_[61], TDA[61]);
  buf B623(TDA_[62], TDA[62]);
  buf B624(TDA_[63], TDA[63]);
  buf B625(TDA_[64], TDA[64]);
  buf B626(TDA_[65], TDA[65]);
  buf B627(TDA_[66], TDA[66]);
  buf B628(TDA_[67], TDA[67]);
  buf B629(TDA_[68], TDA[68]);
  buf B630(TDA_[69], TDA[69]);
  buf B631(TDA_[70], TDA[70]);
  buf B632(TDA_[71], TDA[71]);
  buf B633(TDA_[72], TDA[72]);
  buf B634(TDA_[73], TDA[73]);
  buf B635(TDA_[74], TDA[74]);
  buf B636(TDA_[75], TDA[75]);
  buf B637(TDA_[76], TDA[76]);
  buf B638(TDA_[77], TDA[77]);
  buf B639(TDA_[78], TDA[78]);
  buf B640(TDA_[79], TDA[79]);
  buf B641(TQA_[0], TQA[0]);
  buf B642(TQA_[1], TQA[1]);
  buf B643(TQA_[2], TQA[2]);
  buf B644(TQA_[3], TQA[3]);
  buf B645(TQA_[4], TQA[4]);
  buf B646(TQA_[5], TQA[5]);
  buf B647(TQA_[6], TQA[6]);
  buf B648(TQA_[7], TQA[7]);
  buf B649(TQA_[8], TQA[8]);
  buf B650(TQA_[9], TQA[9]);
  buf B651(TQA_[10], TQA[10]);
  buf B652(TQA_[11], TQA[11]);
  buf B653(TQA_[12], TQA[12]);
  buf B654(TQA_[13], TQA[13]);
  buf B655(TQA_[14], TQA[14]);
  buf B656(TQA_[15], TQA[15]);
  buf B657(TQA_[16], TQA[16]);
  buf B658(TQA_[17], TQA[17]);
  buf B659(TQA_[18], TQA[18]);
  buf B660(TQA_[19], TQA[19]);
  buf B661(TQA_[20], TQA[20]);
  buf B662(TQA_[21], TQA[21]);
  buf B663(TQA_[22], TQA[22]);
  buf B664(TQA_[23], TQA[23]);
  buf B665(TQA_[24], TQA[24]);
  buf B666(TQA_[25], TQA[25]);
  buf B667(TQA_[26], TQA[26]);
  buf B668(TQA_[27], TQA[27]);
  buf B669(TQA_[28], TQA[28]);
  buf B670(TQA_[29], TQA[29]);
  buf B671(TQA_[30], TQA[30]);
  buf B672(TQA_[31], TQA[31]);
  buf B673(TQA_[32], TQA[32]);
  buf B674(TQA_[33], TQA[33]);
  buf B675(TQA_[34], TQA[34]);
  buf B676(TQA_[35], TQA[35]);
  buf B677(TQA_[36], TQA[36]);
  buf B678(TQA_[37], TQA[37]);
  buf B679(TQA_[38], TQA[38]);
  buf B680(TQA_[39], TQA[39]);
  buf B681(TQA_[40], TQA[40]);
  buf B682(TQA_[41], TQA[41]);
  buf B683(TQA_[42], TQA[42]);
  buf B684(TQA_[43], TQA[43]);
  buf B685(TQA_[44], TQA[44]);
  buf B686(TQA_[45], TQA[45]);
  buf B687(TQA_[46], TQA[46]);
  buf B688(TQA_[47], TQA[47]);
  buf B689(TQA_[48], TQA[48]);
  buf B690(TQA_[49], TQA[49]);
  buf B691(TQA_[50], TQA[50]);
  buf B692(TQA_[51], TQA[51]);
  buf B693(TQA_[52], TQA[52]);
  buf B694(TQA_[53], TQA[53]);
  buf B695(TQA_[54], TQA[54]);
  buf B696(TQA_[55], TQA[55]);
  buf B697(TQA_[56], TQA[56]);
  buf B698(TQA_[57], TQA[57]);
  buf B699(TQA_[58], TQA[58]);
  buf B700(TQA_[59], TQA[59]);
  buf B701(TQA_[60], TQA[60]);
  buf B702(TQA_[61], TQA[61]);
  buf B703(TQA_[62], TQA[62]);
  buf B704(TQA_[63], TQA[63]);
  buf B705(TQA_[64], TQA[64]);
  buf B706(TQA_[65], TQA[65]);
  buf B707(TQA_[66], TQA[66]);
  buf B708(TQA_[67], TQA[67]);
  buf B709(TQA_[68], TQA[68]);
  buf B710(TQA_[69], TQA[69]);
  buf B711(TQA_[70], TQA[70]);
  buf B712(TQA_[71], TQA[71]);
  buf B713(TQA_[72], TQA[72]);
  buf B714(TQA_[73], TQA[73]);
  buf B715(TQA_[74], TQA[74]);
  buf B716(TQA_[75], TQA[75]);
  buf B717(TQA_[76], TQA[76]);
  buf B718(TQA_[77], TQA[77]);
  buf B719(TQA_[78], TQA[78]);
  buf B720(TQA_[79], TQA[79]);
  buf B721(TENB_, TENB);
  buf B722(BENB_, BENB);
  buf B723(TCENB_, TCENB);
  buf B724(TWENB_, TWENB);
  buf B725(TAB_[0], TAB[0]);
  buf B726(TAB_[1], TAB[1]);
  buf B727(TAB_[2], TAB[2]);
  buf B728(TAB_[3], TAB[3]);
  buf B729(TAB_[4], TAB[4]);
  buf B730(TAB_[5], TAB[5]);
  buf B731(TAB_[6], TAB[6]);
  buf B732(TAB_[7], TAB[7]);
  buf B733(TAB_[8], TAB[8]);
  buf B734(TAB_[9], TAB[9]);
  buf B735(TAB_[10], TAB[10]);
  buf B736(TDB_[0], TDB[0]);
  buf B737(TDB_[1], TDB[1]);
  buf B738(TDB_[2], TDB[2]);
  buf B739(TDB_[3], TDB[3]);
  buf B740(TDB_[4], TDB[4]);
  buf B741(TDB_[5], TDB[5]);
  buf B742(TDB_[6], TDB[6]);
  buf B743(TDB_[7], TDB[7]);
  buf B744(TDB_[8], TDB[8]);
  buf B745(TDB_[9], TDB[9]);
  buf B746(TDB_[10], TDB[10]);
  buf B747(TDB_[11], TDB[11]);
  buf B748(TDB_[12], TDB[12]);
  buf B749(TDB_[13], TDB[13]);
  buf B750(TDB_[14], TDB[14]);
  buf B751(TDB_[15], TDB[15]);
  buf B752(TDB_[16], TDB[16]);
  buf B753(TDB_[17], TDB[17]);
  buf B754(TDB_[18], TDB[18]);
  buf B755(TDB_[19], TDB[19]);
  buf B756(TDB_[20], TDB[20]);
  buf B757(TDB_[21], TDB[21]);
  buf B758(TDB_[22], TDB[22]);
  buf B759(TDB_[23], TDB[23]);
  buf B760(TDB_[24], TDB[24]);
  buf B761(TDB_[25], TDB[25]);
  buf B762(TDB_[26], TDB[26]);
  buf B763(TDB_[27], TDB[27]);
  buf B764(TDB_[28], TDB[28]);
  buf B765(TDB_[29], TDB[29]);
  buf B766(TDB_[30], TDB[30]);
  buf B767(TDB_[31], TDB[31]);
  buf B768(TDB_[32], TDB[32]);
  buf B769(TDB_[33], TDB[33]);
  buf B770(TDB_[34], TDB[34]);
  buf B771(TDB_[35], TDB[35]);
  buf B772(TDB_[36], TDB[36]);
  buf B773(TDB_[37], TDB[37]);
  buf B774(TDB_[38], TDB[38]);
  buf B775(TDB_[39], TDB[39]);
  buf B776(TDB_[40], TDB[40]);
  buf B777(TDB_[41], TDB[41]);
  buf B778(TDB_[42], TDB[42]);
  buf B779(TDB_[43], TDB[43]);
  buf B780(TDB_[44], TDB[44]);
  buf B781(TDB_[45], TDB[45]);
  buf B782(TDB_[46], TDB[46]);
  buf B783(TDB_[47], TDB[47]);
  buf B784(TDB_[48], TDB[48]);
  buf B785(TDB_[49], TDB[49]);
  buf B786(TDB_[50], TDB[50]);
  buf B787(TDB_[51], TDB[51]);
  buf B788(TDB_[52], TDB[52]);
  buf B789(TDB_[53], TDB[53]);
  buf B790(TDB_[54], TDB[54]);
  buf B791(TDB_[55], TDB[55]);
  buf B792(TDB_[56], TDB[56]);
  buf B793(TDB_[57], TDB[57]);
  buf B794(TDB_[58], TDB[58]);
  buf B795(TDB_[59], TDB[59]);
  buf B796(TDB_[60], TDB[60]);
  buf B797(TDB_[61], TDB[61]);
  buf B798(TDB_[62], TDB[62]);
  buf B799(TDB_[63], TDB[63]);
  buf B800(TDB_[64], TDB[64]);
  buf B801(TDB_[65], TDB[65]);
  buf B802(TDB_[66], TDB[66]);
  buf B803(TDB_[67], TDB[67]);
  buf B804(TDB_[68], TDB[68]);
  buf B805(TDB_[69], TDB[69]);
  buf B806(TDB_[70], TDB[70]);
  buf B807(TDB_[71], TDB[71]);
  buf B808(TDB_[72], TDB[72]);
  buf B809(TDB_[73], TDB[73]);
  buf B810(TDB_[74], TDB[74]);
  buf B811(TDB_[75], TDB[75]);
  buf B812(TDB_[76], TDB[76]);
  buf B813(TDB_[77], TDB[77]);
  buf B814(TDB_[78], TDB[78]);
  buf B815(TDB_[79], TDB[79]);
  buf B816(TQB_[0], TQB[0]);
  buf B817(TQB_[1], TQB[1]);
  buf B818(TQB_[2], TQB[2]);
  buf B819(TQB_[3], TQB[3]);
  buf B820(TQB_[4], TQB[4]);
  buf B821(TQB_[5], TQB[5]);
  buf B822(TQB_[6], TQB[6]);
  buf B823(TQB_[7], TQB[7]);
  buf B824(TQB_[8], TQB[8]);
  buf B825(TQB_[9], TQB[9]);
  buf B826(TQB_[10], TQB[10]);
  buf B827(TQB_[11], TQB[11]);
  buf B828(TQB_[12], TQB[12]);
  buf B829(TQB_[13], TQB[13]);
  buf B830(TQB_[14], TQB[14]);
  buf B831(TQB_[15], TQB[15]);
  buf B832(TQB_[16], TQB[16]);
  buf B833(TQB_[17], TQB[17]);
  buf B834(TQB_[18], TQB[18]);
  buf B835(TQB_[19], TQB[19]);
  buf B836(TQB_[20], TQB[20]);
  buf B837(TQB_[21], TQB[21]);
  buf B838(TQB_[22], TQB[22]);
  buf B839(TQB_[23], TQB[23]);
  buf B840(TQB_[24], TQB[24]);
  buf B841(TQB_[25], TQB[25]);
  buf B842(TQB_[26], TQB[26]);
  buf B843(TQB_[27], TQB[27]);
  buf B844(TQB_[28], TQB[28]);
  buf B845(TQB_[29], TQB[29]);
  buf B846(TQB_[30], TQB[30]);
  buf B847(TQB_[31], TQB[31]);
  buf B848(TQB_[32], TQB[32]);
  buf B849(TQB_[33], TQB[33]);
  buf B850(TQB_[34], TQB[34]);
  buf B851(TQB_[35], TQB[35]);
  buf B852(TQB_[36], TQB[36]);
  buf B853(TQB_[37], TQB[37]);
  buf B854(TQB_[38], TQB[38]);
  buf B855(TQB_[39], TQB[39]);
  buf B856(TQB_[40], TQB[40]);
  buf B857(TQB_[41], TQB[41]);
  buf B858(TQB_[42], TQB[42]);
  buf B859(TQB_[43], TQB[43]);
  buf B860(TQB_[44], TQB[44]);
  buf B861(TQB_[45], TQB[45]);
  buf B862(TQB_[46], TQB[46]);
  buf B863(TQB_[47], TQB[47]);
  buf B864(TQB_[48], TQB[48]);
  buf B865(TQB_[49], TQB[49]);
  buf B866(TQB_[50], TQB[50]);
  buf B867(TQB_[51], TQB[51]);
  buf B868(TQB_[52], TQB[52]);
  buf B869(TQB_[53], TQB[53]);
  buf B870(TQB_[54], TQB[54]);
  buf B871(TQB_[55], TQB[55]);
  buf B872(TQB_[56], TQB[56]);
  buf B873(TQB_[57], TQB[57]);
  buf B874(TQB_[58], TQB[58]);
  buf B875(TQB_[59], TQB[59]);
  buf B876(TQB_[60], TQB[60]);
  buf B877(TQB_[61], TQB[61]);
  buf B878(TQB_[62], TQB[62]);
  buf B879(TQB_[63], TQB[63]);
  buf B880(TQB_[64], TQB[64]);
  buf B881(TQB_[65], TQB[65]);
  buf B882(TQB_[66], TQB[66]);
  buf B883(TQB_[67], TQB[67]);
  buf B884(TQB_[68], TQB[68]);
  buf B885(TQB_[69], TQB[69]);
  buf B886(TQB_[70], TQB[70]);
  buf B887(TQB_[71], TQB[71]);
  buf B888(TQB_[72], TQB[72]);
  buf B889(TQB_[73], TQB[73]);
  buf B890(TQB_[74], TQB[74]);
  buf B891(TQB_[75], TQB[75]);
  buf B892(TQB_[76], TQB[76]);
  buf B893(TQB_[77], TQB[77]);
  buf B894(TQB_[78], TQB[78]);
  buf B895(TQB_[79], TQB[79]);
  buf B896(RET1N_, RET1N);
  buf B897(STOVA_, STOVA);
  buf B898(STOVB_, STOVB);
  buf B899(COLLDISN_, COLLDISN);

  assign CENYA_ = RET1N_ ? (TENA_ ? CENA_ : TCENA_) : 1'bx;
  assign WENYA_ = RET1N_ ? (TENA_ ? WENA_ : TWENA_) : 1'bx;
  assign AYA_ = RET1N_ ? (TENA_ ? AA_ : TAA_) : {11{1'bx}};
  assign DYA_ = RET1N_ ? (TENA_ ? DA_ : TDA_) : {80{1'bx}};
  assign CENYB_ = RET1N_ ? (TENB_ ? CENB_ : TCENB_) : 1'bx;
  assign WENYB_ = RET1N_ ? (TENB_ ? WENB_ : TWENB_) : 1'bx;
  assign AYB_ = RET1N_ ? (TENB_ ? AB_ : TAB_) : {11{1'bx}};
  assign DYB_ = RET1N_ ? (TENB_ ? DB_ : TDB_) : {80{1'bx}};
   `ifdef ARM_FAULT_MODELING
     sram_dp_hde_error_injection u1(.CLK(CLKA_), .Q_out(QA_), .A(AA_int), .CEN(CENA_int), .TQ(TQA_), .BEN(BENA_), .WEN(WENA_int), .Q_in(QA_int));
  `else
  assign QA_ = RET1N_ ? (BENA_ ? ((STOVA_ ? (QA_int_delayed) : (QA_int))) : TQA_) : {80{1'bx}};
  `endif
  assign QB_ = RET1N_ ? (BENB_ ? ((STOVB_ ? (QB_int_delayed) : (QB_int))) : TQB_) : {80{1'bx}};

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
	reg [10:0] Atemp;
  begin
	$readmemb(filename, memld);
     if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {80{1'b1}};
        row_mask =  ( {3'b000, writeEnable[79], 3'b000, writeEnable[78], 3'b000, writeEnable[77],
          3'b000, writeEnable[76], 3'b000, writeEnable[75], 3'b000, writeEnable[74],
          3'b000, writeEnable[73], 3'b000, writeEnable[72], 3'b000, writeEnable[71],
          3'b000, writeEnable[70], 3'b000, writeEnable[69], 3'b000, writeEnable[68],
          3'b000, writeEnable[67], 3'b000, writeEnable[66], 3'b000, writeEnable[65],
          3'b000, writeEnable[64], 3'b000, writeEnable[63], 3'b000, writeEnable[62],
          3'b000, writeEnable[61], 3'b000, writeEnable[60], 3'b000, writeEnable[59],
          3'b000, writeEnable[58], 3'b000, writeEnable[57], 3'b000, writeEnable[56],
          3'b000, writeEnable[55], 3'b000, writeEnable[54], 3'b000, writeEnable[53],
          3'b000, writeEnable[52], 3'b000, writeEnable[51], 3'b000, writeEnable[50],
          3'b000, writeEnable[49], 3'b000, writeEnable[48], 3'b000, writeEnable[47],
          3'b000, writeEnable[46], 3'b000, writeEnable[45], 3'b000, writeEnable[44],
          3'b000, writeEnable[43], 3'b000, writeEnable[42], 3'b000, writeEnable[41],
          3'b000, writeEnable[40], 3'b000, writeEnable[39], 3'b000, writeEnable[38],
          3'b000, writeEnable[37], 3'b000, writeEnable[36], 3'b000, writeEnable[35],
          3'b000, writeEnable[34], 3'b000, writeEnable[33], 3'b000, writeEnable[32],
          3'b000, writeEnable[31], 3'b000, writeEnable[30], 3'b000, writeEnable[29],
          3'b000, writeEnable[28], 3'b000, writeEnable[27], 3'b000, writeEnable[26],
          3'b000, writeEnable[25], 3'b000, writeEnable[24], 3'b000, writeEnable[23],
          3'b000, writeEnable[22], 3'b000, writeEnable[21], 3'b000, writeEnable[20],
          3'b000, writeEnable[19], 3'b000, writeEnable[18], 3'b000, writeEnable[17],
          3'b000, writeEnable[16], 3'b000, writeEnable[15], 3'b000, writeEnable[14],
          3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[79], 3'b000, wordtemp[78], 3'b000, wordtemp[77],
          3'b000, wordtemp[76], 3'b000, wordtemp[75], 3'b000, wordtemp[74], 3'b000, wordtemp[73],
          3'b000, wordtemp[72], 3'b000, wordtemp[71], 3'b000, wordtemp[70], 3'b000, wordtemp[69],
          3'b000, wordtemp[68], 3'b000, wordtemp[67], 3'b000, wordtemp[66], 3'b000, wordtemp[65],
          3'b000, wordtemp[64], 3'b000, wordtemp[63], 3'b000, wordtemp[62], 3'b000, wordtemp[61],
          3'b000, wordtemp[60], 3'b000, wordtemp[59], 3'b000, wordtemp[58], 3'b000, wordtemp[57],
          3'b000, wordtemp[56], 3'b000, wordtemp[55], 3'b000, wordtemp[54], 3'b000, wordtemp[53],
          3'b000, wordtemp[52], 3'b000, wordtemp[51], 3'b000, wordtemp[50], 3'b000, wordtemp[49],
          3'b000, wordtemp[48], 3'b000, wordtemp[47], 3'b000, wordtemp[46], 3'b000, wordtemp[45],
          3'b000, wordtemp[44], 3'b000, wordtemp[43], 3'b000, wordtemp[42], 3'b000, wordtemp[41],
          3'b000, wordtemp[40], 3'b000, wordtemp[39], 3'b000, wordtemp[38], 3'b000, wordtemp[37],
          3'b000, wordtemp[36], 3'b000, wordtemp[35], 3'b000, wordtemp[34], 3'b000, wordtemp[33],
          3'b000, wordtemp[32], 3'b000, wordtemp[31], 3'b000, wordtemp[30], 3'b000, wordtemp[29],
          3'b000, wordtemp[28], 3'b000, wordtemp[27], 3'b000, wordtemp[26], 3'b000, wordtemp[25],
          3'b000, wordtemp[24], 3'b000, wordtemp[23], 3'b000, wordtemp[22], 3'b000, wordtemp[21],
          3'b000, wordtemp[20], 3'b000, wordtemp[19], 3'b000, wordtemp[18], 3'b000, wordtemp[17],
          3'b000, wordtemp[16], 3'b000, wordtemp[15], 3'b000, wordtemp[14], 3'b000, wordtemp[13],
          3'b000, wordtemp[12], 3'b000, wordtemp[11], 3'b000, wordtemp[10], 3'b000, wordtemp[9],
          3'b000, wordtemp[8], 3'b000, wordtemp[7], 3'b000, wordtemp[6], 3'b000, wordtemp[5],
          3'b000, wordtemp[4], 3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
          3'b000, wordtemp[0]} << mux_address);
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
	reg [10:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
     if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {80{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[316], data_out[312], data_out[308], data_out[304], data_out[300],
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
      QA_int = {shifted_readLatch0[79], shifted_readLatch0[78], shifted_readLatch0[77],
        shifted_readLatch0[76], shifted_readLatch0[75], shifted_readLatch0[74], shifted_readLatch0[73],
        shifted_readLatch0[72], shifted_readLatch0[71], shifted_readLatch0[70], shifted_readLatch0[69],
        shifted_readLatch0[68], shifted_readLatch0[67], shifted_readLatch0[66], shifted_readLatch0[65],
        shifted_readLatch0[64], shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
        shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
        shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
        shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
        shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
        shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
        shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
        shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
        shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
        shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
        shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
        shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
        shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
        shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
        shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
        shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
        shifted_readLatch0[0]};
   	$fdisplay(dump_file_desc, "%b", QA_int);
  end
  	end
//    $fclose(filename_dump);
  end
  endtask


  task readWriteA;
  begin
    if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if (RET1N_int === 1'b0 && CENA_int === 1'b0) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{CENA_int, EMAA_int, EMAWA_int, EMASA_int, RET1N_int, (STOVA_int 
     && !CENA_int)} === 1'bx) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if ((AA_int >= WORDS) && (CENA_int === 1'b0)) begin
      QA_int = WENA_int !== 1'b1 ? QA_int : {80{1'bx}};
      QA_int_delayed = WENA_int !== 1'b1 ? QA_int_delayed : {80{1'bx}};
    end else if (CENA_int === 1'b0 && (^AA_int) === 1'bx) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if (CENA_int === 1'b0) begin
      mux_address = (AA_int & 2'b11);
      row_address = (AA_int >> 2);
      if (row_address > 511)
        row = {320{1'bx}};
      else
        row = mem[row_address];
      writeEnable = ~{80{WENA_int}};
      if (WENA_int !== 1'b1) begin
        row_mask =  ( {3'b000, writeEnable[79], 3'b000, writeEnable[78], 3'b000, writeEnable[77],
          3'b000, writeEnable[76], 3'b000, writeEnable[75], 3'b000, writeEnable[74],
          3'b000, writeEnable[73], 3'b000, writeEnable[72], 3'b000, writeEnable[71],
          3'b000, writeEnable[70], 3'b000, writeEnable[69], 3'b000, writeEnable[68],
          3'b000, writeEnable[67], 3'b000, writeEnable[66], 3'b000, writeEnable[65],
          3'b000, writeEnable[64], 3'b000, writeEnable[63], 3'b000, writeEnable[62],
          3'b000, writeEnable[61], 3'b000, writeEnable[60], 3'b000, writeEnable[59],
          3'b000, writeEnable[58], 3'b000, writeEnable[57], 3'b000, writeEnable[56],
          3'b000, writeEnable[55], 3'b000, writeEnable[54], 3'b000, writeEnable[53],
          3'b000, writeEnable[52], 3'b000, writeEnable[51], 3'b000, writeEnable[50],
          3'b000, writeEnable[49], 3'b000, writeEnable[48], 3'b000, writeEnable[47],
          3'b000, writeEnable[46], 3'b000, writeEnable[45], 3'b000, writeEnable[44],
          3'b000, writeEnable[43], 3'b000, writeEnable[42], 3'b000, writeEnable[41],
          3'b000, writeEnable[40], 3'b000, writeEnable[39], 3'b000, writeEnable[38],
          3'b000, writeEnable[37], 3'b000, writeEnable[36], 3'b000, writeEnable[35],
          3'b000, writeEnable[34], 3'b000, writeEnable[33], 3'b000, writeEnable[32],
          3'b000, writeEnable[31], 3'b000, writeEnable[30], 3'b000, writeEnable[29],
          3'b000, writeEnable[28], 3'b000, writeEnable[27], 3'b000, writeEnable[26],
          3'b000, writeEnable[25], 3'b000, writeEnable[24], 3'b000, writeEnable[23],
          3'b000, writeEnable[22], 3'b000, writeEnable[21], 3'b000, writeEnable[20],
          3'b000, writeEnable[19], 3'b000, writeEnable[18], 3'b000, writeEnable[17],
          3'b000, writeEnable[16], 3'b000, writeEnable[15], 3'b000, writeEnable[14],
          3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DA_int[79], 3'b000, DA_int[78], 3'b000, DA_int[77],
          3'b000, DA_int[76], 3'b000, DA_int[75], 3'b000, DA_int[74], 3'b000, DA_int[73],
          3'b000, DA_int[72], 3'b000, DA_int[71], 3'b000, DA_int[70], 3'b000, DA_int[69],
          3'b000, DA_int[68], 3'b000, DA_int[67], 3'b000, DA_int[66], 3'b000, DA_int[65],
          3'b000, DA_int[64], 3'b000, DA_int[63], 3'b000, DA_int[62], 3'b000, DA_int[61],
          3'b000, DA_int[60], 3'b000, DA_int[59], 3'b000, DA_int[58], 3'b000, DA_int[57],
          3'b000, DA_int[56], 3'b000, DA_int[55], 3'b000, DA_int[54], 3'b000, DA_int[53],
          3'b000, DA_int[52], 3'b000, DA_int[51], 3'b000, DA_int[50], 3'b000, DA_int[49],
          3'b000, DA_int[48], 3'b000, DA_int[47], 3'b000, DA_int[46], 3'b000, DA_int[45],
          3'b000, DA_int[44], 3'b000, DA_int[43], 3'b000, DA_int[42], 3'b000, DA_int[41],
          3'b000, DA_int[40], 3'b000, DA_int[39], 3'b000, DA_int[38], 3'b000, DA_int[37],
          3'b000, DA_int[36], 3'b000, DA_int[35], 3'b000, DA_int[34], 3'b000, DA_int[33],
          3'b000, DA_int[32], 3'b000, DA_int[31], 3'b000, DA_int[30], 3'b000, DA_int[29],
          3'b000, DA_int[28], 3'b000, DA_int[27], 3'b000, DA_int[26], 3'b000, DA_int[25],
          3'b000, DA_int[24], 3'b000, DA_int[23], 3'b000, DA_int[22], 3'b000, DA_int[21],
          3'b000, DA_int[20], 3'b000, DA_int[19], 3'b000, DA_int[18], 3'b000, DA_int[17],
          3'b000, DA_int[16], 3'b000, DA_int[15], 3'b000, DA_int[14], 3'b000, DA_int[13],
          3'b000, DA_int[12], 3'b000, DA_int[11], 3'b000, DA_int[10], 3'b000, DA_int[9],
          3'b000, DA_int[8], 3'b000, DA_int[7], 3'b000, DA_int[6], 3'b000, DA_int[5],
          3'b000, DA_int[4], 3'b000, DA_int[3], 3'b000, DA_int[2], 3'b000, DA_int[1],
          3'b000, DA_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[316], data_out[312], data_out[308], data_out[304], data_out[300],
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
      QA_int = {shifted_readLatch0[79], shifted_readLatch0[78], shifted_readLatch0[77],
        shifted_readLatch0[76], shifted_readLatch0[75], shifted_readLatch0[74], shifted_readLatch0[73],
        shifted_readLatch0[72], shifted_readLatch0[71], shifted_readLatch0[70], shifted_readLatch0[69],
        shifted_readLatch0[68], shifted_readLatch0[67], shifted_readLatch0[66], shifted_readLatch0[65],
        shifted_readLatch0[64], shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
        shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
        shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
        shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
        shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
        shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
        shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
        shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
        shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
        shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
        shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
        shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
        shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
        shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
        shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
        shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
        shifted_readLatch0[0]};
      end
    end
  end
  endtask
  always @ (CENA_ or TCENA_ or TENA_ or CLKA_) begin
  	if(CLKA_ == 1'b0) begin
  		CENA_p2 = CENA_;
  		TCENA_p2 = TCENA_;
  	end
  end

  always @ RET1N_ begin
    if (CLKA_ == 1'b1) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CENA_p2 === 1'b0 || TCENA_p2 === 1'b0) ) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CENA_p2 === 1'b0 || TCENA_p2 === 1'b0) ) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end
    if (RET1N_ == 1'b0) begin
      QA_int = {80{1'bx}};
      QA_int_delayed = {80{1'bx}};
      CENA_int = 1'bx;
      WENA_int = 1'bx;
      AA_int = {11{1'bx}};
      DA_int = {80{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      BENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = 1'bx;
      TAA_int = {11{1'bx}};
      TDA_int = {80{1'bx}};
      TQA_int = {80{1'bx}};
      RET1N_int = 1'bx;
      STOVA_int = 1'bx;
      COLLDISN_int = 1'bx;
    end else begin
      QA_int = {80{1'bx}};
      QA_int_delayed = {80{1'bx}};
      CENA_int = 1'bx;
      WENA_int = 1'bx;
      AA_int = {11{1'bx}};
      DA_int = {80{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      BENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = 1'bx;
      TAA_int = {11{1'bx}};
      TDA_int = {80{1'bx}};
      TQA_int = {80{1'bx}};
      RET1N_int = 1'bx;
      STOVA_int = 1'bx;
      COLLDISN_int = 1'bx;
    end
    RET1N_int = RET1N_;
  end


  always @ CLKA_ begin
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
    if ((CLKA_ === 1'bx || CLKA_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(0);
      QA_int = {80{1'bx}};
    end else if (CLKA_ === 1'b1 && LAST_CLKA === 1'b0) begin
      CENA_int = TENA_ ? CENA_ : TCENA_;
      EMAA_int = EMAA_;
      EMAWA_int = EMAWA_;
      EMASA_int = EMASA_;
      TENA_int = TENA_;
      BENA_int = BENA_;
      TWENA_int = TWENA_;
      TQA_int = TQA_;
      RET1N_int = RET1N_;
      STOVA_int = STOVA_;
      COLLDISN_int = COLLDISN_;
      if (CENA_int != 1'b1) begin
        WENA_int = TENA_ ? WENA_ : TWENA_;
        AA_int = TENA_ ? AA_ : TAA_;
        DA_int = TENA_ ? DA_ : TDA_;
        TCENA_int = TCENA_;
        TAA_int = TAA_;
        TDA_int = TDA_;
      end
      clk0_int = 1'b0;
      if (CENA_int === 1'b0 && WENA_int === 1'b1) 
         QA_int_delayed = {80{1'bx}};
      if (CENA_int === 1'b0) previous_CLKA = $realtime;
    readWriteA;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && COLLDISN_int === 1'b1 && row_contention(AA_int, AB_int,  WENA_int, WENB_int)) 
       begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          DA_int = {80{1'bx}};
          readWriteA;
          DB_int = {80{1'bx}};
          readWriteB;
	      end
        end else if (WENA_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QB_int = {80{1'bx}};
		end
        end else if (WENB_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QA_int = {80{1'bx}};
		end
        end else begin
          readWriteB;
          readWriteA;
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_READ = 1;
        end
		if (!is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          readWriteB;
          readWriteA;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE = 1;
        end else if (!(WENA_int !== 1'b1) && (WENB_int !== 1'b1)) begin
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else if ((WENA_int !== 1'b1) && !(WENB_int !== 1'b1)) begin
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else begin
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
        end
        end
      end else if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && (COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx)  && row_contention(AA_int,
        AB_int,  WENA_int, WENB_int)) begin
          $display("%s row contention: in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (WENB_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DB_int = {80{1'bx}};
          readWriteB;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
          QB_int = {80{1'bx}};
        end else begin
          readWriteB;
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE_1 = 1;
          READ_READ_1 = 1;
        end
        if (WENA_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DA_int = {80{1'bx}};
          readWriteA;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          QA_int = {80{1'bx}};
        end else begin
          readWriteA;
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (CLKA_ === 1'b0 && LAST_CLKA === 1'b1) begin
      QA_int_delayed = QA_int;
    end
    LAST_CLKA = CLKA_;
  end
  end

  reg globalNotifier0;
  initial globalNotifier0 = 1'b0;

  always @ globalNotifier0 begin
    if ($realtime == 0) begin
    end else if (CENA_int === 1'bx || EMAA_int[0] === 1'bx || EMAA_int[1] === 1'bx || 
      EMAA_int[2] === 1'bx || EMASA_int === 1'bx || EMAWA_int[0] === 1'bx || EMAWA_int[1] === 1'bx || 
      RET1N_int === 1'bx || (STOVA_int && !CENA_int) === 1'bx || TENA_int === 1'bx || 
      clk0_int === 1'bx) begin
      QA_int = {80{1'bx}};
      failedWrite(0);
    end else if  (cont_flag0_int === 1'bx && COLLDISN_int === 1'b1 &&  (CENA_int !== 
     1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1)) && row_contention(TENB_ ? AB_ : 
     TAB_, AA_int,  WENA_int, TENB_ ? WENB_ : TWENB_)) begin
      cont_flag0_int = 1'b0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          DA_int = {80{1'bx}};
          readWriteA;
          DB_int = {80{1'bx}};
          readWriteB;
	      end
        end else if (WENA_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QB_int = {80{1'bx}};
		end
        end else if (WENB_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QA_int = {80{1'bx}};
		end
        end else begin
          readWriteB;
          readWriteA;
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_READ = 1;
        end
		if (!is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          readWriteB;
          readWriteA;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE = 1;
        end else if (!(WENA_int !== 1'b1) && (WENB_int !== 1'b1)) begin
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else if ((WENA_int !== 1'b1) && !(WENB_int !== 1'b1)) begin
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else begin
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
        end
        end
    end else if  ((CENA_int !== 1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1)) && cont_flag0_int 
     === 1'bx && (COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENB_ 
     ? AB_ : TAB_, AA_int,  WENA_int, TENB_ ? WENB_ : TWENB_)) begin
      cont_flag0_int = 1'b0;
          $display("%s row contention: in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (WENB_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DB_int = {80{1'bx}};
          readWriteB;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
          QB_int = {80{1'bx}};
        end else begin
          readWriteB;
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE_1 = 1;
          READ_READ_1 = 1;
        end
        if (WENA_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DA_int = {80{1'bx}};
          readWriteA;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          QA_int = {80{1'bx}};
        end else begin
          readWriteA;
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
    end else begin
      readWriteA;
   end
    globalNotifier0 = 1'b0;
  end

  task readWriteB;
  begin
    if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if (RET1N_int === 1'b0 && CENB_int === 1'b0) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{CENB_int, EMAB_int, EMAWB_int, EMASB_int, RET1N_int, (STOVB_int 
     && !CENB_int)} === 1'bx) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if ((AB_int >= WORDS) && (CENB_int === 1'b0)) begin
      QB_int = WENB_int !== 1'b1 ? QB_int : {80{1'bx}};
      QB_int_delayed = WENB_int !== 1'b1 ? QB_int_delayed : {80{1'bx}};
    end else if (CENB_int === 1'b0 && (^AB_int) === 1'bx) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if (CENB_int === 1'b0) begin
      mux_address = (AB_int & 2'b11);
      row_address = (AB_int >> 2);
      if (row_address > 511)
        row = {320{1'bx}};
      else
        row = mem[row_address];
      writeEnable = ~{80{WENB_int}};
      if (WENB_int !== 1'b1) begin
        row_mask =  ( {3'b000, writeEnable[79], 3'b000, writeEnable[78], 3'b000, writeEnable[77],
          3'b000, writeEnable[76], 3'b000, writeEnable[75], 3'b000, writeEnable[74],
          3'b000, writeEnable[73], 3'b000, writeEnable[72], 3'b000, writeEnable[71],
          3'b000, writeEnable[70], 3'b000, writeEnable[69], 3'b000, writeEnable[68],
          3'b000, writeEnable[67], 3'b000, writeEnable[66], 3'b000, writeEnable[65],
          3'b000, writeEnable[64], 3'b000, writeEnable[63], 3'b000, writeEnable[62],
          3'b000, writeEnable[61], 3'b000, writeEnable[60], 3'b000, writeEnable[59],
          3'b000, writeEnable[58], 3'b000, writeEnable[57], 3'b000, writeEnable[56],
          3'b000, writeEnable[55], 3'b000, writeEnable[54], 3'b000, writeEnable[53],
          3'b000, writeEnable[52], 3'b000, writeEnable[51], 3'b000, writeEnable[50],
          3'b000, writeEnable[49], 3'b000, writeEnable[48], 3'b000, writeEnable[47],
          3'b000, writeEnable[46], 3'b000, writeEnable[45], 3'b000, writeEnable[44],
          3'b000, writeEnable[43], 3'b000, writeEnable[42], 3'b000, writeEnable[41],
          3'b000, writeEnable[40], 3'b000, writeEnable[39], 3'b000, writeEnable[38],
          3'b000, writeEnable[37], 3'b000, writeEnable[36], 3'b000, writeEnable[35],
          3'b000, writeEnable[34], 3'b000, writeEnable[33], 3'b000, writeEnable[32],
          3'b000, writeEnable[31], 3'b000, writeEnable[30], 3'b000, writeEnable[29],
          3'b000, writeEnable[28], 3'b000, writeEnable[27], 3'b000, writeEnable[26],
          3'b000, writeEnable[25], 3'b000, writeEnable[24], 3'b000, writeEnable[23],
          3'b000, writeEnable[22], 3'b000, writeEnable[21], 3'b000, writeEnable[20],
          3'b000, writeEnable[19], 3'b000, writeEnable[18], 3'b000, writeEnable[17],
          3'b000, writeEnable[16], 3'b000, writeEnable[15], 3'b000, writeEnable[14],
          3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DB_int[79], 3'b000, DB_int[78], 3'b000, DB_int[77],
          3'b000, DB_int[76], 3'b000, DB_int[75], 3'b000, DB_int[74], 3'b000, DB_int[73],
          3'b000, DB_int[72], 3'b000, DB_int[71], 3'b000, DB_int[70], 3'b000, DB_int[69],
          3'b000, DB_int[68], 3'b000, DB_int[67], 3'b000, DB_int[66], 3'b000, DB_int[65],
          3'b000, DB_int[64], 3'b000, DB_int[63], 3'b000, DB_int[62], 3'b000, DB_int[61],
          3'b000, DB_int[60], 3'b000, DB_int[59], 3'b000, DB_int[58], 3'b000, DB_int[57],
          3'b000, DB_int[56], 3'b000, DB_int[55], 3'b000, DB_int[54], 3'b000, DB_int[53],
          3'b000, DB_int[52], 3'b000, DB_int[51], 3'b000, DB_int[50], 3'b000, DB_int[49],
          3'b000, DB_int[48], 3'b000, DB_int[47], 3'b000, DB_int[46], 3'b000, DB_int[45],
          3'b000, DB_int[44], 3'b000, DB_int[43], 3'b000, DB_int[42], 3'b000, DB_int[41],
          3'b000, DB_int[40], 3'b000, DB_int[39], 3'b000, DB_int[38], 3'b000, DB_int[37],
          3'b000, DB_int[36], 3'b000, DB_int[35], 3'b000, DB_int[34], 3'b000, DB_int[33],
          3'b000, DB_int[32], 3'b000, DB_int[31], 3'b000, DB_int[30], 3'b000, DB_int[29],
          3'b000, DB_int[28], 3'b000, DB_int[27], 3'b000, DB_int[26], 3'b000, DB_int[25],
          3'b000, DB_int[24], 3'b000, DB_int[23], 3'b000, DB_int[22], 3'b000, DB_int[21],
          3'b000, DB_int[20], 3'b000, DB_int[19], 3'b000, DB_int[18], 3'b000, DB_int[17],
          3'b000, DB_int[16], 3'b000, DB_int[15], 3'b000, DB_int[14], 3'b000, DB_int[13],
          3'b000, DB_int[12], 3'b000, DB_int[11], 3'b000, DB_int[10], 3'b000, DB_int[9],
          3'b000, DB_int[8], 3'b000, DB_int[7], 3'b000, DB_int[6], 3'b000, DB_int[5],
          3'b000, DB_int[4], 3'b000, DB_int[3], 3'b000, DB_int[2], 3'b000, DB_int[1],
          3'b000, DB_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch1 = {data_out[316], data_out[312], data_out[308], data_out[304], data_out[300],
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
      shifted_readLatch1 = readLatch1;
      QB_int = {shifted_readLatch1[79], shifted_readLatch1[78], shifted_readLatch1[77],
        shifted_readLatch1[76], shifted_readLatch1[75], shifted_readLatch1[74], shifted_readLatch1[73],
        shifted_readLatch1[72], shifted_readLatch1[71], shifted_readLatch1[70], shifted_readLatch1[69],
        shifted_readLatch1[68], shifted_readLatch1[67], shifted_readLatch1[66], shifted_readLatch1[65],
        shifted_readLatch1[64], shifted_readLatch1[63], shifted_readLatch1[62], shifted_readLatch1[61],
        shifted_readLatch1[60], shifted_readLatch1[59], shifted_readLatch1[58], shifted_readLatch1[57],
        shifted_readLatch1[56], shifted_readLatch1[55], shifted_readLatch1[54], shifted_readLatch1[53],
        shifted_readLatch1[52], shifted_readLatch1[51], shifted_readLatch1[50], shifted_readLatch1[49],
        shifted_readLatch1[48], shifted_readLatch1[47], shifted_readLatch1[46], shifted_readLatch1[45],
        shifted_readLatch1[44], shifted_readLatch1[43], shifted_readLatch1[42], shifted_readLatch1[41],
        shifted_readLatch1[40], shifted_readLatch1[39], shifted_readLatch1[38], shifted_readLatch1[37],
        shifted_readLatch1[36], shifted_readLatch1[35], shifted_readLatch1[34], shifted_readLatch1[33],
        shifted_readLatch1[32], shifted_readLatch1[31], shifted_readLatch1[30], shifted_readLatch1[29],
        shifted_readLatch1[28], shifted_readLatch1[27], shifted_readLatch1[26], shifted_readLatch1[25],
        shifted_readLatch1[24], shifted_readLatch1[23], shifted_readLatch1[22], shifted_readLatch1[21],
        shifted_readLatch1[20], shifted_readLatch1[19], shifted_readLatch1[18], shifted_readLatch1[17],
        shifted_readLatch1[16], shifted_readLatch1[15], shifted_readLatch1[14], shifted_readLatch1[13],
        shifted_readLatch1[12], shifted_readLatch1[11], shifted_readLatch1[10], shifted_readLatch1[9],
        shifted_readLatch1[8], shifted_readLatch1[7], shifted_readLatch1[6], shifted_readLatch1[5],
        shifted_readLatch1[4], shifted_readLatch1[3], shifted_readLatch1[2], shifted_readLatch1[1],
        shifted_readLatch1[0]};
      end
    end
  end
  endtask
  always @ (CENB_ or TCENB_ or TENB_ or CLKB_) begin
  	if(CLKB_ == 1'b0) begin
  		CENB_p2 = CENB_;
  		TCENB_p2 = TCENB_;
  	end
  end

  always @ RET1N_ begin
    if (CLKB_ == 1'b1) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CENB_p2 === 1'b0 || TCENB_p2 === 1'b0) ) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CENB_p2 === 1'b0 || TCENB_p2 === 1'b0) ) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end
    if (RET1N_ == 1'b0) begin
      QB_int = {80{1'bx}};
      QB_int_delayed = {80{1'bx}};
      CENB_int = 1'bx;
      WENB_int = 1'bx;
      AB_int = {11{1'bx}};
      DB_int = {80{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      BENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = 1'bx;
      TAB_int = {11{1'bx}};
      TDB_int = {80{1'bx}};
      TQB_int = {80{1'bx}};
      RET1N_int = 1'bx;
      STOVB_int = 1'bx;
      COLLDISN_int = 1'bx;
    end else begin
      QB_int = {80{1'bx}};
      QB_int_delayed = {80{1'bx}};
      CENB_int = 1'bx;
      WENB_int = 1'bx;
      AB_int = {11{1'bx}};
      DB_int = {80{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      BENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = 1'bx;
      TAB_int = {11{1'bx}};
      TDB_int = {80{1'bx}};
      TQB_int = {80{1'bx}};
      RET1N_int = 1'bx;
      STOVB_int = 1'bx;
      COLLDISN_int = 1'bx;
    end
    RET1N_int = RET1N_;
  end


  always @ CLKB_ begin
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
    if ((CLKB_ === 1'bx || CLKB_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(1);
      QB_int = {80{1'bx}};
    end else if (CLKB_ === 1'b1 && LAST_CLKB === 1'b0) begin
      CENB_int = TENB_ ? CENB_ : TCENB_;
      EMAB_int = EMAB_;
      EMAWB_int = EMAWB_;
      EMASB_int = EMASB_;
      TENB_int = TENB_;
      BENB_int = BENB_;
      TWENB_int = TWENB_;
      TQB_int = TQB_;
      RET1N_int = RET1N_;
      STOVB_int = STOVB_;
      COLLDISN_int = COLLDISN_;
      if (CENB_int != 1'b1) begin
        WENB_int = TENB_ ? WENB_ : TWENB_;
        AB_int = TENB_ ? AB_ : TAB_;
        DB_int = TENB_ ? DB_ : TDB_;
        TCENB_int = TCENB_;
        TAB_int = TAB_;
        TDB_int = TDB_;
      end
      clk1_int = 1'b0;
      if (CENB_int === 1'b0 && WENB_int === 1'b1) 
         QB_int_delayed = {80{1'bx}};
      if (CENB_int === 1'b0) previous_CLKB = $realtime;
    readWriteB;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && COLLDISN_int === 1'b1 && row_contention(AA_int, AB_int,  WENA_int, WENB_int)) 
       begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          DA_int = {80{1'bx}};
          readWriteA;
          DB_int = {80{1'bx}};
          readWriteB;
	      end
        end else if (WENA_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QB_int = {80{1'bx}};
		end
        end else if (WENB_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QA_int = {80{1'bx}};
		end
        end else begin
          readWriteA;
          readWriteB;
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_READ = 1;
        end
		if (!is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          readWriteA;
          readWriteB;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE = 1;
        end else if (!(WENA_int !== 1'b1) && (WENB_int !== 1'b1)) begin
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else if ((WENA_int !== 1'b1) && !(WENB_int !== 1'b1)) begin
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else begin
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
        end
        end
      end else if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && (COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx)  && row_contention(AA_int,
        AB_int,  WENA_int, WENB_int)) begin
          $display("%s row contention: in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (WENA_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DA_int = {80{1'bx}};
          readWriteA;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
          QA_int = {80{1'bx}};
        end else begin
          readWriteA;
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_READ_1 = 1;
          READ_WRITE_1 = 1;
        end
        if (WENB_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DB_int = {80{1'bx}};
          readWriteB;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          QB_int = {80{1'bx}};
        end else begin
          readWriteB;
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (CLKB_ === 1'b0 && LAST_CLKB === 1'b1) begin
      QB_int_delayed = QB_int;
    end
    LAST_CLKB = CLKB_;
  end
  end

  reg globalNotifier1;
  initial globalNotifier1 = 1'b0;

  always @ globalNotifier1 begin
    if ($realtime == 0) begin
    end else if (CENB_int === 1'bx || EMAB_int[0] === 1'bx || EMAB_int[1] === 1'bx || 
      EMAB_int[2] === 1'bx || EMASB_int === 1'bx || EMAWB_int[0] === 1'bx || EMAWB_int[1] === 1'bx || 
      RET1N_int === 1'bx || (STOVB_int && !CENB_int) === 1'bx || TENB_int === 1'bx || 
      clk1_int === 1'bx) begin
      QB_int = {80{1'bx}};
      failedWrite(1);
    end else if  (cont_flag1_int === 1'bx && COLLDISN_int === 1'b1 &&  (CENB_int !== 
     1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1)) && row_contention(TENA_ ? AA_ : 
     TAA_, AB_int,  WENB_int, TENA_ ? WENA_ : TWENA_)) begin
      cont_flag1_int = 1'b0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          DA_int = {80{1'bx}};
          readWriteA;
          DB_int = {80{1'bx}};
          readWriteB;
	      end
        end else if (WENA_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QB_int = {80{1'bx}};
		end
        end else if (WENB_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QA_int = {80{1'bx}};
		end
        end else begin
          readWriteA;
          readWriteB;
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_READ = 1;
        end
		if (!is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          readWriteA;
          readWriteB;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE = 1;
        end else if (!(WENA_int !== 1'b1) && (WENB_int !== 1'b1)) begin
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else if ((WENA_int !== 1'b1) && !(WENB_int !== 1'b1)) begin
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else begin
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
        end
        end
    end else if  ((CENB_int !== 1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1)) && cont_flag1_int 
     === 1'bx && (COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENA_ 
     ? AA_ : TAA_, AB_int,  WENB_int, TENA_ ? WENA_ : TWENA_)) begin
      cont_flag1_int = 1'b0;
          $display("%s row contention: in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (WENA_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DA_int = {80{1'bx}};
          readWriteA;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
          QA_int = {80{1'bx}};
        end else begin
          readWriteA;
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_READ_1 = 1;
          READ_WRITE_1 = 1;
        end
        if (WENB_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DB_int = {80{1'bx}};
          readWriteB;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          QB_int = {80{1'bx}};
        end else begin
          readWriteB;
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
    end else begin
      readWriteB;
   end
    globalNotifier1 = 1'b0;
  end

  function row_contention;
    input [10:0] aa;
    input [10:0] ab;
    input  wena;
    input  wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) === 1'b1 && (& wenb) === 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[1:0] == ab[1:0]) ? 1'b1 : 1'b0;
    if (aa[10:2] == ab[10:2]) begin
      sameRow = 1'b1;
    end else begin
      sameRow = 1'b0;
    end
    if (sameRow == 1'b1 && anyWrite == 1'b1)
      row_contention = 1'b1;
    else if (sameRow == 1'b1 && sameMux == 1'b1)
      row_contention = 1'b1;
    else
      row_contention = 1'b0;
  end
  endfunction

  function col_contention;
    input [10:0] aa;
    input [10:0] ab;
  begin
    if (aa[1:0] == ab[1:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [10:0] aa;
    input [10:0] ab;
    input  wena;
    input  wenb;
    reg result;
  begin
    if ((& wena) === 1'b1 && (& wenb) === 1'b1) begin
      result = 1'b0;
    end else if (aa == ab) begin
      result = 1'b1;
    end else begin
      result = 1'b0;
    end
    is_contention = result;
  end
  endfunction

   wire contA_flag = (CENA_int !== 1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1)) && ((COLLDISN_int === 1'b1 && is_contention(TENB_ ? AB_ : TAB_, AA_int,  TENB_ ? WENB_ : TWENB_, WENA_int)) ||
              ((COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENB_ ? AB_ : TAB_, AA_int,  TENB_ ? WENB_ : TWENB_, WENA_int)));
   wire contB_flag = (CENB_int !== 1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1)) && ((COLLDISN_int === 1'b1 && is_contention(TENA_ ? AA_ : TAA_, AB_int,  TENA_ ? WENA_ : TWENA_, WENB_int)) ||
              ((COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENA_ ? AA_ : TAA_, AB_int,  TENA_ ? WENA_ : TWENA_, WENB_int)));

  always @ NOT_CENA begin
    CENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA begin
    WENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA10 begin
    AA_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA9 begin
    AA_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA8 begin
    AA_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA7 begin
    AA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA6 begin
    AA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA5 begin
    AA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA4 begin
    AA_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA3 begin
    AA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA2 begin
    AA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA1 begin
    AA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA0 begin
    AA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA79 begin
    DA_int[79] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA78 begin
    DA_int[78] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA77 begin
    DA_int[77] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA76 begin
    DA_int[76] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA75 begin
    DA_int[75] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA74 begin
    DA_int[74] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA73 begin
    DA_int[73] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA72 begin
    DA_int[72] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA71 begin
    DA_int[71] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA70 begin
    DA_int[70] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA69 begin
    DA_int[69] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA68 begin
    DA_int[68] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA67 begin
    DA_int[67] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA66 begin
    DA_int[66] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA65 begin
    DA_int[65] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA64 begin
    DA_int[64] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA63 begin
    DA_int[63] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA62 begin
    DA_int[62] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA61 begin
    DA_int[61] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA60 begin
    DA_int[60] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA59 begin
    DA_int[59] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA58 begin
    DA_int[58] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA57 begin
    DA_int[57] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA56 begin
    DA_int[56] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA55 begin
    DA_int[55] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA54 begin
    DA_int[54] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA53 begin
    DA_int[53] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA52 begin
    DA_int[52] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA51 begin
    DA_int[51] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA50 begin
    DA_int[50] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA49 begin
    DA_int[49] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA48 begin
    DA_int[48] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA47 begin
    DA_int[47] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA46 begin
    DA_int[46] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA45 begin
    DA_int[45] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA44 begin
    DA_int[44] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA43 begin
    DA_int[43] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA42 begin
    DA_int[42] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA41 begin
    DA_int[41] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA40 begin
    DA_int[40] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA39 begin
    DA_int[39] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA38 begin
    DA_int[38] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA37 begin
    DA_int[37] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA36 begin
    DA_int[36] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA35 begin
    DA_int[35] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA34 begin
    DA_int[34] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA33 begin
    DA_int[33] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA32 begin
    DA_int[32] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA31 begin
    DA_int[31] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA30 begin
    DA_int[30] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA29 begin
    DA_int[29] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA28 begin
    DA_int[28] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA27 begin
    DA_int[27] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA26 begin
    DA_int[26] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA25 begin
    DA_int[25] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA24 begin
    DA_int[24] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA23 begin
    DA_int[23] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA22 begin
    DA_int[22] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA21 begin
    DA_int[21] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA20 begin
    DA_int[20] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA19 begin
    DA_int[19] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA18 begin
    DA_int[18] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA17 begin
    DA_int[17] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA16 begin
    DA_int[16] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA15 begin
    DA_int[15] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA14 begin
    DA_int[14] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA13 begin
    DA_int[13] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA12 begin
    DA_int[12] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA11 begin
    DA_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA10 begin
    DA_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA9 begin
    DA_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA8 begin
    DA_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA7 begin
    DA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA6 begin
    DA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA5 begin
    DA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA4 begin
    DA_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA3 begin
    DA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA2 begin
    DA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA1 begin
    DA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA0 begin
    DA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CENB begin
    CENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB begin
    WENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB10 begin
    AB_int[10] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB9 begin
    AB_int[9] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB8 begin
    AB_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB7 begin
    AB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB6 begin
    AB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB5 begin
    AB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB4 begin
    AB_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB3 begin
    AB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB2 begin
    AB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB1 begin
    AB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB0 begin
    AB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB79 begin
    DB_int[79] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB78 begin
    DB_int[78] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB77 begin
    DB_int[77] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB76 begin
    DB_int[76] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB75 begin
    DB_int[75] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB74 begin
    DB_int[74] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB73 begin
    DB_int[73] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB72 begin
    DB_int[72] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB71 begin
    DB_int[71] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB70 begin
    DB_int[70] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB69 begin
    DB_int[69] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB68 begin
    DB_int[68] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB67 begin
    DB_int[67] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB66 begin
    DB_int[66] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB65 begin
    DB_int[65] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB64 begin
    DB_int[64] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB63 begin
    DB_int[63] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB62 begin
    DB_int[62] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB61 begin
    DB_int[61] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB60 begin
    DB_int[60] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB59 begin
    DB_int[59] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB58 begin
    DB_int[58] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB57 begin
    DB_int[57] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB56 begin
    DB_int[56] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB55 begin
    DB_int[55] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB54 begin
    DB_int[54] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB53 begin
    DB_int[53] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB52 begin
    DB_int[52] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB51 begin
    DB_int[51] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB50 begin
    DB_int[50] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB49 begin
    DB_int[49] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB48 begin
    DB_int[48] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB47 begin
    DB_int[47] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB46 begin
    DB_int[46] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB45 begin
    DB_int[45] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB44 begin
    DB_int[44] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB43 begin
    DB_int[43] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB42 begin
    DB_int[42] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB41 begin
    DB_int[41] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB40 begin
    DB_int[40] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB39 begin
    DB_int[39] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB38 begin
    DB_int[38] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB37 begin
    DB_int[37] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB36 begin
    DB_int[36] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB35 begin
    DB_int[35] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB34 begin
    DB_int[34] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB33 begin
    DB_int[33] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB32 begin
    DB_int[32] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB31 begin
    DB_int[31] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB30 begin
    DB_int[30] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB29 begin
    DB_int[29] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB28 begin
    DB_int[28] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB27 begin
    DB_int[27] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB26 begin
    DB_int[26] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB25 begin
    DB_int[25] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB24 begin
    DB_int[24] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB23 begin
    DB_int[23] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB22 begin
    DB_int[22] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB21 begin
    DB_int[21] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB20 begin
    DB_int[20] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB19 begin
    DB_int[19] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB18 begin
    DB_int[18] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB17 begin
    DB_int[17] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB16 begin
    DB_int[16] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB15 begin
    DB_int[15] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB14 begin
    DB_int[14] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB13 begin
    DB_int[13] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB12 begin
    DB_int[12] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB11 begin
    DB_int[11] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB10 begin
    DB_int[10] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB9 begin
    DB_int[9] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB8 begin
    DB_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB7 begin
    DB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB6 begin
    DB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB5 begin
    DB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB4 begin
    DB_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB3 begin
    DB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB2 begin
    DB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB1 begin
    DB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB0 begin
    DB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAA2 begin
    EMAA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAA1 begin
    EMAA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAA0 begin
    EMAA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAWA1 begin
    EMAWA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAWA0 begin
    EMAWA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMASA begin
    EMASA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAB2 begin
    EMAB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAB1 begin
    EMAB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAB0 begin
    EMAB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAWB1 begin
    EMAWB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAWB0 begin
    EMAWB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMASB begin
    EMASB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TENA begin
    TENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TCENA begin
    CENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA begin
    WENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA10 begin
    AA_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA9 begin
    AA_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA8 begin
    AA_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA7 begin
    AA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA6 begin
    AA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA5 begin
    AA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA4 begin
    AA_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA3 begin
    AA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA2 begin
    AA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA1 begin
    AA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA0 begin
    AA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA79 begin
    DA_int[79] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA78 begin
    DA_int[78] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA77 begin
    DA_int[77] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA76 begin
    DA_int[76] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA75 begin
    DA_int[75] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA74 begin
    DA_int[74] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA73 begin
    DA_int[73] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA72 begin
    DA_int[72] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA71 begin
    DA_int[71] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA70 begin
    DA_int[70] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA69 begin
    DA_int[69] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA68 begin
    DA_int[68] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA67 begin
    DA_int[67] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA66 begin
    DA_int[66] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA65 begin
    DA_int[65] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA64 begin
    DA_int[64] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA63 begin
    DA_int[63] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA62 begin
    DA_int[62] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA61 begin
    DA_int[61] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA60 begin
    DA_int[60] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA59 begin
    DA_int[59] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA58 begin
    DA_int[58] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA57 begin
    DA_int[57] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA56 begin
    DA_int[56] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA55 begin
    DA_int[55] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA54 begin
    DA_int[54] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA53 begin
    DA_int[53] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA52 begin
    DA_int[52] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA51 begin
    DA_int[51] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA50 begin
    DA_int[50] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA49 begin
    DA_int[49] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA48 begin
    DA_int[48] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA47 begin
    DA_int[47] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA46 begin
    DA_int[46] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA45 begin
    DA_int[45] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA44 begin
    DA_int[44] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA43 begin
    DA_int[43] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA42 begin
    DA_int[42] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA41 begin
    DA_int[41] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA40 begin
    DA_int[40] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA39 begin
    DA_int[39] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA38 begin
    DA_int[38] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA37 begin
    DA_int[37] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA36 begin
    DA_int[36] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA35 begin
    DA_int[35] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA34 begin
    DA_int[34] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA33 begin
    DA_int[33] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA32 begin
    DA_int[32] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA31 begin
    DA_int[31] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA30 begin
    DA_int[30] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA29 begin
    DA_int[29] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA28 begin
    DA_int[28] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA27 begin
    DA_int[27] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA26 begin
    DA_int[26] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA25 begin
    DA_int[25] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA24 begin
    DA_int[24] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA23 begin
    DA_int[23] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA22 begin
    DA_int[22] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA21 begin
    DA_int[21] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA20 begin
    DA_int[20] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA19 begin
    DA_int[19] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA18 begin
    DA_int[18] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA17 begin
    DA_int[17] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA16 begin
    DA_int[16] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA15 begin
    DA_int[15] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA14 begin
    DA_int[14] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA13 begin
    DA_int[13] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA12 begin
    DA_int[12] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA11 begin
    DA_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA10 begin
    DA_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA9 begin
    DA_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA8 begin
    DA_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA7 begin
    DA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA6 begin
    DA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA5 begin
    DA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA4 begin
    DA_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA3 begin
    DA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA2 begin
    DA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA1 begin
    DA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA0 begin
    DA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TENB begin
    TENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TCENB begin
    CENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB begin
    WENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB10 begin
    AB_int[10] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB9 begin
    AB_int[9] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB8 begin
    AB_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB7 begin
    AB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB6 begin
    AB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB5 begin
    AB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB4 begin
    AB_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB3 begin
    AB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB2 begin
    AB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB1 begin
    AB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB0 begin
    AB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB79 begin
    DB_int[79] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB78 begin
    DB_int[78] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB77 begin
    DB_int[77] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB76 begin
    DB_int[76] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB75 begin
    DB_int[75] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB74 begin
    DB_int[74] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB73 begin
    DB_int[73] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB72 begin
    DB_int[72] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB71 begin
    DB_int[71] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB70 begin
    DB_int[70] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB69 begin
    DB_int[69] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB68 begin
    DB_int[68] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB67 begin
    DB_int[67] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB66 begin
    DB_int[66] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB65 begin
    DB_int[65] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB64 begin
    DB_int[64] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB63 begin
    DB_int[63] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB62 begin
    DB_int[62] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB61 begin
    DB_int[61] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB60 begin
    DB_int[60] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB59 begin
    DB_int[59] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB58 begin
    DB_int[58] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB57 begin
    DB_int[57] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB56 begin
    DB_int[56] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB55 begin
    DB_int[55] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB54 begin
    DB_int[54] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB53 begin
    DB_int[53] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB52 begin
    DB_int[52] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB51 begin
    DB_int[51] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB50 begin
    DB_int[50] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB49 begin
    DB_int[49] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB48 begin
    DB_int[48] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB47 begin
    DB_int[47] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB46 begin
    DB_int[46] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB45 begin
    DB_int[45] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB44 begin
    DB_int[44] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB43 begin
    DB_int[43] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB42 begin
    DB_int[42] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB41 begin
    DB_int[41] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB40 begin
    DB_int[40] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB39 begin
    DB_int[39] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB38 begin
    DB_int[38] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB37 begin
    DB_int[37] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB36 begin
    DB_int[36] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB35 begin
    DB_int[35] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB34 begin
    DB_int[34] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB33 begin
    DB_int[33] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB32 begin
    DB_int[32] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB31 begin
    DB_int[31] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB30 begin
    DB_int[30] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB29 begin
    DB_int[29] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB28 begin
    DB_int[28] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB27 begin
    DB_int[27] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB26 begin
    DB_int[26] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB25 begin
    DB_int[25] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB24 begin
    DB_int[24] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB23 begin
    DB_int[23] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB22 begin
    DB_int[22] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB21 begin
    DB_int[21] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB20 begin
    DB_int[20] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB19 begin
    DB_int[19] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB18 begin
    DB_int[18] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB17 begin
    DB_int[17] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB16 begin
    DB_int[16] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB15 begin
    DB_int[15] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB14 begin
    DB_int[14] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB13 begin
    DB_int[13] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB12 begin
    DB_int[12] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB11 begin
    DB_int[11] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB10 begin
    DB_int[10] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB9 begin
    DB_int[9] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB8 begin
    DB_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB7 begin
    DB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB6 begin
    DB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB5 begin
    DB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB4 begin
    DB_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB3 begin
    DB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB2 begin
    DB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB1 begin
    DB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB0 begin
    DB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_RET1N begin
    RET1N_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_STOVA begin
    STOVA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_STOVB begin
    STOVB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_COLLDISN begin
    COLLDISN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end

  always @ NOT_CONTA begin
    cont_flag0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_PER begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_MINH begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_MINL begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CONTB begin
    cont_flag1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_PER begin
    clk1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_MINH begin
    clk1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_MINL begin
    clk1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end


  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire opopTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cpcpandopopTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cpcp;
  wire opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp;
  wire opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp;

  wire STOVAeq0, STOVAeq1andEMASAeq0, STOVAeq1andEMASAeq1, TENAeq1, TENAeq1andCENAeq0;
  wire TENAeq1andCENAeq0andWENAeq0, STOVBeq0, STOVBeq1andEMASBeq0, STOVBeq1andEMASBeq1;
  wire TENBeq1, TENBeq1andCENBeq0, TENBeq1andCENBeq0andWENBeq0, TENAeq0, TENAeq0andTCENAeq0;
  wire TENAeq0andTCENAeq0andTWENAeq0, TENBeq0, TENBeq0andTCENBeq0, TENBeq0andTCENBeq0andTWENBeq0;

  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (STOVA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (STOVA) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (STOVA) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (STOVA) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (STOVA) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq1andEMASAeq0 = 
         (STOVA) && (!EMASA) && !(TENA ? CENA : TCENA);
  assign STOVAeq1andEMASAeq1 = 
         (STOVA) && (EMASA) && !(TENA ? CENA : TCENA);
  assign TENAeq1andCENAeq0 = 
         !(!TENA || CENA);
  assign TENAeq1andCENAeq0andWENAeq0 = 
         !(!TENA ||  CENA || WENA);
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (STOVB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (STOVB) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (STOVB) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (STOVB) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (STOVB) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq1andEMASBeq0 = 
         (STOVB) && (!EMASB) && !(TENB ? CENB : TCENB);
  assign STOVBeq1andEMASBeq1 = 
         (STOVB) && (EMASB) && !(TENB ? CENB : TCENB);
  assign TENBeq1andCENBeq0 = 
         !(!TENB || CENB);
  assign TENBeq1andCENBeq0andWENBeq0 = 
         !(!TENB ||  CENB || WENB);
  assign TENAeq0andTCENAeq0 = 
         !(TENA || TCENA);
  assign TENAeq0andTCENAeq0andTWENAeq0 = 
         !(TENA ||  TCENA || TWENA);
  assign TENBeq0andTCENBeq0 = 
         !(TENB || TCENB);
  assign TENBeq0andTCENBeq0andTWENBeq0 = 
         !(TENB ||  TCENB || TWENB);
  assign opopTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cpcpandopopTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cpcp = 
         ((TENA ? CENA : TCENA) && (TENB ? CENB : TCENB));
  assign opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp = 
         !(TENA ? CENA : TCENA);
  assign opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp = 
         !(TENB ? CENB : TCENB);

  assign STOVAeq0 = (!STOVA) && !(TENA ? CENA : TCENA);
  assign TENAeq1 = TENA;
  assign STOVBeq0 = (!STOVB) && !(TENB ? CENB : TCENB);
  assign TENBeq1 = TENB;
  assign TENAeq0 = !TENA;
  assign TENBeq0 = !TENB;

  specify
    if (CENA == 1'b0 && TCENA == 1'b1)
       (TENA => CENYA) = (1.000, 1.000);
    if (CENA == 1'b1 && TCENA == 1'b0)
       (TENA => CENYA) = (1.000, 1.000);
    if (TENA == 1'b1)
       (CENA => CENYA) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TCENA => CENYA) = (1.000, 1.000);
    if (WENA == 1'b0 && TWENA == 1'b1)
       (TENA => WENYA) = (1.000, 1.000);
    if (WENA == 1'b1 && TWENA == 1'b0)
       (TENA => WENYA) = (1.000, 1.000);
    if (TENA == 1'b1)
       (WENA => WENYA) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TWENA => WENYA) = (1.000, 1.000);
    if (AA[10] == 1'b0 && TAA[10] == 1'b1)
       (TENA => AYA[10]) = (1.000, 1.000);
    if (AA[10] == 1'b1 && TAA[10] == 1'b0)
       (TENA => AYA[10]) = (1.000, 1.000);
    if (AA[9] == 1'b0 && TAA[9] == 1'b1)
       (TENA => AYA[9]) = (1.000, 1.000);
    if (AA[9] == 1'b1 && TAA[9] == 1'b0)
       (TENA => AYA[9]) = (1.000, 1.000);
    if (AA[8] == 1'b0 && TAA[8] == 1'b1)
       (TENA => AYA[8]) = (1.000, 1.000);
    if (AA[8] == 1'b1 && TAA[8] == 1'b0)
       (TENA => AYA[8]) = (1.000, 1.000);
    if (AA[7] == 1'b0 && TAA[7] == 1'b1)
       (TENA => AYA[7]) = (1.000, 1.000);
    if (AA[7] == 1'b1 && TAA[7] == 1'b0)
       (TENA => AYA[7]) = (1.000, 1.000);
    if (AA[6] == 1'b0 && TAA[6] == 1'b1)
       (TENA => AYA[6]) = (1.000, 1.000);
    if (AA[6] == 1'b1 && TAA[6] == 1'b0)
       (TENA => AYA[6]) = (1.000, 1.000);
    if (AA[5] == 1'b0 && TAA[5] == 1'b1)
       (TENA => AYA[5]) = (1.000, 1.000);
    if (AA[5] == 1'b1 && TAA[5] == 1'b0)
       (TENA => AYA[5]) = (1.000, 1.000);
    if (AA[4] == 1'b0 && TAA[4] == 1'b1)
       (TENA => AYA[4]) = (1.000, 1.000);
    if (AA[4] == 1'b1 && TAA[4] == 1'b0)
       (TENA => AYA[4]) = (1.000, 1.000);
    if (AA[3] == 1'b0 && TAA[3] == 1'b1)
       (TENA => AYA[3]) = (1.000, 1.000);
    if (AA[3] == 1'b1 && TAA[3] == 1'b0)
       (TENA => AYA[3]) = (1.000, 1.000);
    if (AA[2] == 1'b0 && TAA[2] == 1'b1)
       (TENA => AYA[2]) = (1.000, 1.000);
    if (AA[2] == 1'b1 && TAA[2] == 1'b0)
       (TENA => AYA[2]) = (1.000, 1.000);
    if (AA[1] == 1'b0 && TAA[1] == 1'b1)
       (TENA => AYA[1]) = (1.000, 1.000);
    if (AA[1] == 1'b1 && TAA[1] == 1'b0)
       (TENA => AYA[1]) = (1.000, 1.000);
    if (AA[0] == 1'b0 && TAA[0] == 1'b1)
       (TENA => AYA[0]) = (1.000, 1.000);
    if (AA[0] == 1'b1 && TAA[0] == 1'b0)
       (TENA => AYA[0]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[10] => AYA[10]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[9] => AYA[9]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[8] => AYA[8]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[7] => AYA[7]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[6] => AYA[6]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[5] => AYA[5]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[4] => AYA[4]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[3] => AYA[3]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[2] => AYA[2]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[1] => AYA[1]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[0] => AYA[0]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[10] => AYA[10]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[9] => AYA[9]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[8] => AYA[8]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[7] => AYA[7]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[6] => AYA[6]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[5] => AYA[5]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[4] => AYA[4]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[3] => AYA[3]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[2] => AYA[2]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[1] => AYA[1]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[0] => AYA[0]) = (1.000, 1.000);
    if (DA[79] == 1'b0 && TDA[79] == 1'b1)
       (TENA => DYA[79]) = (1.000, 1.000);
    if (DA[79] == 1'b1 && TDA[79] == 1'b0)
       (TENA => DYA[79]) = (1.000, 1.000);
    if (DA[78] == 1'b0 && TDA[78] == 1'b1)
       (TENA => DYA[78]) = (1.000, 1.000);
    if (DA[78] == 1'b1 && TDA[78] == 1'b0)
       (TENA => DYA[78]) = (1.000, 1.000);
    if (DA[77] == 1'b0 && TDA[77] == 1'b1)
       (TENA => DYA[77]) = (1.000, 1.000);
    if (DA[77] == 1'b1 && TDA[77] == 1'b0)
       (TENA => DYA[77]) = (1.000, 1.000);
    if (DA[76] == 1'b0 && TDA[76] == 1'b1)
       (TENA => DYA[76]) = (1.000, 1.000);
    if (DA[76] == 1'b1 && TDA[76] == 1'b0)
       (TENA => DYA[76]) = (1.000, 1.000);
    if (DA[75] == 1'b0 && TDA[75] == 1'b1)
       (TENA => DYA[75]) = (1.000, 1.000);
    if (DA[75] == 1'b1 && TDA[75] == 1'b0)
       (TENA => DYA[75]) = (1.000, 1.000);
    if (DA[74] == 1'b0 && TDA[74] == 1'b1)
       (TENA => DYA[74]) = (1.000, 1.000);
    if (DA[74] == 1'b1 && TDA[74] == 1'b0)
       (TENA => DYA[74]) = (1.000, 1.000);
    if (DA[73] == 1'b0 && TDA[73] == 1'b1)
       (TENA => DYA[73]) = (1.000, 1.000);
    if (DA[73] == 1'b1 && TDA[73] == 1'b0)
       (TENA => DYA[73]) = (1.000, 1.000);
    if (DA[72] == 1'b0 && TDA[72] == 1'b1)
       (TENA => DYA[72]) = (1.000, 1.000);
    if (DA[72] == 1'b1 && TDA[72] == 1'b0)
       (TENA => DYA[72]) = (1.000, 1.000);
    if (DA[71] == 1'b0 && TDA[71] == 1'b1)
       (TENA => DYA[71]) = (1.000, 1.000);
    if (DA[71] == 1'b1 && TDA[71] == 1'b0)
       (TENA => DYA[71]) = (1.000, 1.000);
    if (DA[70] == 1'b0 && TDA[70] == 1'b1)
       (TENA => DYA[70]) = (1.000, 1.000);
    if (DA[70] == 1'b1 && TDA[70] == 1'b0)
       (TENA => DYA[70]) = (1.000, 1.000);
    if (DA[69] == 1'b0 && TDA[69] == 1'b1)
       (TENA => DYA[69]) = (1.000, 1.000);
    if (DA[69] == 1'b1 && TDA[69] == 1'b0)
       (TENA => DYA[69]) = (1.000, 1.000);
    if (DA[68] == 1'b0 && TDA[68] == 1'b1)
       (TENA => DYA[68]) = (1.000, 1.000);
    if (DA[68] == 1'b1 && TDA[68] == 1'b0)
       (TENA => DYA[68]) = (1.000, 1.000);
    if (DA[67] == 1'b0 && TDA[67] == 1'b1)
       (TENA => DYA[67]) = (1.000, 1.000);
    if (DA[67] == 1'b1 && TDA[67] == 1'b0)
       (TENA => DYA[67]) = (1.000, 1.000);
    if (DA[66] == 1'b0 && TDA[66] == 1'b1)
       (TENA => DYA[66]) = (1.000, 1.000);
    if (DA[66] == 1'b1 && TDA[66] == 1'b0)
       (TENA => DYA[66]) = (1.000, 1.000);
    if (DA[65] == 1'b0 && TDA[65] == 1'b1)
       (TENA => DYA[65]) = (1.000, 1.000);
    if (DA[65] == 1'b1 && TDA[65] == 1'b0)
       (TENA => DYA[65]) = (1.000, 1.000);
    if (DA[64] == 1'b0 && TDA[64] == 1'b1)
       (TENA => DYA[64]) = (1.000, 1.000);
    if (DA[64] == 1'b1 && TDA[64] == 1'b0)
       (TENA => DYA[64]) = (1.000, 1.000);
    if (DA[63] == 1'b0 && TDA[63] == 1'b1)
       (TENA => DYA[63]) = (1.000, 1.000);
    if (DA[63] == 1'b1 && TDA[63] == 1'b0)
       (TENA => DYA[63]) = (1.000, 1.000);
    if (DA[62] == 1'b0 && TDA[62] == 1'b1)
       (TENA => DYA[62]) = (1.000, 1.000);
    if (DA[62] == 1'b1 && TDA[62] == 1'b0)
       (TENA => DYA[62]) = (1.000, 1.000);
    if (DA[61] == 1'b0 && TDA[61] == 1'b1)
       (TENA => DYA[61]) = (1.000, 1.000);
    if (DA[61] == 1'b1 && TDA[61] == 1'b0)
       (TENA => DYA[61]) = (1.000, 1.000);
    if (DA[60] == 1'b0 && TDA[60] == 1'b1)
       (TENA => DYA[60]) = (1.000, 1.000);
    if (DA[60] == 1'b1 && TDA[60] == 1'b0)
       (TENA => DYA[60]) = (1.000, 1.000);
    if (DA[59] == 1'b0 && TDA[59] == 1'b1)
       (TENA => DYA[59]) = (1.000, 1.000);
    if (DA[59] == 1'b1 && TDA[59] == 1'b0)
       (TENA => DYA[59]) = (1.000, 1.000);
    if (DA[58] == 1'b0 && TDA[58] == 1'b1)
       (TENA => DYA[58]) = (1.000, 1.000);
    if (DA[58] == 1'b1 && TDA[58] == 1'b0)
       (TENA => DYA[58]) = (1.000, 1.000);
    if (DA[57] == 1'b0 && TDA[57] == 1'b1)
       (TENA => DYA[57]) = (1.000, 1.000);
    if (DA[57] == 1'b1 && TDA[57] == 1'b0)
       (TENA => DYA[57]) = (1.000, 1.000);
    if (DA[56] == 1'b0 && TDA[56] == 1'b1)
       (TENA => DYA[56]) = (1.000, 1.000);
    if (DA[56] == 1'b1 && TDA[56] == 1'b0)
       (TENA => DYA[56]) = (1.000, 1.000);
    if (DA[55] == 1'b0 && TDA[55] == 1'b1)
       (TENA => DYA[55]) = (1.000, 1.000);
    if (DA[55] == 1'b1 && TDA[55] == 1'b0)
       (TENA => DYA[55]) = (1.000, 1.000);
    if (DA[54] == 1'b0 && TDA[54] == 1'b1)
       (TENA => DYA[54]) = (1.000, 1.000);
    if (DA[54] == 1'b1 && TDA[54] == 1'b0)
       (TENA => DYA[54]) = (1.000, 1.000);
    if (DA[53] == 1'b0 && TDA[53] == 1'b1)
       (TENA => DYA[53]) = (1.000, 1.000);
    if (DA[53] == 1'b1 && TDA[53] == 1'b0)
       (TENA => DYA[53]) = (1.000, 1.000);
    if (DA[52] == 1'b0 && TDA[52] == 1'b1)
       (TENA => DYA[52]) = (1.000, 1.000);
    if (DA[52] == 1'b1 && TDA[52] == 1'b0)
       (TENA => DYA[52]) = (1.000, 1.000);
    if (DA[51] == 1'b0 && TDA[51] == 1'b1)
       (TENA => DYA[51]) = (1.000, 1.000);
    if (DA[51] == 1'b1 && TDA[51] == 1'b0)
       (TENA => DYA[51]) = (1.000, 1.000);
    if (DA[50] == 1'b0 && TDA[50] == 1'b1)
       (TENA => DYA[50]) = (1.000, 1.000);
    if (DA[50] == 1'b1 && TDA[50] == 1'b0)
       (TENA => DYA[50]) = (1.000, 1.000);
    if (DA[49] == 1'b0 && TDA[49] == 1'b1)
       (TENA => DYA[49]) = (1.000, 1.000);
    if (DA[49] == 1'b1 && TDA[49] == 1'b0)
       (TENA => DYA[49]) = (1.000, 1.000);
    if (DA[48] == 1'b0 && TDA[48] == 1'b1)
       (TENA => DYA[48]) = (1.000, 1.000);
    if (DA[48] == 1'b1 && TDA[48] == 1'b0)
       (TENA => DYA[48]) = (1.000, 1.000);
    if (DA[47] == 1'b0 && TDA[47] == 1'b1)
       (TENA => DYA[47]) = (1.000, 1.000);
    if (DA[47] == 1'b1 && TDA[47] == 1'b0)
       (TENA => DYA[47]) = (1.000, 1.000);
    if (DA[46] == 1'b0 && TDA[46] == 1'b1)
       (TENA => DYA[46]) = (1.000, 1.000);
    if (DA[46] == 1'b1 && TDA[46] == 1'b0)
       (TENA => DYA[46]) = (1.000, 1.000);
    if (DA[45] == 1'b0 && TDA[45] == 1'b1)
       (TENA => DYA[45]) = (1.000, 1.000);
    if (DA[45] == 1'b1 && TDA[45] == 1'b0)
       (TENA => DYA[45]) = (1.000, 1.000);
    if (DA[44] == 1'b0 && TDA[44] == 1'b1)
       (TENA => DYA[44]) = (1.000, 1.000);
    if (DA[44] == 1'b1 && TDA[44] == 1'b0)
       (TENA => DYA[44]) = (1.000, 1.000);
    if (DA[43] == 1'b0 && TDA[43] == 1'b1)
       (TENA => DYA[43]) = (1.000, 1.000);
    if (DA[43] == 1'b1 && TDA[43] == 1'b0)
       (TENA => DYA[43]) = (1.000, 1.000);
    if (DA[42] == 1'b0 && TDA[42] == 1'b1)
       (TENA => DYA[42]) = (1.000, 1.000);
    if (DA[42] == 1'b1 && TDA[42] == 1'b0)
       (TENA => DYA[42]) = (1.000, 1.000);
    if (DA[41] == 1'b0 && TDA[41] == 1'b1)
       (TENA => DYA[41]) = (1.000, 1.000);
    if (DA[41] == 1'b1 && TDA[41] == 1'b0)
       (TENA => DYA[41]) = (1.000, 1.000);
    if (DA[40] == 1'b0 && TDA[40] == 1'b1)
       (TENA => DYA[40]) = (1.000, 1.000);
    if (DA[40] == 1'b1 && TDA[40] == 1'b0)
       (TENA => DYA[40]) = (1.000, 1.000);
    if (DA[39] == 1'b0 && TDA[39] == 1'b1)
       (TENA => DYA[39]) = (1.000, 1.000);
    if (DA[39] == 1'b1 && TDA[39] == 1'b0)
       (TENA => DYA[39]) = (1.000, 1.000);
    if (DA[38] == 1'b0 && TDA[38] == 1'b1)
       (TENA => DYA[38]) = (1.000, 1.000);
    if (DA[38] == 1'b1 && TDA[38] == 1'b0)
       (TENA => DYA[38]) = (1.000, 1.000);
    if (DA[37] == 1'b0 && TDA[37] == 1'b1)
       (TENA => DYA[37]) = (1.000, 1.000);
    if (DA[37] == 1'b1 && TDA[37] == 1'b0)
       (TENA => DYA[37]) = (1.000, 1.000);
    if (DA[36] == 1'b0 && TDA[36] == 1'b1)
       (TENA => DYA[36]) = (1.000, 1.000);
    if (DA[36] == 1'b1 && TDA[36] == 1'b0)
       (TENA => DYA[36]) = (1.000, 1.000);
    if (DA[35] == 1'b0 && TDA[35] == 1'b1)
       (TENA => DYA[35]) = (1.000, 1.000);
    if (DA[35] == 1'b1 && TDA[35] == 1'b0)
       (TENA => DYA[35]) = (1.000, 1.000);
    if (DA[34] == 1'b0 && TDA[34] == 1'b1)
       (TENA => DYA[34]) = (1.000, 1.000);
    if (DA[34] == 1'b1 && TDA[34] == 1'b0)
       (TENA => DYA[34]) = (1.000, 1.000);
    if (DA[33] == 1'b0 && TDA[33] == 1'b1)
       (TENA => DYA[33]) = (1.000, 1.000);
    if (DA[33] == 1'b1 && TDA[33] == 1'b0)
       (TENA => DYA[33]) = (1.000, 1.000);
    if (DA[32] == 1'b0 && TDA[32] == 1'b1)
       (TENA => DYA[32]) = (1.000, 1.000);
    if (DA[32] == 1'b1 && TDA[32] == 1'b0)
       (TENA => DYA[32]) = (1.000, 1.000);
    if (DA[31] == 1'b0 && TDA[31] == 1'b1)
       (TENA => DYA[31]) = (1.000, 1.000);
    if (DA[31] == 1'b1 && TDA[31] == 1'b0)
       (TENA => DYA[31]) = (1.000, 1.000);
    if (DA[30] == 1'b0 && TDA[30] == 1'b1)
       (TENA => DYA[30]) = (1.000, 1.000);
    if (DA[30] == 1'b1 && TDA[30] == 1'b0)
       (TENA => DYA[30]) = (1.000, 1.000);
    if (DA[29] == 1'b0 && TDA[29] == 1'b1)
       (TENA => DYA[29]) = (1.000, 1.000);
    if (DA[29] == 1'b1 && TDA[29] == 1'b0)
       (TENA => DYA[29]) = (1.000, 1.000);
    if (DA[28] == 1'b0 && TDA[28] == 1'b1)
       (TENA => DYA[28]) = (1.000, 1.000);
    if (DA[28] == 1'b1 && TDA[28] == 1'b0)
       (TENA => DYA[28]) = (1.000, 1.000);
    if (DA[27] == 1'b0 && TDA[27] == 1'b1)
       (TENA => DYA[27]) = (1.000, 1.000);
    if (DA[27] == 1'b1 && TDA[27] == 1'b0)
       (TENA => DYA[27]) = (1.000, 1.000);
    if (DA[26] == 1'b0 && TDA[26] == 1'b1)
       (TENA => DYA[26]) = (1.000, 1.000);
    if (DA[26] == 1'b1 && TDA[26] == 1'b0)
       (TENA => DYA[26]) = (1.000, 1.000);
    if (DA[25] == 1'b0 && TDA[25] == 1'b1)
       (TENA => DYA[25]) = (1.000, 1.000);
    if (DA[25] == 1'b1 && TDA[25] == 1'b0)
       (TENA => DYA[25]) = (1.000, 1.000);
    if (DA[24] == 1'b0 && TDA[24] == 1'b1)
       (TENA => DYA[24]) = (1.000, 1.000);
    if (DA[24] == 1'b1 && TDA[24] == 1'b0)
       (TENA => DYA[24]) = (1.000, 1.000);
    if (DA[23] == 1'b0 && TDA[23] == 1'b1)
       (TENA => DYA[23]) = (1.000, 1.000);
    if (DA[23] == 1'b1 && TDA[23] == 1'b0)
       (TENA => DYA[23]) = (1.000, 1.000);
    if (DA[22] == 1'b0 && TDA[22] == 1'b1)
       (TENA => DYA[22]) = (1.000, 1.000);
    if (DA[22] == 1'b1 && TDA[22] == 1'b0)
       (TENA => DYA[22]) = (1.000, 1.000);
    if (DA[21] == 1'b0 && TDA[21] == 1'b1)
       (TENA => DYA[21]) = (1.000, 1.000);
    if (DA[21] == 1'b1 && TDA[21] == 1'b0)
       (TENA => DYA[21]) = (1.000, 1.000);
    if (DA[20] == 1'b0 && TDA[20] == 1'b1)
       (TENA => DYA[20]) = (1.000, 1.000);
    if (DA[20] == 1'b1 && TDA[20] == 1'b0)
       (TENA => DYA[20]) = (1.000, 1.000);
    if (DA[19] == 1'b0 && TDA[19] == 1'b1)
       (TENA => DYA[19]) = (1.000, 1.000);
    if (DA[19] == 1'b1 && TDA[19] == 1'b0)
       (TENA => DYA[19]) = (1.000, 1.000);
    if (DA[18] == 1'b0 && TDA[18] == 1'b1)
       (TENA => DYA[18]) = (1.000, 1.000);
    if (DA[18] == 1'b1 && TDA[18] == 1'b0)
       (TENA => DYA[18]) = (1.000, 1.000);
    if (DA[17] == 1'b0 && TDA[17] == 1'b1)
       (TENA => DYA[17]) = (1.000, 1.000);
    if (DA[17] == 1'b1 && TDA[17] == 1'b0)
       (TENA => DYA[17]) = (1.000, 1.000);
    if (DA[16] == 1'b0 && TDA[16] == 1'b1)
       (TENA => DYA[16]) = (1.000, 1.000);
    if (DA[16] == 1'b1 && TDA[16] == 1'b0)
       (TENA => DYA[16]) = (1.000, 1.000);
    if (DA[15] == 1'b0 && TDA[15] == 1'b1)
       (TENA => DYA[15]) = (1.000, 1.000);
    if (DA[15] == 1'b1 && TDA[15] == 1'b0)
       (TENA => DYA[15]) = (1.000, 1.000);
    if (DA[14] == 1'b0 && TDA[14] == 1'b1)
       (TENA => DYA[14]) = (1.000, 1.000);
    if (DA[14] == 1'b1 && TDA[14] == 1'b0)
       (TENA => DYA[14]) = (1.000, 1.000);
    if (DA[13] == 1'b0 && TDA[13] == 1'b1)
       (TENA => DYA[13]) = (1.000, 1.000);
    if (DA[13] == 1'b1 && TDA[13] == 1'b0)
       (TENA => DYA[13]) = (1.000, 1.000);
    if (DA[12] == 1'b0 && TDA[12] == 1'b1)
       (TENA => DYA[12]) = (1.000, 1.000);
    if (DA[12] == 1'b1 && TDA[12] == 1'b0)
       (TENA => DYA[12]) = (1.000, 1.000);
    if (DA[11] == 1'b0 && TDA[11] == 1'b1)
       (TENA => DYA[11]) = (1.000, 1.000);
    if (DA[11] == 1'b1 && TDA[11] == 1'b0)
       (TENA => DYA[11]) = (1.000, 1.000);
    if (DA[10] == 1'b0 && TDA[10] == 1'b1)
       (TENA => DYA[10]) = (1.000, 1.000);
    if (DA[10] == 1'b1 && TDA[10] == 1'b0)
       (TENA => DYA[10]) = (1.000, 1.000);
    if (DA[9] == 1'b0 && TDA[9] == 1'b1)
       (TENA => DYA[9]) = (1.000, 1.000);
    if (DA[9] == 1'b1 && TDA[9] == 1'b0)
       (TENA => DYA[9]) = (1.000, 1.000);
    if (DA[8] == 1'b0 && TDA[8] == 1'b1)
       (TENA => DYA[8]) = (1.000, 1.000);
    if (DA[8] == 1'b1 && TDA[8] == 1'b0)
       (TENA => DYA[8]) = (1.000, 1.000);
    if (DA[7] == 1'b0 && TDA[7] == 1'b1)
       (TENA => DYA[7]) = (1.000, 1.000);
    if (DA[7] == 1'b1 && TDA[7] == 1'b0)
       (TENA => DYA[7]) = (1.000, 1.000);
    if (DA[6] == 1'b0 && TDA[6] == 1'b1)
       (TENA => DYA[6]) = (1.000, 1.000);
    if (DA[6] == 1'b1 && TDA[6] == 1'b0)
       (TENA => DYA[6]) = (1.000, 1.000);
    if (DA[5] == 1'b0 && TDA[5] == 1'b1)
       (TENA => DYA[5]) = (1.000, 1.000);
    if (DA[5] == 1'b1 && TDA[5] == 1'b0)
       (TENA => DYA[5]) = (1.000, 1.000);
    if (DA[4] == 1'b0 && TDA[4] == 1'b1)
       (TENA => DYA[4]) = (1.000, 1.000);
    if (DA[4] == 1'b1 && TDA[4] == 1'b0)
       (TENA => DYA[4]) = (1.000, 1.000);
    if (DA[3] == 1'b0 && TDA[3] == 1'b1)
       (TENA => DYA[3]) = (1.000, 1.000);
    if (DA[3] == 1'b1 && TDA[3] == 1'b0)
       (TENA => DYA[3]) = (1.000, 1.000);
    if (DA[2] == 1'b0 && TDA[2] == 1'b1)
       (TENA => DYA[2]) = (1.000, 1.000);
    if (DA[2] == 1'b1 && TDA[2] == 1'b0)
       (TENA => DYA[2]) = (1.000, 1.000);
    if (DA[1] == 1'b0 && TDA[1] == 1'b1)
       (TENA => DYA[1]) = (1.000, 1.000);
    if (DA[1] == 1'b1 && TDA[1] == 1'b0)
       (TENA => DYA[1]) = (1.000, 1.000);
    if (DA[0] == 1'b0 && TDA[0] == 1'b1)
       (TENA => DYA[0]) = (1.000, 1.000);
    if (DA[0] == 1'b1 && TDA[0] == 1'b0)
       (TENA => DYA[0]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[79] => DYA[79]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[78] => DYA[78]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[77] => DYA[77]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[76] => DYA[76]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[75] => DYA[75]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[74] => DYA[74]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[73] => DYA[73]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[72] => DYA[72]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[71] => DYA[71]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[70] => DYA[70]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[69] => DYA[69]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[68] => DYA[68]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[67] => DYA[67]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[66] => DYA[66]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[65] => DYA[65]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[64] => DYA[64]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[63] => DYA[63]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[62] => DYA[62]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[61] => DYA[61]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[60] => DYA[60]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[59] => DYA[59]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[58] => DYA[58]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[57] => DYA[57]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[56] => DYA[56]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[55] => DYA[55]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[54] => DYA[54]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[53] => DYA[53]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[52] => DYA[52]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[51] => DYA[51]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[50] => DYA[50]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[49] => DYA[49]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[48] => DYA[48]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[47] => DYA[47]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[46] => DYA[46]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[45] => DYA[45]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[44] => DYA[44]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[43] => DYA[43]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[42] => DYA[42]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[41] => DYA[41]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[40] => DYA[40]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[39] => DYA[39]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[38] => DYA[38]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[37] => DYA[37]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[36] => DYA[36]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[35] => DYA[35]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[34] => DYA[34]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[33] => DYA[33]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[32] => DYA[32]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[31] => DYA[31]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[30] => DYA[30]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[29] => DYA[29]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[28] => DYA[28]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[27] => DYA[27]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[26] => DYA[26]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[25] => DYA[25]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[24] => DYA[24]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[23] => DYA[23]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[22] => DYA[22]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[21] => DYA[21]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[20] => DYA[20]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[19] => DYA[19]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[18] => DYA[18]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[17] => DYA[17]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[16] => DYA[16]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[15] => DYA[15]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[14] => DYA[14]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[13] => DYA[13]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[12] => DYA[12]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[11] => DYA[11]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[10] => DYA[10]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[9] => DYA[9]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[8] => DYA[8]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[7] => DYA[7]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[6] => DYA[6]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[5] => DYA[5]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[4] => DYA[4]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[3] => DYA[3]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[2] => DYA[2]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[1] => DYA[1]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[0] => DYA[0]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[79] => DYA[79]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[78] => DYA[78]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[77] => DYA[77]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[76] => DYA[76]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[75] => DYA[75]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[74] => DYA[74]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[73] => DYA[73]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[72] => DYA[72]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[71] => DYA[71]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[70] => DYA[70]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[69] => DYA[69]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[68] => DYA[68]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[67] => DYA[67]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[66] => DYA[66]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[65] => DYA[65]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[64] => DYA[64]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[63] => DYA[63]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[62] => DYA[62]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[61] => DYA[61]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[60] => DYA[60]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[59] => DYA[59]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[58] => DYA[58]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[57] => DYA[57]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[56] => DYA[56]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[55] => DYA[55]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[54] => DYA[54]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[53] => DYA[53]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[52] => DYA[52]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[51] => DYA[51]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[50] => DYA[50]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[49] => DYA[49]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[48] => DYA[48]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[47] => DYA[47]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[46] => DYA[46]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[45] => DYA[45]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[44] => DYA[44]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[43] => DYA[43]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[42] => DYA[42]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[41] => DYA[41]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[40] => DYA[40]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[39] => DYA[39]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[38] => DYA[38]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[37] => DYA[37]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[36] => DYA[36]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[35] => DYA[35]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[34] => DYA[34]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[33] => DYA[33]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[32] => DYA[32]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[31] => DYA[31]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[30] => DYA[30]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[29] => DYA[29]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[28] => DYA[28]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[27] => DYA[27]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[26] => DYA[26]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[25] => DYA[25]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[24] => DYA[24]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[23] => DYA[23]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[22] => DYA[22]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[21] => DYA[21]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[20] => DYA[20]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[19] => DYA[19]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[18] => DYA[18]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[17] => DYA[17]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[16] => DYA[16]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[15] => DYA[15]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[14] => DYA[14]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[13] => DYA[13]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[12] => DYA[12]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[11] => DYA[11]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[10] => DYA[10]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[9] => DYA[9]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[8] => DYA[8]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[7] => DYA[7]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[6] => DYA[6]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[5] => DYA[5]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[4] => DYA[4]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[3] => DYA[3]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[2] => DYA[2]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[1] => DYA[1]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[0] => DYA[0]) = (1.000, 1.000);
    if (CENB == 1'b0 && TCENB == 1'b1)
       (TENB => CENYB) = (1.000, 1.000);
    if (CENB == 1'b1 && TCENB == 1'b0)
       (TENB => CENYB) = (1.000, 1.000);
    if (TENB == 1'b1)
       (CENB => CENYB) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TCENB => CENYB) = (1.000, 1.000);
    if (WENB == 1'b0 && TWENB == 1'b1)
       (TENB => WENYB) = (1.000, 1.000);
    if (WENB == 1'b1 && TWENB == 1'b0)
       (TENB => WENYB) = (1.000, 1.000);
    if (TENB == 1'b1)
       (WENB => WENYB) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TWENB => WENYB) = (1.000, 1.000);
    if (AB[10] == 1'b0 && TAB[10] == 1'b1)
       (TENB => AYB[10]) = (1.000, 1.000);
    if (AB[10] == 1'b1 && TAB[10] == 1'b0)
       (TENB => AYB[10]) = (1.000, 1.000);
    if (AB[9] == 1'b0 && TAB[9] == 1'b1)
       (TENB => AYB[9]) = (1.000, 1.000);
    if (AB[9] == 1'b1 && TAB[9] == 1'b0)
       (TENB => AYB[9]) = (1.000, 1.000);
    if (AB[8] == 1'b0 && TAB[8] == 1'b1)
       (TENB => AYB[8]) = (1.000, 1.000);
    if (AB[8] == 1'b1 && TAB[8] == 1'b0)
       (TENB => AYB[8]) = (1.000, 1.000);
    if (AB[7] == 1'b0 && TAB[7] == 1'b1)
       (TENB => AYB[7]) = (1.000, 1.000);
    if (AB[7] == 1'b1 && TAB[7] == 1'b0)
       (TENB => AYB[7]) = (1.000, 1.000);
    if (AB[6] == 1'b0 && TAB[6] == 1'b1)
       (TENB => AYB[6]) = (1.000, 1.000);
    if (AB[6] == 1'b1 && TAB[6] == 1'b0)
       (TENB => AYB[6]) = (1.000, 1.000);
    if (AB[5] == 1'b0 && TAB[5] == 1'b1)
       (TENB => AYB[5]) = (1.000, 1.000);
    if (AB[5] == 1'b1 && TAB[5] == 1'b0)
       (TENB => AYB[5]) = (1.000, 1.000);
    if (AB[4] == 1'b0 && TAB[4] == 1'b1)
       (TENB => AYB[4]) = (1.000, 1.000);
    if (AB[4] == 1'b1 && TAB[4] == 1'b0)
       (TENB => AYB[4]) = (1.000, 1.000);
    if (AB[3] == 1'b0 && TAB[3] == 1'b1)
       (TENB => AYB[3]) = (1.000, 1.000);
    if (AB[3] == 1'b1 && TAB[3] == 1'b0)
       (TENB => AYB[3]) = (1.000, 1.000);
    if (AB[2] == 1'b0 && TAB[2] == 1'b1)
       (TENB => AYB[2]) = (1.000, 1.000);
    if (AB[2] == 1'b1 && TAB[2] == 1'b0)
       (TENB => AYB[2]) = (1.000, 1.000);
    if (AB[1] == 1'b0 && TAB[1] == 1'b1)
       (TENB => AYB[1]) = (1.000, 1.000);
    if (AB[1] == 1'b1 && TAB[1] == 1'b0)
       (TENB => AYB[1]) = (1.000, 1.000);
    if (AB[0] == 1'b0 && TAB[0] == 1'b1)
       (TENB => AYB[0]) = (1.000, 1.000);
    if (AB[0] == 1'b1 && TAB[0] == 1'b0)
       (TENB => AYB[0]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[10] => AYB[10]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[9] => AYB[9]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[8] => AYB[8]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[7] => AYB[7]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[6] => AYB[6]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[5] => AYB[5]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[4] => AYB[4]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[3] => AYB[3]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[2] => AYB[2]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[1] => AYB[1]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[0] => AYB[0]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[10] => AYB[10]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[9] => AYB[9]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[8] => AYB[8]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[7] => AYB[7]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[6] => AYB[6]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[5] => AYB[5]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[4] => AYB[4]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[3] => AYB[3]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[2] => AYB[2]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[1] => AYB[1]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[0] => AYB[0]) = (1.000, 1.000);
    if (DB[79] == 1'b0 && TDB[79] == 1'b1)
       (TENB => DYB[79]) = (1.000, 1.000);
    if (DB[79] == 1'b1 && TDB[79] == 1'b0)
       (TENB => DYB[79]) = (1.000, 1.000);
    if (DB[78] == 1'b0 && TDB[78] == 1'b1)
       (TENB => DYB[78]) = (1.000, 1.000);
    if (DB[78] == 1'b1 && TDB[78] == 1'b0)
       (TENB => DYB[78]) = (1.000, 1.000);
    if (DB[77] == 1'b0 && TDB[77] == 1'b1)
       (TENB => DYB[77]) = (1.000, 1.000);
    if (DB[77] == 1'b1 && TDB[77] == 1'b0)
       (TENB => DYB[77]) = (1.000, 1.000);
    if (DB[76] == 1'b0 && TDB[76] == 1'b1)
       (TENB => DYB[76]) = (1.000, 1.000);
    if (DB[76] == 1'b1 && TDB[76] == 1'b0)
       (TENB => DYB[76]) = (1.000, 1.000);
    if (DB[75] == 1'b0 && TDB[75] == 1'b1)
       (TENB => DYB[75]) = (1.000, 1.000);
    if (DB[75] == 1'b1 && TDB[75] == 1'b0)
       (TENB => DYB[75]) = (1.000, 1.000);
    if (DB[74] == 1'b0 && TDB[74] == 1'b1)
       (TENB => DYB[74]) = (1.000, 1.000);
    if (DB[74] == 1'b1 && TDB[74] == 1'b0)
       (TENB => DYB[74]) = (1.000, 1.000);
    if (DB[73] == 1'b0 && TDB[73] == 1'b1)
       (TENB => DYB[73]) = (1.000, 1.000);
    if (DB[73] == 1'b1 && TDB[73] == 1'b0)
       (TENB => DYB[73]) = (1.000, 1.000);
    if (DB[72] == 1'b0 && TDB[72] == 1'b1)
       (TENB => DYB[72]) = (1.000, 1.000);
    if (DB[72] == 1'b1 && TDB[72] == 1'b0)
       (TENB => DYB[72]) = (1.000, 1.000);
    if (DB[71] == 1'b0 && TDB[71] == 1'b1)
       (TENB => DYB[71]) = (1.000, 1.000);
    if (DB[71] == 1'b1 && TDB[71] == 1'b0)
       (TENB => DYB[71]) = (1.000, 1.000);
    if (DB[70] == 1'b0 && TDB[70] == 1'b1)
       (TENB => DYB[70]) = (1.000, 1.000);
    if (DB[70] == 1'b1 && TDB[70] == 1'b0)
       (TENB => DYB[70]) = (1.000, 1.000);
    if (DB[69] == 1'b0 && TDB[69] == 1'b1)
       (TENB => DYB[69]) = (1.000, 1.000);
    if (DB[69] == 1'b1 && TDB[69] == 1'b0)
       (TENB => DYB[69]) = (1.000, 1.000);
    if (DB[68] == 1'b0 && TDB[68] == 1'b1)
       (TENB => DYB[68]) = (1.000, 1.000);
    if (DB[68] == 1'b1 && TDB[68] == 1'b0)
       (TENB => DYB[68]) = (1.000, 1.000);
    if (DB[67] == 1'b0 && TDB[67] == 1'b1)
       (TENB => DYB[67]) = (1.000, 1.000);
    if (DB[67] == 1'b1 && TDB[67] == 1'b0)
       (TENB => DYB[67]) = (1.000, 1.000);
    if (DB[66] == 1'b0 && TDB[66] == 1'b1)
       (TENB => DYB[66]) = (1.000, 1.000);
    if (DB[66] == 1'b1 && TDB[66] == 1'b0)
       (TENB => DYB[66]) = (1.000, 1.000);
    if (DB[65] == 1'b0 && TDB[65] == 1'b1)
       (TENB => DYB[65]) = (1.000, 1.000);
    if (DB[65] == 1'b1 && TDB[65] == 1'b0)
       (TENB => DYB[65]) = (1.000, 1.000);
    if (DB[64] == 1'b0 && TDB[64] == 1'b1)
       (TENB => DYB[64]) = (1.000, 1.000);
    if (DB[64] == 1'b1 && TDB[64] == 1'b0)
       (TENB => DYB[64]) = (1.000, 1.000);
    if (DB[63] == 1'b0 && TDB[63] == 1'b1)
       (TENB => DYB[63]) = (1.000, 1.000);
    if (DB[63] == 1'b1 && TDB[63] == 1'b0)
       (TENB => DYB[63]) = (1.000, 1.000);
    if (DB[62] == 1'b0 && TDB[62] == 1'b1)
       (TENB => DYB[62]) = (1.000, 1.000);
    if (DB[62] == 1'b1 && TDB[62] == 1'b0)
       (TENB => DYB[62]) = (1.000, 1.000);
    if (DB[61] == 1'b0 && TDB[61] == 1'b1)
       (TENB => DYB[61]) = (1.000, 1.000);
    if (DB[61] == 1'b1 && TDB[61] == 1'b0)
       (TENB => DYB[61]) = (1.000, 1.000);
    if (DB[60] == 1'b0 && TDB[60] == 1'b1)
       (TENB => DYB[60]) = (1.000, 1.000);
    if (DB[60] == 1'b1 && TDB[60] == 1'b0)
       (TENB => DYB[60]) = (1.000, 1.000);
    if (DB[59] == 1'b0 && TDB[59] == 1'b1)
       (TENB => DYB[59]) = (1.000, 1.000);
    if (DB[59] == 1'b1 && TDB[59] == 1'b0)
       (TENB => DYB[59]) = (1.000, 1.000);
    if (DB[58] == 1'b0 && TDB[58] == 1'b1)
       (TENB => DYB[58]) = (1.000, 1.000);
    if (DB[58] == 1'b1 && TDB[58] == 1'b0)
       (TENB => DYB[58]) = (1.000, 1.000);
    if (DB[57] == 1'b0 && TDB[57] == 1'b1)
       (TENB => DYB[57]) = (1.000, 1.000);
    if (DB[57] == 1'b1 && TDB[57] == 1'b0)
       (TENB => DYB[57]) = (1.000, 1.000);
    if (DB[56] == 1'b0 && TDB[56] == 1'b1)
       (TENB => DYB[56]) = (1.000, 1.000);
    if (DB[56] == 1'b1 && TDB[56] == 1'b0)
       (TENB => DYB[56]) = (1.000, 1.000);
    if (DB[55] == 1'b0 && TDB[55] == 1'b1)
       (TENB => DYB[55]) = (1.000, 1.000);
    if (DB[55] == 1'b1 && TDB[55] == 1'b0)
       (TENB => DYB[55]) = (1.000, 1.000);
    if (DB[54] == 1'b0 && TDB[54] == 1'b1)
       (TENB => DYB[54]) = (1.000, 1.000);
    if (DB[54] == 1'b1 && TDB[54] == 1'b0)
       (TENB => DYB[54]) = (1.000, 1.000);
    if (DB[53] == 1'b0 && TDB[53] == 1'b1)
       (TENB => DYB[53]) = (1.000, 1.000);
    if (DB[53] == 1'b1 && TDB[53] == 1'b0)
       (TENB => DYB[53]) = (1.000, 1.000);
    if (DB[52] == 1'b0 && TDB[52] == 1'b1)
       (TENB => DYB[52]) = (1.000, 1.000);
    if (DB[52] == 1'b1 && TDB[52] == 1'b0)
       (TENB => DYB[52]) = (1.000, 1.000);
    if (DB[51] == 1'b0 && TDB[51] == 1'b1)
       (TENB => DYB[51]) = (1.000, 1.000);
    if (DB[51] == 1'b1 && TDB[51] == 1'b0)
       (TENB => DYB[51]) = (1.000, 1.000);
    if (DB[50] == 1'b0 && TDB[50] == 1'b1)
       (TENB => DYB[50]) = (1.000, 1.000);
    if (DB[50] == 1'b1 && TDB[50] == 1'b0)
       (TENB => DYB[50]) = (1.000, 1.000);
    if (DB[49] == 1'b0 && TDB[49] == 1'b1)
       (TENB => DYB[49]) = (1.000, 1.000);
    if (DB[49] == 1'b1 && TDB[49] == 1'b0)
       (TENB => DYB[49]) = (1.000, 1.000);
    if (DB[48] == 1'b0 && TDB[48] == 1'b1)
       (TENB => DYB[48]) = (1.000, 1.000);
    if (DB[48] == 1'b1 && TDB[48] == 1'b0)
       (TENB => DYB[48]) = (1.000, 1.000);
    if (DB[47] == 1'b0 && TDB[47] == 1'b1)
       (TENB => DYB[47]) = (1.000, 1.000);
    if (DB[47] == 1'b1 && TDB[47] == 1'b0)
       (TENB => DYB[47]) = (1.000, 1.000);
    if (DB[46] == 1'b0 && TDB[46] == 1'b1)
       (TENB => DYB[46]) = (1.000, 1.000);
    if (DB[46] == 1'b1 && TDB[46] == 1'b0)
       (TENB => DYB[46]) = (1.000, 1.000);
    if (DB[45] == 1'b0 && TDB[45] == 1'b1)
       (TENB => DYB[45]) = (1.000, 1.000);
    if (DB[45] == 1'b1 && TDB[45] == 1'b0)
       (TENB => DYB[45]) = (1.000, 1.000);
    if (DB[44] == 1'b0 && TDB[44] == 1'b1)
       (TENB => DYB[44]) = (1.000, 1.000);
    if (DB[44] == 1'b1 && TDB[44] == 1'b0)
       (TENB => DYB[44]) = (1.000, 1.000);
    if (DB[43] == 1'b0 && TDB[43] == 1'b1)
       (TENB => DYB[43]) = (1.000, 1.000);
    if (DB[43] == 1'b1 && TDB[43] == 1'b0)
       (TENB => DYB[43]) = (1.000, 1.000);
    if (DB[42] == 1'b0 && TDB[42] == 1'b1)
       (TENB => DYB[42]) = (1.000, 1.000);
    if (DB[42] == 1'b1 && TDB[42] == 1'b0)
       (TENB => DYB[42]) = (1.000, 1.000);
    if (DB[41] == 1'b0 && TDB[41] == 1'b1)
       (TENB => DYB[41]) = (1.000, 1.000);
    if (DB[41] == 1'b1 && TDB[41] == 1'b0)
       (TENB => DYB[41]) = (1.000, 1.000);
    if (DB[40] == 1'b0 && TDB[40] == 1'b1)
       (TENB => DYB[40]) = (1.000, 1.000);
    if (DB[40] == 1'b1 && TDB[40] == 1'b0)
       (TENB => DYB[40]) = (1.000, 1.000);
    if (DB[39] == 1'b0 && TDB[39] == 1'b1)
       (TENB => DYB[39]) = (1.000, 1.000);
    if (DB[39] == 1'b1 && TDB[39] == 1'b0)
       (TENB => DYB[39]) = (1.000, 1.000);
    if (DB[38] == 1'b0 && TDB[38] == 1'b1)
       (TENB => DYB[38]) = (1.000, 1.000);
    if (DB[38] == 1'b1 && TDB[38] == 1'b0)
       (TENB => DYB[38]) = (1.000, 1.000);
    if (DB[37] == 1'b0 && TDB[37] == 1'b1)
       (TENB => DYB[37]) = (1.000, 1.000);
    if (DB[37] == 1'b1 && TDB[37] == 1'b0)
       (TENB => DYB[37]) = (1.000, 1.000);
    if (DB[36] == 1'b0 && TDB[36] == 1'b1)
       (TENB => DYB[36]) = (1.000, 1.000);
    if (DB[36] == 1'b1 && TDB[36] == 1'b0)
       (TENB => DYB[36]) = (1.000, 1.000);
    if (DB[35] == 1'b0 && TDB[35] == 1'b1)
       (TENB => DYB[35]) = (1.000, 1.000);
    if (DB[35] == 1'b1 && TDB[35] == 1'b0)
       (TENB => DYB[35]) = (1.000, 1.000);
    if (DB[34] == 1'b0 && TDB[34] == 1'b1)
       (TENB => DYB[34]) = (1.000, 1.000);
    if (DB[34] == 1'b1 && TDB[34] == 1'b0)
       (TENB => DYB[34]) = (1.000, 1.000);
    if (DB[33] == 1'b0 && TDB[33] == 1'b1)
       (TENB => DYB[33]) = (1.000, 1.000);
    if (DB[33] == 1'b1 && TDB[33] == 1'b0)
       (TENB => DYB[33]) = (1.000, 1.000);
    if (DB[32] == 1'b0 && TDB[32] == 1'b1)
       (TENB => DYB[32]) = (1.000, 1.000);
    if (DB[32] == 1'b1 && TDB[32] == 1'b0)
       (TENB => DYB[32]) = (1.000, 1.000);
    if (DB[31] == 1'b0 && TDB[31] == 1'b1)
       (TENB => DYB[31]) = (1.000, 1.000);
    if (DB[31] == 1'b1 && TDB[31] == 1'b0)
       (TENB => DYB[31]) = (1.000, 1.000);
    if (DB[30] == 1'b0 && TDB[30] == 1'b1)
       (TENB => DYB[30]) = (1.000, 1.000);
    if (DB[30] == 1'b1 && TDB[30] == 1'b0)
       (TENB => DYB[30]) = (1.000, 1.000);
    if (DB[29] == 1'b0 && TDB[29] == 1'b1)
       (TENB => DYB[29]) = (1.000, 1.000);
    if (DB[29] == 1'b1 && TDB[29] == 1'b0)
       (TENB => DYB[29]) = (1.000, 1.000);
    if (DB[28] == 1'b0 && TDB[28] == 1'b1)
       (TENB => DYB[28]) = (1.000, 1.000);
    if (DB[28] == 1'b1 && TDB[28] == 1'b0)
       (TENB => DYB[28]) = (1.000, 1.000);
    if (DB[27] == 1'b0 && TDB[27] == 1'b1)
       (TENB => DYB[27]) = (1.000, 1.000);
    if (DB[27] == 1'b1 && TDB[27] == 1'b0)
       (TENB => DYB[27]) = (1.000, 1.000);
    if (DB[26] == 1'b0 && TDB[26] == 1'b1)
       (TENB => DYB[26]) = (1.000, 1.000);
    if (DB[26] == 1'b1 && TDB[26] == 1'b0)
       (TENB => DYB[26]) = (1.000, 1.000);
    if (DB[25] == 1'b0 && TDB[25] == 1'b1)
       (TENB => DYB[25]) = (1.000, 1.000);
    if (DB[25] == 1'b1 && TDB[25] == 1'b0)
       (TENB => DYB[25]) = (1.000, 1.000);
    if (DB[24] == 1'b0 && TDB[24] == 1'b1)
       (TENB => DYB[24]) = (1.000, 1.000);
    if (DB[24] == 1'b1 && TDB[24] == 1'b0)
       (TENB => DYB[24]) = (1.000, 1.000);
    if (DB[23] == 1'b0 && TDB[23] == 1'b1)
       (TENB => DYB[23]) = (1.000, 1.000);
    if (DB[23] == 1'b1 && TDB[23] == 1'b0)
       (TENB => DYB[23]) = (1.000, 1.000);
    if (DB[22] == 1'b0 && TDB[22] == 1'b1)
       (TENB => DYB[22]) = (1.000, 1.000);
    if (DB[22] == 1'b1 && TDB[22] == 1'b0)
       (TENB => DYB[22]) = (1.000, 1.000);
    if (DB[21] == 1'b0 && TDB[21] == 1'b1)
       (TENB => DYB[21]) = (1.000, 1.000);
    if (DB[21] == 1'b1 && TDB[21] == 1'b0)
       (TENB => DYB[21]) = (1.000, 1.000);
    if (DB[20] == 1'b0 && TDB[20] == 1'b1)
       (TENB => DYB[20]) = (1.000, 1.000);
    if (DB[20] == 1'b1 && TDB[20] == 1'b0)
       (TENB => DYB[20]) = (1.000, 1.000);
    if (DB[19] == 1'b0 && TDB[19] == 1'b1)
       (TENB => DYB[19]) = (1.000, 1.000);
    if (DB[19] == 1'b1 && TDB[19] == 1'b0)
       (TENB => DYB[19]) = (1.000, 1.000);
    if (DB[18] == 1'b0 && TDB[18] == 1'b1)
       (TENB => DYB[18]) = (1.000, 1.000);
    if (DB[18] == 1'b1 && TDB[18] == 1'b0)
       (TENB => DYB[18]) = (1.000, 1.000);
    if (DB[17] == 1'b0 && TDB[17] == 1'b1)
       (TENB => DYB[17]) = (1.000, 1.000);
    if (DB[17] == 1'b1 && TDB[17] == 1'b0)
       (TENB => DYB[17]) = (1.000, 1.000);
    if (DB[16] == 1'b0 && TDB[16] == 1'b1)
       (TENB => DYB[16]) = (1.000, 1.000);
    if (DB[16] == 1'b1 && TDB[16] == 1'b0)
       (TENB => DYB[16]) = (1.000, 1.000);
    if (DB[15] == 1'b0 && TDB[15] == 1'b1)
       (TENB => DYB[15]) = (1.000, 1.000);
    if (DB[15] == 1'b1 && TDB[15] == 1'b0)
       (TENB => DYB[15]) = (1.000, 1.000);
    if (DB[14] == 1'b0 && TDB[14] == 1'b1)
       (TENB => DYB[14]) = (1.000, 1.000);
    if (DB[14] == 1'b1 && TDB[14] == 1'b0)
       (TENB => DYB[14]) = (1.000, 1.000);
    if (DB[13] == 1'b0 && TDB[13] == 1'b1)
       (TENB => DYB[13]) = (1.000, 1.000);
    if (DB[13] == 1'b1 && TDB[13] == 1'b0)
       (TENB => DYB[13]) = (1.000, 1.000);
    if (DB[12] == 1'b0 && TDB[12] == 1'b1)
       (TENB => DYB[12]) = (1.000, 1.000);
    if (DB[12] == 1'b1 && TDB[12] == 1'b0)
       (TENB => DYB[12]) = (1.000, 1.000);
    if (DB[11] == 1'b0 && TDB[11] == 1'b1)
       (TENB => DYB[11]) = (1.000, 1.000);
    if (DB[11] == 1'b1 && TDB[11] == 1'b0)
       (TENB => DYB[11]) = (1.000, 1.000);
    if (DB[10] == 1'b0 && TDB[10] == 1'b1)
       (TENB => DYB[10]) = (1.000, 1.000);
    if (DB[10] == 1'b1 && TDB[10] == 1'b0)
       (TENB => DYB[10]) = (1.000, 1.000);
    if (DB[9] == 1'b0 && TDB[9] == 1'b1)
       (TENB => DYB[9]) = (1.000, 1.000);
    if (DB[9] == 1'b1 && TDB[9] == 1'b0)
       (TENB => DYB[9]) = (1.000, 1.000);
    if (DB[8] == 1'b0 && TDB[8] == 1'b1)
       (TENB => DYB[8]) = (1.000, 1.000);
    if (DB[8] == 1'b1 && TDB[8] == 1'b0)
       (TENB => DYB[8]) = (1.000, 1.000);
    if (DB[7] == 1'b0 && TDB[7] == 1'b1)
       (TENB => DYB[7]) = (1.000, 1.000);
    if (DB[7] == 1'b1 && TDB[7] == 1'b0)
       (TENB => DYB[7]) = (1.000, 1.000);
    if (DB[6] == 1'b0 && TDB[6] == 1'b1)
       (TENB => DYB[6]) = (1.000, 1.000);
    if (DB[6] == 1'b1 && TDB[6] == 1'b0)
       (TENB => DYB[6]) = (1.000, 1.000);
    if (DB[5] == 1'b0 && TDB[5] == 1'b1)
       (TENB => DYB[5]) = (1.000, 1.000);
    if (DB[5] == 1'b1 && TDB[5] == 1'b0)
       (TENB => DYB[5]) = (1.000, 1.000);
    if (DB[4] == 1'b0 && TDB[4] == 1'b1)
       (TENB => DYB[4]) = (1.000, 1.000);
    if (DB[4] == 1'b1 && TDB[4] == 1'b0)
       (TENB => DYB[4]) = (1.000, 1.000);
    if (DB[3] == 1'b0 && TDB[3] == 1'b1)
       (TENB => DYB[3]) = (1.000, 1.000);
    if (DB[3] == 1'b1 && TDB[3] == 1'b0)
       (TENB => DYB[3]) = (1.000, 1.000);
    if (DB[2] == 1'b0 && TDB[2] == 1'b1)
       (TENB => DYB[2]) = (1.000, 1.000);
    if (DB[2] == 1'b1 && TDB[2] == 1'b0)
       (TENB => DYB[2]) = (1.000, 1.000);
    if (DB[1] == 1'b0 && TDB[1] == 1'b1)
       (TENB => DYB[1]) = (1.000, 1.000);
    if (DB[1] == 1'b1 && TDB[1] == 1'b0)
       (TENB => DYB[1]) = (1.000, 1.000);
    if (DB[0] == 1'b0 && TDB[0] == 1'b1)
       (TENB => DYB[0]) = (1.000, 1.000);
    if (DB[0] == 1'b1 && TDB[0] == 1'b0)
       (TENB => DYB[0]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[79] => DYB[79]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[78] => DYB[78]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[77] => DYB[77]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[76] => DYB[76]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[75] => DYB[75]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[74] => DYB[74]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[73] => DYB[73]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[72] => DYB[72]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[71] => DYB[71]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[70] => DYB[70]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[69] => DYB[69]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[68] => DYB[68]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[67] => DYB[67]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[66] => DYB[66]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[65] => DYB[65]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[64] => DYB[64]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[63] => DYB[63]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[62] => DYB[62]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[61] => DYB[61]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[60] => DYB[60]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[59] => DYB[59]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[58] => DYB[58]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[57] => DYB[57]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[56] => DYB[56]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[55] => DYB[55]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[54] => DYB[54]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[53] => DYB[53]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[52] => DYB[52]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[51] => DYB[51]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[50] => DYB[50]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[49] => DYB[49]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[48] => DYB[48]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[47] => DYB[47]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[46] => DYB[46]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[45] => DYB[45]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[44] => DYB[44]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[43] => DYB[43]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[42] => DYB[42]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[41] => DYB[41]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[40] => DYB[40]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[39] => DYB[39]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[38] => DYB[38]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[37] => DYB[37]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[36] => DYB[36]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[35] => DYB[35]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[34] => DYB[34]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[33] => DYB[33]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[32] => DYB[32]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[31] => DYB[31]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[30] => DYB[30]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[29] => DYB[29]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[28] => DYB[28]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[27] => DYB[27]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[26] => DYB[26]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[25] => DYB[25]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[24] => DYB[24]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[23] => DYB[23]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[22] => DYB[22]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[21] => DYB[21]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[20] => DYB[20]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[19] => DYB[19]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[18] => DYB[18]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[17] => DYB[17]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[16] => DYB[16]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[15] => DYB[15]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[14] => DYB[14]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[13] => DYB[13]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[12] => DYB[12]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[11] => DYB[11]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[10] => DYB[10]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[9] => DYB[9]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[8] => DYB[8]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[7] => DYB[7]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[6] => DYB[6]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[5] => DYB[5]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[4] => DYB[4]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[3] => DYB[3]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[2] => DYB[2]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[1] => DYB[1]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[0] => DYB[0]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[79] => DYB[79]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[78] => DYB[78]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[77] => DYB[77]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[76] => DYB[76]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[75] => DYB[75]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[74] => DYB[74]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[73] => DYB[73]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[72] => DYB[72]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[71] => DYB[71]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[70] => DYB[70]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[69] => DYB[69]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[68] => DYB[68]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[67] => DYB[67]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[66] => DYB[66]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[65] => DYB[65]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[64] => DYB[64]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[63] => DYB[63]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[62] => DYB[62]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[61] => DYB[61]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[60] => DYB[60]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[59] => DYB[59]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[58] => DYB[58]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[57] => DYB[57]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[56] => DYB[56]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[55] => DYB[55]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[54] => DYB[54]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[53] => DYB[53]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[52] => DYB[52]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[51] => DYB[51]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[50] => DYB[50]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[49] => DYB[49]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[48] => DYB[48]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[47] => DYB[47]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[46] => DYB[46]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[45] => DYB[45]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[44] => DYB[44]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[43] => DYB[43]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[42] => DYB[42]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[41] => DYB[41]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[40] => DYB[40]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[39] => DYB[39]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[38] => DYB[38]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[37] => DYB[37]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[36] => DYB[36]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[35] => DYB[35]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[34] => DYB[34]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[33] => DYB[33]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[32] => DYB[32]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[31] => DYB[31]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[30] => DYB[30]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[29] => DYB[29]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[28] => DYB[28]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[27] => DYB[27]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[26] => DYB[26]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[25] => DYB[25]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[24] => DYB[24]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[23] => DYB[23]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[22] => DYB[22]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[21] => DYB[21]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[20] => DYB[20]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[19] => DYB[19]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[18] => DYB[18]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[17] => DYB[17]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[16] => DYB[16]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[15] => DYB[15]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[14] => DYB[14]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[13] => DYB[13]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[12] => DYB[12]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[11] => DYB[11]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[10] => DYB[10]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[9] => DYB[9]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[8] => DYB[8]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[7] => DYB[7]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[6] => DYB[6]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[5] => DYB[5]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[4] => DYB[4]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[3] => DYB[3]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[2] => DYB[2]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[1] => DYB[1]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[0] => DYB[0]) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (TQA[79] == 1'b1)
       (BENA => QA[79]) = (1.000, 1.000);
    if (TQA[79] == 1'b0)
       (BENA => QA[79]) = (1.000, 1.000);
    if (TQA[78] == 1'b1)
       (BENA => QA[78]) = (1.000, 1.000);
    if (TQA[78] == 1'b0)
       (BENA => QA[78]) = (1.000, 1.000);
    if (TQA[77] == 1'b1)
       (BENA => QA[77]) = (1.000, 1.000);
    if (TQA[77] == 1'b0)
       (BENA => QA[77]) = (1.000, 1.000);
    if (TQA[76] == 1'b1)
       (BENA => QA[76]) = (1.000, 1.000);
    if (TQA[76] == 1'b0)
       (BENA => QA[76]) = (1.000, 1.000);
    if (TQA[75] == 1'b1)
       (BENA => QA[75]) = (1.000, 1.000);
    if (TQA[75] == 1'b0)
       (BENA => QA[75]) = (1.000, 1.000);
    if (TQA[74] == 1'b1)
       (BENA => QA[74]) = (1.000, 1.000);
    if (TQA[74] == 1'b0)
       (BENA => QA[74]) = (1.000, 1.000);
    if (TQA[73] == 1'b1)
       (BENA => QA[73]) = (1.000, 1.000);
    if (TQA[73] == 1'b0)
       (BENA => QA[73]) = (1.000, 1.000);
    if (TQA[72] == 1'b1)
       (BENA => QA[72]) = (1.000, 1.000);
    if (TQA[72] == 1'b0)
       (BENA => QA[72]) = (1.000, 1.000);
    if (TQA[71] == 1'b1)
       (BENA => QA[71]) = (1.000, 1.000);
    if (TQA[71] == 1'b0)
       (BENA => QA[71]) = (1.000, 1.000);
    if (TQA[70] == 1'b1)
       (BENA => QA[70]) = (1.000, 1.000);
    if (TQA[70] == 1'b0)
       (BENA => QA[70]) = (1.000, 1.000);
    if (TQA[69] == 1'b1)
       (BENA => QA[69]) = (1.000, 1.000);
    if (TQA[69] == 1'b0)
       (BENA => QA[69]) = (1.000, 1.000);
    if (TQA[68] == 1'b1)
       (BENA => QA[68]) = (1.000, 1.000);
    if (TQA[68] == 1'b0)
       (BENA => QA[68]) = (1.000, 1.000);
    if (TQA[67] == 1'b1)
       (BENA => QA[67]) = (1.000, 1.000);
    if (TQA[67] == 1'b0)
       (BENA => QA[67]) = (1.000, 1.000);
    if (TQA[66] == 1'b1)
       (BENA => QA[66]) = (1.000, 1.000);
    if (TQA[66] == 1'b0)
       (BENA => QA[66]) = (1.000, 1.000);
    if (TQA[65] == 1'b1)
       (BENA => QA[65]) = (1.000, 1.000);
    if (TQA[65] == 1'b0)
       (BENA => QA[65]) = (1.000, 1.000);
    if (TQA[64] == 1'b1)
       (BENA => QA[64]) = (1.000, 1.000);
    if (TQA[64] == 1'b0)
       (BENA => QA[64]) = (1.000, 1.000);
    if (TQA[63] == 1'b1)
       (BENA => QA[63]) = (1.000, 1.000);
    if (TQA[63] == 1'b0)
       (BENA => QA[63]) = (1.000, 1.000);
    if (TQA[62] == 1'b1)
       (BENA => QA[62]) = (1.000, 1.000);
    if (TQA[62] == 1'b0)
       (BENA => QA[62]) = (1.000, 1.000);
    if (TQA[61] == 1'b1)
       (BENA => QA[61]) = (1.000, 1.000);
    if (TQA[61] == 1'b0)
       (BENA => QA[61]) = (1.000, 1.000);
    if (TQA[60] == 1'b1)
       (BENA => QA[60]) = (1.000, 1.000);
    if (TQA[60] == 1'b0)
       (BENA => QA[60]) = (1.000, 1.000);
    if (TQA[59] == 1'b1)
       (BENA => QA[59]) = (1.000, 1.000);
    if (TQA[59] == 1'b0)
       (BENA => QA[59]) = (1.000, 1.000);
    if (TQA[58] == 1'b1)
       (BENA => QA[58]) = (1.000, 1.000);
    if (TQA[58] == 1'b0)
       (BENA => QA[58]) = (1.000, 1.000);
    if (TQA[57] == 1'b1)
       (BENA => QA[57]) = (1.000, 1.000);
    if (TQA[57] == 1'b0)
       (BENA => QA[57]) = (1.000, 1.000);
    if (TQA[56] == 1'b1)
       (BENA => QA[56]) = (1.000, 1.000);
    if (TQA[56] == 1'b0)
       (BENA => QA[56]) = (1.000, 1.000);
    if (TQA[55] == 1'b1)
       (BENA => QA[55]) = (1.000, 1.000);
    if (TQA[55] == 1'b0)
       (BENA => QA[55]) = (1.000, 1.000);
    if (TQA[54] == 1'b1)
       (BENA => QA[54]) = (1.000, 1.000);
    if (TQA[54] == 1'b0)
       (BENA => QA[54]) = (1.000, 1.000);
    if (TQA[53] == 1'b1)
       (BENA => QA[53]) = (1.000, 1.000);
    if (TQA[53] == 1'b0)
       (BENA => QA[53]) = (1.000, 1.000);
    if (TQA[52] == 1'b1)
       (BENA => QA[52]) = (1.000, 1.000);
    if (TQA[52] == 1'b0)
       (BENA => QA[52]) = (1.000, 1.000);
    if (TQA[51] == 1'b1)
       (BENA => QA[51]) = (1.000, 1.000);
    if (TQA[51] == 1'b0)
       (BENA => QA[51]) = (1.000, 1.000);
    if (TQA[50] == 1'b1)
       (BENA => QA[50]) = (1.000, 1.000);
    if (TQA[50] == 1'b0)
       (BENA => QA[50]) = (1.000, 1.000);
    if (TQA[49] == 1'b1)
       (BENA => QA[49]) = (1.000, 1.000);
    if (TQA[49] == 1'b0)
       (BENA => QA[49]) = (1.000, 1.000);
    if (TQA[48] == 1'b1)
       (BENA => QA[48]) = (1.000, 1.000);
    if (TQA[48] == 1'b0)
       (BENA => QA[48]) = (1.000, 1.000);
    if (TQA[47] == 1'b1)
       (BENA => QA[47]) = (1.000, 1.000);
    if (TQA[47] == 1'b0)
       (BENA => QA[47]) = (1.000, 1.000);
    if (TQA[46] == 1'b1)
       (BENA => QA[46]) = (1.000, 1.000);
    if (TQA[46] == 1'b0)
       (BENA => QA[46]) = (1.000, 1.000);
    if (TQA[45] == 1'b1)
       (BENA => QA[45]) = (1.000, 1.000);
    if (TQA[45] == 1'b0)
       (BENA => QA[45]) = (1.000, 1.000);
    if (TQA[44] == 1'b1)
       (BENA => QA[44]) = (1.000, 1.000);
    if (TQA[44] == 1'b0)
       (BENA => QA[44]) = (1.000, 1.000);
    if (TQA[43] == 1'b1)
       (BENA => QA[43]) = (1.000, 1.000);
    if (TQA[43] == 1'b0)
       (BENA => QA[43]) = (1.000, 1.000);
    if (TQA[42] == 1'b1)
       (BENA => QA[42]) = (1.000, 1.000);
    if (TQA[42] == 1'b0)
       (BENA => QA[42]) = (1.000, 1.000);
    if (TQA[41] == 1'b1)
       (BENA => QA[41]) = (1.000, 1.000);
    if (TQA[41] == 1'b0)
       (BENA => QA[41]) = (1.000, 1.000);
    if (TQA[40] == 1'b1)
       (BENA => QA[40]) = (1.000, 1.000);
    if (TQA[40] == 1'b0)
       (BENA => QA[40]) = (1.000, 1.000);
    if (TQA[39] == 1'b1)
       (BENA => QA[39]) = (1.000, 1.000);
    if (TQA[39] == 1'b0)
       (BENA => QA[39]) = (1.000, 1.000);
    if (TQA[38] == 1'b1)
       (BENA => QA[38]) = (1.000, 1.000);
    if (TQA[38] == 1'b0)
       (BENA => QA[38]) = (1.000, 1.000);
    if (TQA[37] == 1'b1)
       (BENA => QA[37]) = (1.000, 1.000);
    if (TQA[37] == 1'b0)
       (BENA => QA[37]) = (1.000, 1.000);
    if (TQA[36] == 1'b1)
       (BENA => QA[36]) = (1.000, 1.000);
    if (TQA[36] == 1'b0)
       (BENA => QA[36]) = (1.000, 1.000);
    if (TQA[35] == 1'b1)
       (BENA => QA[35]) = (1.000, 1.000);
    if (TQA[35] == 1'b0)
       (BENA => QA[35]) = (1.000, 1.000);
    if (TQA[34] == 1'b1)
       (BENA => QA[34]) = (1.000, 1.000);
    if (TQA[34] == 1'b0)
       (BENA => QA[34]) = (1.000, 1.000);
    if (TQA[33] == 1'b1)
       (BENA => QA[33]) = (1.000, 1.000);
    if (TQA[33] == 1'b0)
       (BENA => QA[33]) = (1.000, 1.000);
    if (TQA[32] == 1'b1)
       (BENA => QA[32]) = (1.000, 1.000);
    if (TQA[32] == 1'b0)
       (BENA => QA[32]) = (1.000, 1.000);
    if (TQA[31] == 1'b1)
       (BENA => QA[31]) = (1.000, 1.000);
    if (TQA[31] == 1'b0)
       (BENA => QA[31]) = (1.000, 1.000);
    if (TQA[30] == 1'b1)
       (BENA => QA[30]) = (1.000, 1.000);
    if (TQA[30] == 1'b0)
       (BENA => QA[30]) = (1.000, 1.000);
    if (TQA[29] == 1'b1)
       (BENA => QA[29]) = (1.000, 1.000);
    if (TQA[29] == 1'b0)
       (BENA => QA[29]) = (1.000, 1.000);
    if (TQA[28] == 1'b1)
       (BENA => QA[28]) = (1.000, 1.000);
    if (TQA[28] == 1'b0)
       (BENA => QA[28]) = (1.000, 1.000);
    if (TQA[27] == 1'b1)
       (BENA => QA[27]) = (1.000, 1.000);
    if (TQA[27] == 1'b0)
       (BENA => QA[27]) = (1.000, 1.000);
    if (TQA[26] == 1'b1)
       (BENA => QA[26]) = (1.000, 1.000);
    if (TQA[26] == 1'b0)
       (BENA => QA[26]) = (1.000, 1.000);
    if (TQA[25] == 1'b1)
       (BENA => QA[25]) = (1.000, 1.000);
    if (TQA[25] == 1'b0)
       (BENA => QA[25]) = (1.000, 1.000);
    if (TQA[24] == 1'b1)
       (BENA => QA[24]) = (1.000, 1.000);
    if (TQA[24] == 1'b0)
       (BENA => QA[24]) = (1.000, 1.000);
    if (TQA[23] == 1'b1)
       (BENA => QA[23]) = (1.000, 1.000);
    if (TQA[23] == 1'b0)
       (BENA => QA[23]) = (1.000, 1.000);
    if (TQA[22] == 1'b1)
       (BENA => QA[22]) = (1.000, 1.000);
    if (TQA[22] == 1'b0)
       (BENA => QA[22]) = (1.000, 1.000);
    if (TQA[21] == 1'b1)
       (BENA => QA[21]) = (1.000, 1.000);
    if (TQA[21] == 1'b0)
       (BENA => QA[21]) = (1.000, 1.000);
    if (TQA[20] == 1'b1)
       (BENA => QA[20]) = (1.000, 1.000);
    if (TQA[20] == 1'b0)
       (BENA => QA[20]) = (1.000, 1.000);
    if (TQA[19] == 1'b1)
       (BENA => QA[19]) = (1.000, 1.000);
    if (TQA[19] == 1'b0)
       (BENA => QA[19]) = (1.000, 1.000);
    if (TQA[18] == 1'b1)
       (BENA => QA[18]) = (1.000, 1.000);
    if (TQA[18] == 1'b0)
       (BENA => QA[18]) = (1.000, 1.000);
    if (TQA[17] == 1'b1)
       (BENA => QA[17]) = (1.000, 1.000);
    if (TQA[17] == 1'b0)
       (BENA => QA[17]) = (1.000, 1.000);
    if (TQA[16] == 1'b1)
       (BENA => QA[16]) = (1.000, 1.000);
    if (TQA[16] == 1'b0)
       (BENA => QA[16]) = (1.000, 1.000);
    if (TQA[15] == 1'b1)
       (BENA => QA[15]) = (1.000, 1.000);
    if (TQA[15] == 1'b0)
       (BENA => QA[15]) = (1.000, 1.000);
    if (TQA[14] == 1'b1)
       (BENA => QA[14]) = (1.000, 1.000);
    if (TQA[14] == 1'b0)
       (BENA => QA[14]) = (1.000, 1.000);
    if (TQA[13] == 1'b1)
       (BENA => QA[13]) = (1.000, 1.000);
    if (TQA[13] == 1'b0)
       (BENA => QA[13]) = (1.000, 1.000);
    if (TQA[12] == 1'b1)
       (BENA => QA[12]) = (1.000, 1.000);
    if (TQA[12] == 1'b0)
       (BENA => QA[12]) = (1.000, 1.000);
    if (TQA[11] == 1'b1)
       (BENA => QA[11]) = (1.000, 1.000);
    if (TQA[11] == 1'b0)
       (BENA => QA[11]) = (1.000, 1.000);
    if (TQA[10] == 1'b1)
       (BENA => QA[10]) = (1.000, 1.000);
    if (TQA[10] == 1'b0)
       (BENA => QA[10]) = (1.000, 1.000);
    if (TQA[9] == 1'b1)
       (BENA => QA[9]) = (1.000, 1.000);
    if (TQA[9] == 1'b0)
       (BENA => QA[9]) = (1.000, 1.000);
    if (TQA[8] == 1'b1)
       (BENA => QA[8]) = (1.000, 1.000);
    if (TQA[8] == 1'b0)
       (BENA => QA[8]) = (1.000, 1.000);
    if (TQA[7] == 1'b1)
       (BENA => QA[7]) = (1.000, 1.000);
    if (TQA[7] == 1'b0)
       (BENA => QA[7]) = (1.000, 1.000);
    if (TQA[6] == 1'b1)
       (BENA => QA[6]) = (1.000, 1.000);
    if (TQA[6] == 1'b0)
       (BENA => QA[6]) = (1.000, 1.000);
    if (TQA[5] == 1'b1)
       (BENA => QA[5]) = (1.000, 1.000);
    if (TQA[5] == 1'b0)
       (BENA => QA[5]) = (1.000, 1.000);
    if (TQA[4] == 1'b1)
       (BENA => QA[4]) = (1.000, 1.000);
    if (TQA[4] == 1'b0)
       (BENA => QA[4]) = (1.000, 1.000);
    if (TQA[3] == 1'b1)
       (BENA => QA[3]) = (1.000, 1.000);
    if (TQA[3] == 1'b0)
       (BENA => QA[3]) = (1.000, 1.000);
    if (TQA[2] == 1'b1)
       (BENA => QA[2]) = (1.000, 1.000);
    if (TQA[2] == 1'b0)
       (BENA => QA[2]) = (1.000, 1.000);
    if (TQA[1] == 1'b1)
       (BENA => QA[1]) = (1.000, 1.000);
    if (TQA[1] == 1'b0)
       (BENA => QA[1]) = (1.000, 1.000);
    if (TQA[0] == 1'b1)
       (BENA => QA[0]) = (1.000, 1.000);
    if (TQA[0] == 1'b0)
       (BENA => QA[0]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[79] => QA[79]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[78] => QA[78]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[77] => QA[77]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[76] => QA[76]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[75] => QA[75]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[74] => QA[74]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[73] => QA[73]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[72] => QA[72]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[71] => QA[71]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[70] => QA[70]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[69] => QA[69]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[68] => QA[68]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[67] => QA[67]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[66] => QA[66]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[65] => QA[65]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[64] => QA[64]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[63] => QA[63]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[62] => QA[62]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[61] => QA[61]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[60] => QA[60]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[59] => QA[59]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[58] => QA[58]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[57] => QA[57]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[56] => QA[56]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[55] => QA[55]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[54] => QA[54]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[53] => QA[53]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[52] => QA[52]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[51] => QA[51]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[50] => QA[50]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[49] => QA[49]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[48] => QA[48]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[47] => QA[47]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[46] => QA[46]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[45] => QA[45]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[44] => QA[44]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[43] => QA[43]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[42] => QA[42]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[41] => QA[41]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[40] => QA[40]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[39] => QA[39]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[38] => QA[38]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[37] => QA[37]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[36] => QA[36]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[35] => QA[35]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[34] => QA[34]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[33] => QA[33]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[32] => QA[32]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[31] => QA[31]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[30] => QA[30]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[29] => QA[29]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[28] => QA[28]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[27] => QA[27]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[26] => QA[26]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[25] => QA[25]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[24] => QA[24]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[23] => QA[23]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[22] => QA[22]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[21] => QA[21]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[20] => QA[20]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[19] => QA[19]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[18] => QA[18]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[17] => QA[17]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[16] => QA[16]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[15] => QA[15]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[14] => QA[14]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[13] => QA[13]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[12] => QA[12]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[11] => QA[11]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[10] => QA[10]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[9] => QA[9]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[8] => QA[8]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[7] => QA[7]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[6] => QA[6]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[5] => QA[5]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[4] => QA[4]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[3] => QA[3]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[2] => QA[2]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[1] => QA[1]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[0] => QA[0]) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[79] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[78] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[77] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[76] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[75] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[74] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[73] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[72] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[71] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[70] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[69] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[68] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[67] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[66] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[65] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[64] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[63] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[62] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[61] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[60] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[59] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[58] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[57] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[56] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[55] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[54] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[53] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[52] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[51] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[50] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[49] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[48] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[47] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[46] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[45] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[44] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[43] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[42] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[41] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[40] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[39] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[38] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[37] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[36] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[35] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[34] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[33] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[32] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[31] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[30] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[29] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[28] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[27] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[26] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[25] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[24] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[23] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[22] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[21] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[20] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[19] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[18] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[17] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[16] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[15] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[14] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[13] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[12] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[11] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[10] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[9] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[8] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (TQB[79] == 1'b1)
       (BENB => QB[79]) = (1.000, 1.000);
    if (TQB[79] == 1'b0)
       (BENB => QB[79]) = (1.000, 1.000);
    if (TQB[78] == 1'b1)
       (BENB => QB[78]) = (1.000, 1.000);
    if (TQB[78] == 1'b0)
       (BENB => QB[78]) = (1.000, 1.000);
    if (TQB[77] == 1'b1)
       (BENB => QB[77]) = (1.000, 1.000);
    if (TQB[77] == 1'b0)
       (BENB => QB[77]) = (1.000, 1.000);
    if (TQB[76] == 1'b1)
       (BENB => QB[76]) = (1.000, 1.000);
    if (TQB[76] == 1'b0)
       (BENB => QB[76]) = (1.000, 1.000);
    if (TQB[75] == 1'b1)
       (BENB => QB[75]) = (1.000, 1.000);
    if (TQB[75] == 1'b0)
       (BENB => QB[75]) = (1.000, 1.000);
    if (TQB[74] == 1'b1)
       (BENB => QB[74]) = (1.000, 1.000);
    if (TQB[74] == 1'b0)
       (BENB => QB[74]) = (1.000, 1.000);
    if (TQB[73] == 1'b1)
       (BENB => QB[73]) = (1.000, 1.000);
    if (TQB[73] == 1'b0)
       (BENB => QB[73]) = (1.000, 1.000);
    if (TQB[72] == 1'b1)
       (BENB => QB[72]) = (1.000, 1.000);
    if (TQB[72] == 1'b0)
       (BENB => QB[72]) = (1.000, 1.000);
    if (TQB[71] == 1'b1)
       (BENB => QB[71]) = (1.000, 1.000);
    if (TQB[71] == 1'b0)
       (BENB => QB[71]) = (1.000, 1.000);
    if (TQB[70] == 1'b1)
       (BENB => QB[70]) = (1.000, 1.000);
    if (TQB[70] == 1'b0)
       (BENB => QB[70]) = (1.000, 1.000);
    if (TQB[69] == 1'b1)
       (BENB => QB[69]) = (1.000, 1.000);
    if (TQB[69] == 1'b0)
       (BENB => QB[69]) = (1.000, 1.000);
    if (TQB[68] == 1'b1)
       (BENB => QB[68]) = (1.000, 1.000);
    if (TQB[68] == 1'b0)
       (BENB => QB[68]) = (1.000, 1.000);
    if (TQB[67] == 1'b1)
       (BENB => QB[67]) = (1.000, 1.000);
    if (TQB[67] == 1'b0)
       (BENB => QB[67]) = (1.000, 1.000);
    if (TQB[66] == 1'b1)
       (BENB => QB[66]) = (1.000, 1.000);
    if (TQB[66] == 1'b0)
       (BENB => QB[66]) = (1.000, 1.000);
    if (TQB[65] == 1'b1)
       (BENB => QB[65]) = (1.000, 1.000);
    if (TQB[65] == 1'b0)
       (BENB => QB[65]) = (1.000, 1.000);
    if (TQB[64] == 1'b1)
       (BENB => QB[64]) = (1.000, 1.000);
    if (TQB[64] == 1'b0)
       (BENB => QB[64]) = (1.000, 1.000);
    if (TQB[63] == 1'b1)
       (BENB => QB[63]) = (1.000, 1.000);
    if (TQB[63] == 1'b0)
       (BENB => QB[63]) = (1.000, 1.000);
    if (TQB[62] == 1'b1)
       (BENB => QB[62]) = (1.000, 1.000);
    if (TQB[62] == 1'b0)
       (BENB => QB[62]) = (1.000, 1.000);
    if (TQB[61] == 1'b1)
       (BENB => QB[61]) = (1.000, 1.000);
    if (TQB[61] == 1'b0)
       (BENB => QB[61]) = (1.000, 1.000);
    if (TQB[60] == 1'b1)
       (BENB => QB[60]) = (1.000, 1.000);
    if (TQB[60] == 1'b0)
       (BENB => QB[60]) = (1.000, 1.000);
    if (TQB[59] == 1'b1)
       (BENB => QB[59]) = (1.000, 1.000);
    if (TQB[59] == 1'b0)
       (BENB => QB[59]) = (1.000, 1.000);
    if (TQB[58] == 1'b1)
       (BENB => QB[58]) = (1.000, 1.000);
    if (TQB[58] == 1'b0)
       (BENB => QB[58]) = (1.000, 1.000);
    if (TQB[57] == 1'b1)
       (BENB => QB[57]) = (1.000, 1.000);
    if (TQB[57] == 1'b0)
       (BENB => QB[57]) = (1.000, 1.000);
    if (TQB[56] == 1'b1)
       (BENB => QB[56]) = (1.000, 1.000);
    if (TQB[56] == 1'b0)
       (BENB => QB[56]) = (1.000, 1.000);
    if (TQB[55] == 1'b1)
       (BENB => QB[55]) = (1.000, 1.000);
    if (TQB[55] == 1'b0)
       (BENB => QB[55]) = (1.000, 1.000);
    if (TQB[54] == 1'b1)
       (BENB => QB[54]) = (1.000, 1.000);
    if (TQB[54] == 1'b0)
       (BENB => QB[54]) = (1.000, 1.000);
    if (TQB[53] == 1'b1)
       (BENB => QB[53]) = (1.000, 1.000);
    if (TQB[53] == 1'b0)
       (BENB => QB[53]) = (1.000, 1.000);
    if (TQB[52] == 1'b1)
       (BENB => QB[52]) = (1.000, 1.000);
    if (TQB[52] == 1'b0)
       (BENB => QB[52]) = (1.000, 1.000);
    if (TQB[51] == 1'b1)
       (BENB => QB[51]) = (1.000, 1.000);
    if (TQB[51] == 1'b0)
       (BENB => QB[51]) = (1.000, 1.000);
    if (TQB[50] == 1'b1)
       (BENB => QB[50]) = (1.000, 1.000);
    if (TQB[50] == 1'b0)
       (BENB => QB[50]) = (1.000, 1.000);
    if (TQB[49] == 1'b1)
       (BENB => QB[49]) = (1.000, 1.000);
    if (TQB[49] == 1'b0)
       (BENB => QB[49]) = (1.000, 1.000);
    if (TQB[48] == 1'b1)
       (BENB => QB[48]) = (1.000, 1.000);
    if (TQB[48] == 1'b0)
       (BENB => QB[48]) = (1.000, 1.000);
    if (TQB[47] == 1'b1)
       (BENB => QB[47]) = (1.000, 1.000);
    if (TQB[47] == 1'b0)
       (BENB => QB[47]) = (1.000, 1.000);
    if (TQB[46] == 1'b1)
       (BENB => QB[46]) = (1.000, 1.000);
    if (TQB[46] == 1'b0)
       (BENB => QB[46]) = (1.000, 1.000);
    if (TQB[45] == 1'b1)
       (BENB => QB[45]) = (1.000, 1.000);
    if (TQB[45] == 1'b0)
       (BENB => QB[45]) = (1.000, 1.000);
    if (TQB[44] == 1'b1)
       (BENB => QB[44]) = (1.000, 1.000);
    if (TQB[44] == 1'b0)
       (BENB => QB[44]) = (1.000, 1.000);
    if (TQB[43] == 1'b1)
       (BENB => QB[43]) = (1.000, 1.000);
    if (TQB[43] == 1'b0)
       (BENB => QB[43]) = (1.000, 1.000);
    if (TQB[42] == 1'b1)
       (BENB => QB[42]) = (1.000, 1.000);
    if (TQB[42] == 1'b0)
       (BENB => QB[42]) = (1.000, 1.000);
    if (TQB[41] == 1'b1)
       (BENB => QB[41]) = (1.000, 1.000);
    if (TQB[41] == 1'b0)
       (BENB => QB[41]) = (1.000, 1.000);
    if (TQB[40] == 1'b1)
       (BENB => QB[40]) = (1.000, 1.000);
    if (TQB[40] == 1'b0)
       (BENB => QB[40]) = (1.000, 1.000);
    if (TQB[39] == 1'b1)
       (BENB => QB[39]) = (1.000, 1.000);
    if (TQB[39] == 1'b0)
       (BENB => QB[39]) = (1.000, 1.000);
    if (TQB[38] == 1'b1)
       (BENB => QB[38]) = (1.000, 1.000);
    if (TQB[38] == 1'b0)
       (BENB => QB[38]) = (1.000, 1.000);
    if (TQB[37] == 1'b1)
       (BENB => QB[37]) = (1.000, 1.000);
    if (TQB[37] == 1'b0)
       (BENB => QB[37]) = (1.000, 1.000);
    if (TQB[36] == 1'b1)
       (BENB => QB[36]) = (1.000, 1.000);
    if (TQB[36] == 1'b0)
       (BENB => QB[36]) = (1.000, 1.000);
    if (TQB[35] == 1'b1)
       (BENB => QB[35]) = (1.000, 1.000);
    if (TQB[35] == 1'b0)
       (BENB => QB[35]) = (1.000, 1.000);
    if (TQB[34] == 1'b1)
       (BENB => QB[34]) = (1.000, 1.000);
    if (TQB[34] == 1'b0)
       (BENB => QB[34]) = (1.000, 1.000);
    if (TQB[33] == 1'b1)
       (BENB => QB[33]) = (1.000, 1.000);
    if (TQB[33] == 1'b0)
       (BENB => QB[33]) = (1.000, 1.000);
    if (TQB[32] == 1'b1)
       (BENB => QB[32]) = (1.000, 1.000);
    if (TQB[32] == 1'b0)
       (BENB => QB[32]) = (1.000, 1.000);
    if (TQB[31] == 1'b1)
       (BENB => QB[31]) = (1.000, 1.000);
    if (TQB[31] == 1'b0)
       (BENB => QB[31]) = (1.000, 1.000);
    if (TQB[30] == 1'b1)
       (BENB => QB[30]) = (1.000, 1.000);
    if (TQB[30] == 1'b0)
       (BENB => QB[30]) = (1.000, 1.000);
    if (TQB[29] == 1'b1)
       (BENB => QB[29]) = (1.000, 1.000);
    if (TQB[29] == 1'b0)
       (BENB => QB[29]) = (1.000, 1.000);
    if (TQB[28] == 1'b1)
       (BENB => QB[28]) = (1.000, 1.000);
    if (TQB[28] == 1'b0)
       (BENB => QB[28]) = (1.000, 1.000);
    if (TQB[27] == 1'b1)
       (BENB => QB[27]) = (1.000, 1.000);
    if (TQB[27] == 1'b0)
       (BENB => QB[27]) = (1.000, 1.000);
    if (TQB[26] == 1'b1)
       (BENB => QB[26]) = (1.000, 1.000);
    if (TQB[26] == 1'b0)
       (BENB => QB[26]) = (1.000, 1.000);
    if (TQB[25] == 1'b1)
       (BENB => QB[25]) = (1.000, 1.000);
    if (TQB[25] == 1'b0)
       (BENB => QB[25]) = (1.000, 1.000);
    if (TQB[24] == 1'b1)
       (BENB => QB[24]) = (1.000, 1.000);
    if (TQB[24] == 1'b0)
       (BENB => QB[24]) = (1.000, 1.000);
    if (TQB[23] == 1'b1)
       (BENB => QB[23]) = (1.000, 1.000);
    if (TQB[23] == 1'b0)
       (BENB => QB[23]) = (1.000, 1.000);
    if (TQB[22] == 1'b1)
       (BENB => QB[22]) = (1.000, 1.000);
    if (TQB[22] == 1'b0)
       (BENB => QB[22]) = (1.000, 1.000);
    if (TQB[21] == 1'b1)
       (BENB => QB[21]) = (1.000, 1.000);
    if (TQB[21] == 1'b0)
       (BENB => QB[21]) = (1.000, 1.000);
    if (TQB[20] == 1'b1)
       (BENB => QB[20]) = (1.000, 1.000);
    if (TQB[20] == 1'b0)
       (BENB => QB[20]) = (1.000, 1.000);
    if (TQB[19] == 1'b1)
       (BENB => QB[19]) = (1.000, 1.000);
    if (TQB[19] == 1'b0)
       (BENB => QB[19]) = (1.000, 1.000);
    if (TQB[18] == 1'b1)
       (BENB => QB[18]) = (1.000, 1.000);
    if (TQB[18] == 1'b0)
       (BENB => QB[18]) = (1.000, 1.000);
    if (TQB[17] == 1'b1)
       (BENB => QB[17]) = (1.000, 1.000);
    if (TQB[17] == 1'b0)
       (BENB => QB[17]) = (1.000, 1.000);
    if (TQB[16] == 1'b1)
       (BENB => QB[16]) = (1.000, 1.000);
    if (TQB[16] == 1'b0)
       (BENB => QB[16]) = (1.000, 1.000);
    if (TQB[15] == 1'b1)
       (BENB => QB[15]) = (1.000, 1.000);
    if (TQB[15] == 1'b0)
       (BENB => QB[15]) = (1.000, 1.000);
    if (TQB[14] == 1'b1)
       (BENB => QB[14]) = (1.000, 1.000);
    if (TQB[14] == 1'b0)
       (BENB => QB[14]) = (1.000, 1.000);
    if (TQB[13] == 1'b1)
       (BENB => QB[13]) = (1.000, 1.000);
    if (TQB[13] == 1'b0)
       (BENB => QB[13]) = (1.000, 1.000);
    if (TQB[12] == 1'b1)
       (BENB => QB[12]) = (1.000, 1.000);
    if (TQB[12] == 1'b0)
       (BENB => QB[12]) = (1.000, 1.000);
    if (TQB[11] == 1'b1)
       (BENB => QB[11]) = (1.000, 1.000);
    if (TQB[11] == 1'b0)
       (BENB => QB[11]) = (1.000, 1.000);
    if (TQB[10] == 1'b1)
       (BENB => QB[10]) = (1.000, 1.000);
    if (TQB[10] == 1'b0)
       (BENB => QB[10]) = (1.000, 1.000);
    if (TQB[9] == 1'b1)
       (BENB => QB[9]) = (1.000, 1.000);
    if (TQB[9] == 1'b0)
       (BENB => QB[9]) = (1.000, 1.000);
    if (TQB[8] == 1'b1)
       (BENB => QB[8]) = (1.000, 1.000);
    if (TQB[8] == 1'b0)
       (BENB => QB[8]) = (1.000, 1.000);
    if (TQB[7] == 1'b1)
       (BENB => QB[7]) = (1.000, 1.000);
    if (TQB[7] == 1'b0)
       (BENB => QB[7]) = (1.000, 1.000);
    if (TQB[6] == 1'b1)
       (BENB => QB[6]) = (1.000, 1.000);
    if (TQB[6] == 1'b0)
       (BENB => QB[6]) = (1.000, 1.000);
    if (TQB[5] == 1'b1)
       (BENB => QB[5]) = (1.000, 1.000);
    if (TQB[5] == 1'b0)
       (BENB => QB[5]) = (1.000, 1.000);
    if (TQB[4] == 1'b1)
       (BENB => QB[4]) = (1.000, 1.000);
    if (TQB[4] == 1'b0)
       (BENB => QB[4]) = (1.000, 1.000);
    if (TQB[3] == 1'b1)
       (BENB => QB[3]) = (1.000, 1.000);
    if (TQB[3] == 1'b0)
       (BENB => QB[3]) = (1.000, 1.000);
    if (TQB[2] == 1'b1)
       (BENB => QB[2]) = (1.000, 1.000);
    if (TQB[2] == 1'b0)
       (BENB => QB[2]) = (1.000, 1.000);
    if (TQB[1] == 1'b1)
       (BENB => QB[1]) = (1.000, 1.000);
    if (TQB[1] == 1'b0)
       (BENB => QB[1]) = (1.000, 1.000);
    if (TQB[0] == 1'b1)
       (BENB => QB[0]) = (1.000, 1.000);
    if (TQB[0] == 1'b0)
       (BENB => QB[0]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[79] => QB[79]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[78] => QB[78]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[77] => QB[77]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[76] => QB[76]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[75] => QB[75]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[74] => QB[74]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[73] => QB[73]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[72] => QB[72]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[71] => QB[71]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[70] => QB[70]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[69] => QB[69]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[68] => QB[68]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[67] => QB[67]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[66] => QB[66]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[65] => QB[65]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[64] => QB[64]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[63] => QB[63]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[62] => QB[62]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[61] => QB[61]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[60] => QB[60]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[59] => QB[59]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[58] => QB[58]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[57] => QB[57]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[56] => QB[56]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[55] => QB[55]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[54] => QB[54]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[53] => QB[53]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[52] => QB[52]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[51] => QB[51]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[50] => QB[50]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[49] => QB[49]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[48] => QB[48]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[47] => QB[47]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[46] => QB[46]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[45] => QB[45]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[44] => QB[44]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[43] => QB[43]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[42] => QB[42]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[41] => QB[41]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[40] => QB[40]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[39] => QB[39]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[38] => QB[38]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[37] => QB[37]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[36] => QB[36]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[35] => QB[35]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[34] => QB[34]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[33] => QB[33]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[32] => QB[32]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[31] => QB[31]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[30] => QB[30]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[29] => QB[29]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[28] => QB[28]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[27] => QB[27]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[26] => QB[26]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[25] => QB[25]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[24] => QB[24]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[23] => QB[23]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[22] => QB[22]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[21] => QB[21]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[20] => QB[20]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[19] => QB[19]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[18] => QB[18]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[17] => QB[17]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[16] => QB[16]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[15] => QB[15]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[14] => QB[14]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[13] => QB[13]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[12] => QB[12]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[11] => QB[11]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[10] => QB[10]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[9] => QB[9]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[8] => QB[8]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[7] => QB[7]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[6] => QB[6]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[5] => QB[5]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[4] => QB[4]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[3] => QB[3]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[2] => QB[2]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[1] => QB[1]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[0] => QB[0]) = (1.000, 1.000);

    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);

// Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge CLKA, 3.000, NOT_CLKA_PER);
   `else
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(negedge CLKA &&& STOVAeq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(negedge CLKA &&& STOVAeq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
   `endif

// Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge CLKA, 1.000, 0, NOT_CLKA_MINH);
       $width(negedge CLKA, 1.000, 0, NOT_CLKA_MINL);
   `else
       $width(posedge CLKA &&& STOVAeq0, 1.000, 0, NOT_CLKA_MINH);
       $width(negedge CLKA &&& STOVAeq0, 1.000, 0, NOT_CLKA_MINL);
       $width(posedge CLKA &&& STOVAeq1andEMASAeq0, 1.000, 0, NOT_CLKA_MINH);
       $width(negedge CLKA &&& STOVAeq1andEMASAeq0, 1.000, 0, NOT_CLKA_MINL);
       $width(posedge CLKA &&& STOVAeq1andEMASAeq1, 1.000, 0, NOT_CLKA_MINH);
       $width(negedge CLKA &&& STOVAeq1andEMASAeq1, 1.000, 0, NOT_CLKA_MINL);
   `endif

    $setuphold(posedge CLKA &&& TENAeq1, posedge CENA, 1.000, 0.500, NOT_CENA);
    $setuphold(posedge CLKA &&& TENAeq1, negedge CENA, 1.000, 0.500, NOT_CENA);
    $setuphold(posedge RET1N &&& TENAeq1, negedge CENA, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge WENA, 1.000, 0.500, NOT_WENA);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge WENA, 1.000, 0.500, NOT_WENA);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[10], 1.000, 0.500, NOT_AA10);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[9], 1.000, 0.500, NOT_AA9);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[8], 1.000, 0.500, NOT_AA8);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[7], 1.000, 0.500, NOT_AA7);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[6], 1.000, 0.500, NOT_AA6);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[5], 1.000, 0.500, NOT_AA5);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[4], 1.000, 0.500, NOT_AA4);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[3], 1.000, 0.500, NOT_AA3);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[2], 1.000, 0.500, NOT_AA2);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[1], 1.000, 0.500, NOT_AA1);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[0], 1.000, 0.500, NOT_AA0);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[10], 1.000, 0.500, NOT_AA10);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[9], 1.000, 0.500, NOT_AA9);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[8], 1.000, 0.500, NOT_AA8);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[7], 1.000, 0.500, NOT_AA7);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[6], 1.000, 0.500, NOT_AA6);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[5], 1.000, 0.500, NOT_AA5);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[4], 1.000, 0.500, NOT_AA4);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[3], 1.000, 0.500, NOT_AA3);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[2], 1.000, 0.500, NOT_AA2);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[1], 1.000, 0.500, NOT_AA1);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[0], 1.000, 0.500, NOT_AA0);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[79], 1.000, 0.500, NOT_DA79);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[78], 1.000, 0.500, NOT_DA78);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[77], 1.000, 0.500, NOT_DA77);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[76], 1.000, 0.500, NOT_DA76);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[75], 1.000, 0.500, NOT_DA75);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[74], 1.000, 0.500, NOT_DA74);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[73], 1.000, 0.500, NOT_DA73);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[72], 1.000, 0.500, NOT_DA72);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[71], 1.000, 0.500, NOT_DA71);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[70], 1.000, 0.500, NOT_DA70);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[69], 1.000, 0.500, NOT_DA69);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[68], 1.000, 0.500, NOT_DA68);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[67], 1.000, 0.500, NOT_DA67);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[66], 1.000, 0.500, NOT_DA66);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[65], 1.000, 0.500, NOT_DA65);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[64], 1.000, 0.500, NOT_DA64);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[63], 1.000, 0.500, NOT_DA63);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[62], 1.000, 0.500, NOT_DA62);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[61], 1.000, 0.500, NOT_DA61);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[60], 1.000, 0.500, NOT_DA60);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[59], 1.000, 0.500, NOT_DA59);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[58], 1.000, 0.500, NOT_DA58);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[57], 1.000, 0.500, NOT_DA57);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[56], 1.000, 0.500, NOT_DA56);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[55], 1.000, 0.500, NOT_DA55);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[54], 1.000, 0.500, NOT_DA54);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[53], 1.000, 0.500, NOT_DA53);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[52], 1.000, 0.500, NOT_DA52);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[51], 1.000, 0.500, NOT_DA51);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[50], 1.000, 0.500, NOT_DA50);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[49], 1.000, 0.500, NOT_DA49);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[48], 1.000, 0.500, NOT_DA48);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[47], 1.000, 0.500, NOT_DA47);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[46], 1.000, 0.500, NOT_DA46);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[45], 1.000, 0.500, NOT_DA45);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[44], 1.000, 0.500, NOT_DA44);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[43], 1.000, 0.500, NOT_DA43);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[42], 1.000, 0.500, NOT_DA42);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[41], 1.000, 0.500, NOT_DA41);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[40], 1.000, 0.500, NOT_DA40);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[39], 1.000, 0.500, NOT_DA39);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[38], 1.000, 0.500, NOT_DA38);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[37], 1.000, 0.500, NOT_DA37);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[36], 1.000, 0.500, NOT_DA36);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[35], 1.000, 0.500, NOT_DA35);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[34], 1.000, 0.500, NOT_DA34);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[33], 1.000, 0.500, NOT_DA33);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[32], 1.000, 0.500, NOT_DA32);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[31], 1.000, 0.500, NOT_DA31);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[30], 1.000, 0.500, NOT_DA30);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[29], 1.000, 0.500, NOT_DA29);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[28], 1.000, 0.500, NOT_DA28);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[27], 1.000, 0.500, NOT_DA27);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[26], 1.000, 0.500, NOT_DA26);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[25], 1.000, 0.500, NOT_DA25);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[24], 1.000, 0.500, NOT_DA24);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[23], 1.000, 0.500, NOT_DA23);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[22], 1.000, 0.500, NOT_DA22);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[21], 1.000, 0.500, NOT_DA21);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[20], 1.000, 0.500, NOT_DA20);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[19], 1.000, 0.500, NOT_DA19);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[18], 1.000, 0.500, NOT_DA18);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[17], 1.000, 0.500, NOT_DA17);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[16], 1.000, 0.500, NOT_DA16);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[15], 1.000, 0.500, NOT_DA15);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[14], 1.000, 0.500, NOT_DA14);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[13], 1.000, 0.500, NOT_DA13);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[12], 1.000, 0.500, NOT_DA12);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[11], 1.000, 0.500, NOT_DA11);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[10], 1.000, 0.500, NOT_DA10);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[9], 1.000, 0.500, NOT_DA9);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[8], 1.000, 0.500, NOT_DA8);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[7], 1.000, 0.500, NOT_DA7);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[6], 1.000, 0.500, NOT_DA6);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[5], 1.000, 0.500, NOT_DA5);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[4], 1.000, 0.500, NOT_DA4);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[3], 1.000, 0.500, NOT_DA3);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[2], 1.000, 0.500, NOT_DA2);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[1], 1.000, 0.500, NOT_DA1);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[0], 1.000, 0.500, NOT_DA0);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[79], 1.000, 0.500, NOT_DA79);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[78], 1.000, 0.500, NOT_DA78);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[77], 1.000, 0.500, NOT_DA77);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[76], 1.000, 0.500, NOT_DA76);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[75], 1.000, 0.500, NOT_DA75);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[74], 1.000, 0.500, NOT_DA74);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[73], 1.000, 0.500, NOT_DA73);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[72], 1.000, 0.500, NOT_DA72);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[71], 1.000, 0.500, NOT_DA71);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[70], 1.000, 0.500, NOT_DA70);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[69], 1.000, 0.500, NOT_DA69);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[68], 1.000, 0.500, NOT_DA68);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[67], 1.000, 0.500, NOT_DA67);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[66], 1.000, 0.500, NOT_DA66);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[65], 1.000, 0.500, NOT_DA65);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[64], 1.000, 0.500, NOT_DA64);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[63], 1.000, 0.500, NOT_DA63);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[62], 1.000, 0.500, NOT_DA62);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[61], 1.000, 0.500, NOT_DA61);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[60], 1.000, 0.500, NOT_DA60);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[59], 1.000, 0.500, NOT_DA59);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[58], 1.000, 0.500, NOT_DA58);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[57], 1.000, 0.500, NOT_DA57);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[56], 1.000, 0.500, NOT_DA56);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[55], 1.000, 0.500, NOT_DA55);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[54], 1.000, 0.500, NOT_DA54);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[53], 1.000, 0.500, NOT_DA53);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[52], 1.000, 0.500, NOT_DA52);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[51], 1.000, 0.500, NOT_DA51);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[50], 1.000, 0.500, NOT_DA50);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[49], 1.000, 0.500, NOT_DA49);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[48], 1.000, 0.500, NOT_DA48);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[47], 1.000, 0.500, NOT_DA47);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[46], 1.000, 0.500, NOT_DA46);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[45], 1.000, 0.500, NOT_DA45);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[44], 1.000, 0.500, NOT_DA44);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[43], 1.000, 0.500, NOT_DA43);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[42], 1.000, 0.500, NOT_DA42);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[41], 1.000, 0.500, NOT_DA41);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[40], 1.000, 0.500, NOT_DA40);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[39], 1.000, 0.500, NOT_DA39);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[38], 1.000, 0.500, NOT_DA38);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[37], 1.000, 0.500, NOT_DA37);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[36], 1.000, 0.500, NOT_DA36);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[35], 1.000, 0.500, NOT_DA35);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[34], 1.000, 0.500, NOT_DA34);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[33], 1.000, 0.500, NOT_DA33);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[32], 1.000, 0.500, NOT_DA32);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[31], 1.000, 0.500, NOT_DA31);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[30], 1.000, 0.500, NOT_DA30);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[29], 1.000, 0.500, NOT_DA29);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[28], 1.000, 0.500, NOT_DA28);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[27], 1.000, 0.500, NOT_DA27);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[26], 1.000, 0.500, NOT_DA26);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[25], 1.000, 0.500, NOT_DA25);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[24], 1.000, 0.500, NOT_DA24);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[23], 1.000, 0.500, NOT_DA23);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[22], 1.000, 0.500, NOT_DA22);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[21], 1.000, 0.500, NOT_DA21);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[20], 1.000, 0.500, NOT_DA20);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[19], 1.000, 0.500, NOT_DA19);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[18], 1.000, 0.500, NOT_DA18);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[17], 1.000, 0.500, NOT_DA17);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[16], 1.000, 0.500, NOT_DA16);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[15], 1.000, 0.500, NOT_DA15);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[14], 1.000, 0.500, NOT_DA14);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[13], 1.000, 0.500, NOT_DA13);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[12], 1.000, 0.500, NOT_DA12);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[11], 1.000, 0.500, NOT_DA11);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[10], 1.000, 0.500, NOT_DA10);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[9], 1.000, 0.500, NOT_DA9);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[8], 1.000, 0.500, NOT_DA8);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[7], 1.000, 0.500, NOT_DA7);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[6], 1.000, 0.500, NOT_DA6);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[5], 1.000, 0.500, NOT_DA5);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[4], 1.000, 0.500, NOT_DA4);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[3], 1.000, 0.500, NOT_DA3);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[2], 1.000, 0.500, NOT_DA2);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[1], 1.000, 0.500, NOT_DA1);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[0], 1.000, 0.500, NOT_DA0);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);

// Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge CLKB, 3.000, NOT_CLKB_PER);
   `else
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(negedge CLKB &&& STOVBeq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(negedge CLKB &&& STOVBeq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
   `endif

// Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge CLKB, 1.000, 0, NOT_CLKB_MINH);
       $width(negedge CLKB, 1.000, 0, NOT_CLKB_MINL);
   `else
       $width(posedge CLKB &&& STOVBeq0, 1.000, 0, NOT_CLKB_MINH);
       $width(negedge CLKB &&& STOVBeq0, 1.000, 0, NOT_CLKB_MINL);
       $width(posedge CLKB &&& STOVBeq1andEMASBeq0, 1.000, 0, NOT_CLKB_MINH);
       $width(negedge CLKB &&& STOVBeq1andEMASBeq0, 1.000, 0, NOT_CLKB_MINL);
       $width(posedge CLKB &&& STOVBeq1andEMASBeq1, 1.000, 0, NOT_CLKB_MINH);
       $width(negedge CLKB &&& STOVBeq1andEMASBeq1, 1.000, 0, NOT_CLKB_MINL);
   `endif

    $setuphold(posedge CLKB &&& TENBeq1, posedge CENB, 1.000, 0.500, NOT_CENB);
    $setuphold(posedge CLKB &&& TENBeq1, negedge CENB, 1.000, 0.500, NOT_CENB);
    $setuphold(posedge RET1N &&& TENBeq1, negedge CENB, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge WENB, 1.000, 0.500, NOT_WENB);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge WENB, 1.000, 0.500, NOT_WENB);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[10], 1.000, 0.500, NOT_AB10);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[9], 1.000, 0.500, NOT_AB9);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[8], 1.000, 0.500, NOT_AB8);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[7], 1.000, 0.500, NOT_AB7);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[6], 1.000, 0.500, NOT_AB6);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[5], 1.000, 0.500, NOT_AB5);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[4], 1.000, 0.500, NOT_AB4);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[3], 1.000, 0.500, NOT_AB3);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[2], 1.000, 0.500, NOT_AB2);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[1], 1.000, 0.500, NOT_AB1);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[0], 1.000, 0.500, NOT_AB0);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[10], 1.000, 0.500, NOT_AB10);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[9], 1.000, 0.500, NOT_AB9);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[8], 1.000, 0.500, NOT_AB8);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[7], 1.000, 0.500, NOT_AB7);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[6], 1.000, 0.500, NOT_AB6);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[5], 1.000, 0.500, NOT_AB5);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[4], 1.000, 0.500, NOT_AB4);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[3], 1.000, 0.500, NOT_AB3);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[2], 1.000, 0.500, NOT_AB2);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[1], 1.000, 0.500, NOT_AB1);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[0], 1.000, 0.500, NOT_AB0);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[79], 1.000, 0.500, NOT_DB79);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[78], 1.000, 0.500, NOT_DB78);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[77], 1.000, 0.500, NOT_DB77);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[76], 1.000, 0.500, NOT_DB76);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[75], 1.000, 0.500, NOT_DB75);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[74], 1.000, 0.500, NOT_DB74);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[73], 1.000, 0.500, NOT_DB73);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[72], 1.000, 0.500, NOT_DB72);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[71], 1.000, 0.500, NOT_DB71);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[70], 1.000, 0.500, NOT_DB70);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[69], 1.000, 0.500, NOT_DB69);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[68], 1.000, 0.500, NOT_DB68);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[67], 1.000, 0.500, NOT_DB67);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[66], 1.000, 0.500, NOT_DB66);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[65], 1.000, 0.500, NOT_DB65);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[64], 1.000, 0.500, NOT_DB64);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[63], 1.000, 0.500, NOT_DB63);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[62], 1.000, 0.500, NOT_DB62);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[61], 1.000, 0.500, NOT_DB61);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[60], 1.000, 0.500, NOT_DB60);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[59], 1.000, 0.500, NOT_DB59);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[58], 1.000, 0.500, NOT_DB58);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[57], 1.000, 0.500, NOT_DB57);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[56], 1.000, 0.500, NOT_DB56);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[55], 1.000, 0.500, NOT_DB55);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[54], 1.000, 0.500, NOT_DB54);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[53], 1.000, 0.500, NOT_DB53);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[52], 1.000, 0.500, NOT_DB52);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[51], 1.000, 0.500, NOT_DB51);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[50], 1.000, 0.500, NOT_DB50);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[49], 1.000, 0.500, NOT_DB49);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[48], 1.000, 0.500, NOT_DB48);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[47], 1.000, 0.500, NOT_DB47);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[46], 1.000, 0.500, NOT_DB46);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[45], 1.000, 0.500, NOT_DB45);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[44], 1.000, 0.500, NOT_DB44);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[43], 1.000, 0.500, NOT_DB43);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[42], 1.000, 0.500, NOT_DB42);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[41], 1.000, 0.500, NOT_DB41);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[40], 1.000, 0.500, NOT_DB40);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[39], 1.000, 0.500, NOT_DB39);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[38], 1.000, 0.500, NOT_DB38);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[37], 1.000, 0.500, NOT_DB37);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[36], 1.000, 0.500, NOT_DB36);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[35], 1.000, 0.500, NOT_DB35);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[34], 1.000, 0.500, NOT_DB34);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[33], 1.000, 0.500, NOT_DB33);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[32], 1.000, 0.500, NOT_DB32);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[31], 1.000, 0.500, NOT_DB31);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[30], 1.000, 0.500, NOT_DB30);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[29], 1.000, 0.500, NOT_DB29);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[28], 1.000, 0.500, NOT_DB28);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[27], 1.000, 0.500, NOT_DB27);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[26], 1.000, 0.500, NOT_DB26);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[25], 1.000, 0.500, NOT_DB25);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[24], 1.000, 0.500, NOT_DB24);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[23], 1.000, 0.500, NOT_DB23);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[22], 1.000, 0.500, NOT_DB22);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[21], 1.000, 0.500, NOT_DB21);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[20], 1.000, 0.500, NOT_DB20);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[19], 1.000, 0.500, NOT_DB19);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[18], 1.000, 0.500, NOT_DB18);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[17], 1.000, 0.500, NOT_DB17);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[16], 1.000, 0.500, NOT_DB16);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[15], 1.000, 0.500, NOT_DB15);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[14], 1.000, 0.500, NOT_DB14);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[13], 1.000, 0.500, NOT_DB13);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[12], 1.000, 0.500, NOT_DB12);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[11], 1.000, 0.500, NOT_DB11);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[10], 1.000, 0.500, NOT_DB10);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[9], 1.000, 0.500, NOT_DB9);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[8], 1.000, 0.500, NOT_DB8);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[7], 1.000, 0.500, NOT_DB7);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[6], 1.000, 0.500, NOT_DB6);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[5], 1.000, 0.500, NOT_DB5);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[4], 1.000, 0.500, NOT_DB4);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[3], 1.000, 0.500, NOT_DB3);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[2], 1.000, 0.500, NOT_DB2);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[1], 1.000, 0.500, NOT_DB1);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[0], 1.000, 0.500, NOT_DB0);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[79], 1.000, 0.500, NOT_DB79);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[78], 1.000, 0.500, NOT_DB78);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[77], 1.000, 0.500, NOT_DB77);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[76], 1.000, 0.500, NOT_DB76);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[75], 1.000, 0.500, NOT_DB75);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[74], 1.000, 0.500, NOT_DB74);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[73], 1.000, 0.500, NOT_DB73);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[72], 1.000, 0.500, NOT_DB72);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[71], 1.000, 0.500, NOT_DB71);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[70], 1.000, 0.500, NOT_DB70);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[69], 1.000, 0.500, NOT_DB69);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[68], 1.000, 0.500, NOT_DB68);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[67], 1.000, 0.500, NOT_DB67);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[66], 1.000, 0.500, NOT_DB66);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[65], 1.000, 0.500, NOT_DB65);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[64], 1.000, 0.500, NOT_DB64);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[63], 1.000, 0.500, NOT_DB63);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[62], 1.000, 0.500, NOT_DB62);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[61], 1.000, 0.500, NOT_DB61);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[60], 1.000, 0.500, NOT_DB60);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[59], 1.000, 0.500, NOT_DB59);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[58], 1.000, 0.500, NOT_DB58);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[57], 1.000, 0.500, NOT_DB57);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[56], 1.000, 0.500, NOT_DB56);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[55], 1.000, 0.500, NOT_DB55);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[54], 1.000, 0.500, NOT_DB54);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[53], 1.000, 0.500, NOT_DB53);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[52], 1.000, 0.500, NOT_DB52);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[51], 1.000, 0.500, NOT_DB51);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[50], 1.000, 0.500, NOT_DB50);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[49], 1.000, 0.500, NOT_DB49);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[48], 1.000, 0.500, NOT_DB48);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[47], 1.000, 0.500, NOT_DB47);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[46], 1.000, 0.500, NOT_DB46);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[45], 1.000, 0.500, NOT_DB45);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[44], 1.000, 0.500, NOT_DB44);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[43], 1.000, 0.500, NOT_DB43);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[42], 1.000, 0.500, NOT_DB42);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[41], 1.000, 0.500, NOT_DB41);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[40], 1.000, 0.500, NOT_DB40);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[39], 1.000, 0.500, NOT_DB39);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[38], 1.000, 0.500, NOT_DB38);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[37], 1.000, 0.500, NOT_DB37);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[36], 1.000, 0.500, NOT_DB36);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[35], 1.000, 0.500, NOT_DB35);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[34], 1.000, 0.500, NOT_DB34);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[33], 1.000, 0.500, NOT_DB33);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[32], 1.000, 0.500, NOT_DB32);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[31], 1.000, 0.500, NOT_DB31);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[30], 1.000, 0.500, NOT_DB30);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[29], 1.000, 0.500, NOT_DB29);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[28], 1.000, 0.500, NOT_DB28);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[27], 1.000, 0.500, NOT_DB27);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[26], 1.000, 0.500, NOT_DB26);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[25], 1.000, 0.500, NOT_DB25);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[24], 1.000, 0.500, NOT_DB24);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[23], 1.000, 0.500, NOT_DB23);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[22], 1.000, 0.500, NOT_DB22);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[21], 1.000, 0.500, NOT_DB21);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[20], 1.000, 0.500, NOT_DB20);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[19], 1.000, 0.500, NOT_DB19);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[18], 1.000, 0.500, NOT_DB18);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[17], 1.000, 0.500, NOT_DB17);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[16], 1.000, 0.500, NOT_DB16);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[15], 1.000, 0.500, NOT_DB15);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[14], 1.000, 0.500, NOT_DB14);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[13], 1.000, 0.500, NOT_DB13);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[12], 1.000, 0.500, NOT_DB12);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[11], 1.000, 0.500, NOT_DB11);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[10], 1.000, 0.500, NOT_DB10);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[9], 1.000, 0.500, NOT_DB9);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[8], 1.000, 0.500, NOT_DB8);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[7], 1.000, 0.500, NOT_DB7);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[6], 1.000, 0.500, NOT_DB6);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[5], 1.000, 0.500, NOT_DB5);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[4], 1.000, 0.500, NOT_DB4);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[3], 1.000, 0.500, NOT_DB3);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[2], 1.000, 0.500, NOT_DB2);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[1], 1.000, 0.500, NOT_DB1);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[0], 1.000, 0.500, NOT_DB0);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge EMAA[2], 1.000, 0.500, NOT_EMAA2);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge EMAA[1], 1.000, 0.500, NOT_EMAA1);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge EMAA[0], 1.000, 0.500, NOT_EMAA0);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge EMAA[2], 1.000, 0.500, NOT_EMAA2);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge EMAA[1], 1.000, 0.500, NOT_EMAA1);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge EMAA[0], 1.000, 0.500, NOT_EMAA0);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge EMAWA[1], 1.000, 0.500, NOT_EMAWA1);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge EMAWA[0], 1.000, 0.500, NOT_EMAWA0);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge EMAWA[1], 1.000, 0.500, NOT_EMAWA1);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge EMAWA[0], 1.000, 0.500, NOT_EMAWA0);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge EMASA, 1.000, 0.500, NOT_EMASA);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge EMASA, 1.000, 0.500, NOT_EMASA);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge EMAB[2], 1.000, 0.500, NOT_EMAB2);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge EMAB[1], 1.000, 0.500, NOT_EMAB1);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge EMAB[0], 1.000, 0.500, NOT_EMAB0);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge EMAB[2], 1.000, 0.500, NOT_EMAB2);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge EMAB[1], 1.000, 0.500, NOT_EMAB1);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge EMAB[0], 1.000, 0.500, NOT_EMAB0);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge EMAWB[1], 1.000, 0.500, NOT_EMAWB1);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge EMAWB[0], 1.000, 0.500, NOT_EMAWB0);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge EMAWB[1], 1.000, 0.500, NOT_EMAWB1);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge EMAWB[0], 1.000, 0.500, NOT_EMAWB0);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge EMASB, 1.000, 0.500, NOT_EMASB);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge EMASB, 1.000, 0.500, NOT_EMASB);
    $setuphold(posedge CLKA, posedge TENA, 1.000, 0.500, NOT_TENA);
    $setuphold(posedge CLKA, negedge TENA, 1.000, 0.500, NOT_TENA);
    $setuphold(posedge CLKA &&& TENAeq0, posedge TCENA, 1.000, 0.500, NOT_TCENA);
    $setuphold(posedge CLKA &&& TENAeq0, negedge TCENA, 1.000, 0.500, NOT_TCENA);
    $setuphold(posedge RET1N &&& TENAeq0, negedge TCENA, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TWENA, 1.000, 0.500, NOT_TWENA);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TWENA, 1.000, 0.500, NOT_TWENA);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[10], 1.000, 0.500, NOT_TAA10);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[9], 1.000, 0.500, NOT_TAA9);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[8], 1.000, 0.500, NOT_TAA8);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[7], 1.000, 0.500, NOT_TAA7);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[6], 1.000, 0.500, NOT_TAA6);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[5], 1.000, 0.500, NOT_TAA5);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[4], 1.000, 0.500, NOT_TAA4);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[3], 1.000, 0.500, NOT_TAA3);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[2], 1.000, 0.500, NOT_TAA2);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[1], 1.000, 0.500, NOT_TAA1);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[0], 1.000, 0.500, NOT_TAA0);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[10], 1.000, 0.500, NOT_TAA10);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[9], 1.000, 0.500, NOT_TAA9);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[8], 1.000, 0.500, NOT_TAA8);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[7], 1.000, 0.500, NOT_TAA7);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[6], 1.000, 0.500, NOT_TAA6);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[5], 1.000, 0.500, NOT_TAA5);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[4], 1.000, 0.500, NOT_TAA4);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[3], 1.000, 0.500, NOT_TAA3);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[2], 1.000, 0.500, NOT_TAA2);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[1], 1.000, 0.500, NOT_TAA1);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[0], 1.000, 0.500, NOT_TAA0);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[79], 1.000, 0.500, NOT_TDA79);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[78], 1.000, 0.500, NOT_TDA78);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[77], 1.000, 0.500, NOT_TDA77);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[76], 1.000, 0.500, NOT_TDA76);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[75], 1.000, 0.500, NOT_TDA75);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[74], 1.000, 0.500, NOT_TDA74);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[73], 1.000, 0.500, NOT_TDA73);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[72], 1.000, 0.500, NOT_TDA72);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[71], 1.000, 0.500, NOT_TDA71);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[70], 1.000, 0.500, NOT_TDA70);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[69], 1.000, 0.500, NOT_TDA69);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[68], 1.000, 0.500, NOT_TDA68);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[67], 1.000, 0.500, NOT_TDA67);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[66], 1.000, 0.500, NOT_TDA66);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[65], 1.000, 0.500, NOT_TDA65);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[64], 1.000, 0.500, NOT_TDA64);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[63], 1.000, 0.500, NOT_TDA63);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[62], 1.000, 0.500, NOT_TDA62);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[61], 1.000, 0.500, NOT_TDA61);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[60], 1.000, 0.500, NOT_TDA60);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[59], 1.000, 0.500, NOT_TDA59);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[58], 1.000, 0.500, NOT_TDA58);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[57], 1.000, 0.500, NOT_TDA57);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[56], 1.000, 0.500, NOT_TDA56);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[55], 1.000, 0.500, NOT_TDA55);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[54], 1.000, 0.500, NOT_TDA54);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[53], 1.000, 0.500, NOT_TDA53);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[52], 1.000, 0.500, NOT_TDA52);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[51], 1.000, 0.500, NOT_TDA51);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[50], 1.000, 0.500, NOT_TDA50);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[49], 1.000, 0.500, NOT_TDA49);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[48], 1.000, 0.500, NOT_TDA48);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[47], 1.000, 0.500, NOT_TDA47);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[46], 1.000, 0.500, NOT_TDA46);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[45], 1.000, 0.500, NOT_TDA45);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[44], 1.000, 0.500, NOT_TDA44);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[43], 1.000, 0.500, NOT_TDA43);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[42], 1.000, 0.500, NOT_TDA42);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[41], 1.000, 0.500, NOT_TDA41);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[40], 1.000, 0.500, NOT_TDA40);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[39], 1.000, 0.500, NOT_TDA39);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[38], 1.000, 0.500, NOT_TDA38);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[37], 1.000, 0.500, NOT_TDA37);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[36], 1.000, 0.500, NOT_TDA36);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[35], 1.000, 0.500, NOT_TDA35);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[34], 1.000, 0.500, NOT_TDA34);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[33], 1.000, 0.500, NOT_TDA33);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[32], 1.000, 0.500, NOT_TDA32);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[31], 1.000, 0.500, NOT_TDA31);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[30], 1.000, 0.500, NOT_TDA30);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[29], 1.000, 0.500, NOT_TDA29);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[28], 1.000, 0.500, NOT_TDA28);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[27], 1.000, 0.500, NOT_TDA27);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[26], 1.000, 0.500, NOT_TDA26);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[25], 1.000, 0.500, NOT_TDA25);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[24], 1.000, 0.500, NOT_TDA24);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[23], 1.000, 0.500, NOT_TDA23);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[22], 1.000, 0.500, NOT_TDA22);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[21], 1.000, 0.500, NOT_TDA21);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[20], 1.000, 0.500, NOT_TDA20);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[19], 1.000, 0.500, NOT_TDA19);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[18], 1.000, 0.500, NOT_TDA18);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[17], 1.000, 0.500, NOT_TDA17);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[16], 1.000, 0.500, NOT_TDA16);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[15], 1.000, 0.500, NOT_TDA15);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[14], 1.000, 0.500, NOT_TDA14);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[13], 1.000, 0.500, NOT_TDA13);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[12], 1.000, 0.500, NOT_TDA12);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[11], 1.000, 0.500, NOT_TDA11);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[10], 1.000, 0.500, NOT_TDA10);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[9], 1.000, 0.500, NOT_TDA9);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[8], 1.000, 0.500, NOT_TDA8);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[7], 1.000, 0.500, NOT_TDA7);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[6], 1.000, 0.500, NOT_TDA6);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[5], 1.000, 0.500, NOT_TDA5);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[4], 1.000, 0.500, NOT_TDA4);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[3], 1.000, 0.500, NOT_TDA3);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[2], 1.000, 0.500, NOT_TDA2);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[1], 1.000, 0.500, NOT_TDA1);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[0], 1.000, 0.500, NOT_TDA0);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[79], 1.000, 0.500, NOT_TDA79);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[78], 1.000, 0.500, NOT_TDA78);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[77], 1.000, 0.500, NOT_TDA77);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[76], 1.000, 0.500, NOT_TDA76);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[75], 1.000, 0.500, NOT_TDA75);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[74], 1.000, 0.500, NOT_TDA74);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[73], 1.000, 0.500, NOT_TDA73);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[72], 1.000, 0.500, NOT_TDA72);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[71], 1.000, 0.500, NOT_TDA71);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[70], 1.000, 0.500, NOT_TDA70);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[69], 1.000, 0.500, NOT_TDA69);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[68], 1.000, 0.500, NOT_TDA68);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[67], 1.000, 0.500, NOT_TDA67);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[66], 1.000, 0.500, NOT_TDA66);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[65], 1.000, 0.500, NOT_TDA65);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[64], 1.000, 0.500, NOT_TDA64);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[63], 1.000, 0.500, NOT_TDA63);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[62], 1.000, 0.500, NOT_TDA62);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[61], 1.000, 0.500, NOT_TDA61);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[60], 1.000, 0.500, NOT_TDA60);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[59], 1.000, 0.500, NOT_TDA59);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[58], 1.000, 0.500, NOT_TDA58);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[57], 1.000, 0.500, NOT_TDA57);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[56], 1.000, 0.500, NOT_TDA56);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[55], 1.000, 0.500, NOT_TDA55);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[54], 1.000, 0.500, NOT_TDA54);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[53], 1.000, 0.500, NOT_TDA53);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[52], 1.000, 0.500, NOT_TDA52);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[51], 1.000, 0.500, NOT_TDA51);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[50], 1.000, 0.500, NOT_TDA50);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[49], 1.000, 0.500, NOT_TDA49);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[48], 1.000, 0.500, NOT_TDA48);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[47], 1.000, 0.500, NOT_TDA47);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[46], 1.000, 0.500, NOT_TDA46);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[45], 1.000, 0.500, NOT_TDA45);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[44], 1.000, 0.500, NOT_TDA44);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[43], 1.000, 0.500, NOT_TDA43);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[42], 1.000, 0.500, NOT_TDA42);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[41], 1.000, 0.500, NOT_TDA41);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[40], 1.000, 0.500, NOT_TDA40);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[39], 1.000, 0.500, NOT_TDA39);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[38], 1.000, 0.500, NOT_TDA38);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[37], 1.000, 0.500, NOT_TDA37);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[36], 1.000, 0.500, NOT_TDA36);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[35], 1.000, 0.500, NOT_TDA35);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[34], 1.000, 0.500, NOT_TDA34);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[33], 1.000, 0.500, NOT_TDA33);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[32], 1.000, 0.500, NOT_TDA32);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[31], 1.000, 0.500, NOT_TDA31);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[30], 1.000, 0.500, NOT_TDA30);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[29], 1.000, 0.500, NOT_TDA29);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[28], 1.000, 0.500, NOT_TDA28);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[27], 1.000, 0.500, NOT_TDA27);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[26], 1.000, 0.500, NOT_TDA26);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[25], 1.000, 0.500, NOT_TDA25);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[24], 1.000, 0.500, NOT_TDA24);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[23], 1.000, 0.500, NOT_TDA23);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[22], 1.000, 0.500, NOT_TDA22);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[21], 1.000, 0.500, NOT_TDA21);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[20], 1.000, 0.500, NOT_TDA20);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[19], 1.000, 0.500, NOT_TDA19);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[18], 1.000, 0.500, NOT_TDA18);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[17], 1.000, 0.500, NOT_TDA17);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[16], 1.000, 0.500, NOT_TDA16);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[15], 1.000, 0.500, NOT_TDA15);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[14], 1.000, 0.500, NOT_TDA14);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[13], 1.000, 0.500, NOT_TDA13);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[12], 1.000, 0.500, NOT_TDA12);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[11], 1.000, 0.500, NOT_TDA11);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[10], 1.000, 0.500, NOT_TDA10);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[9], 1.000, 0.500, NOT_TDA9);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[8], 1.000, 0.500, NOT_TDA8);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[7], 1.000, 0.500, NOT_TDA7);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[6], 1.000, 0.500, NOT_TDA6);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[5], 1.000, 0.500, NOT_TDA5);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[4], 1.000, 0.500, NOT_TDA4);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[3], 1.000, 0.500, NOT_TDA3);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[2], 1.000, 0.500, NOT_TDA2);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[1], 1.000, 0.500, NOT_TDA1);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[0], 1.000, 0.500, NOT_TDA0);
    $setuphold(posedge CLKB, posedge TENB, 1.000, 0.500, NOT_TENB);
    $setuphold(posedge CLKB, negedge TENB, 1.000, 0.500, NOT_TENB);
    $setuphold(posedge CLKB &&& TENBeq0, posedge TCENB, 1.000, 0.500, NOT_TCENB);
    $setuphold(posedge CLKB &&& TENBeq0, negedge TCENB, 1.000, 0.500, NOT_TCENB);
    $setuphold(posedge RET1N &&& TENBeq0, negedge TCENB, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TWENB, 1.000, 0.500, NOT_TWENB);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TWENB, 1.000, 0.500, NOT_TWENB);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[10], 1.000, 0.500, NOT_TAB10);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[9], 1.000, 0.500, NOT_TAB9);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[8], 1.000, 0.500, NOT_TAB8);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[7], 1.000, 0.500, NOT_TAB7);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[6], 1.000, 0.500, NOT_TAB6);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[5], 1.000, 0.500, NOT_TAB5);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[4], 1.000, 0.500, NOT_TAB4);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[3], 1.000, 0.500, NOT_TAB3);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[2], 1.000, 0.500, NOT_TAB2);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[1], 1.000, 0.500, NOT_TAB1);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[0], 1.000, 0.500, NOT_TAB0);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[10], 1.000, 0.500, NOT_TAB10);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[9], 1.000, 0.500, NOT_TAB9);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[8], 1.000, 0.500, NOT_TAB8);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[7], 1.000, 0.500, NOT_TAB7);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[6], 1.000, 0.500, NOT_TAB6);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[5], 1.000, 0.500, NOT_TAB5);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[4], 1.000, 0.500, NOT_TAB4);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[3], 1.000, 0.500, NOT_TAB3);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[2], 1.000, 0.500, NOT_TAB2);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[1], 1.000, 0.500, NOT_TAB1);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[0], 1.000, 0.500, NOT_TAB0);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[79], 1.000, 0.500, NOT_TDB79);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[78], 1.000, 0.500, NOT_TDB78);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[77], 1.000, 0.500, NOT_TDB77);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[76], 1.000, 0.500, NOT_TDB76);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[75], 1.000, 0.500, NOT_TDB75);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[74], 1.000, 0.500, NOT_TDB74);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[73], 1.000, 0.500, NOT_TDB73);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[72], 1.000, 0.500, NOT_TDB72);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[71], 1.000, 0.500, NOT_TDB71);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[70], 1.000, 0.500, NOT_TDB70);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[69], 1.000, 0.500, NOT_TDB69);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[68], 1.000, 0.500, NOT_TDB68);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[67], 1.000, 0.500, NOT_TDB67);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[66], 1.000, 0.500, NOT_TDB66);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[65], 1.000, 0.500, NOT_TDB65);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[64], 1.000, 0.500, NOT_TDB64);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[63], 1.000, 0.500, NOT_TDB63);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[62], 1.000, 0.500, NOT_TDB62);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[61], 1.000, 0.500, NOT_TDB61);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[60], 1.000, 0.500, NOT_TDB60);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[59], 1.000, 0.500, NOT_TDB59);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[58], 1.000, 0.500, NOT_TDB58);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[57], 1.000, 0.500, NOT_TDB57);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[56], 1.000, 0.500, NOT_TDB56);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[55], 1.000, 0.500, NOT_TDB55);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[54], 1.000, 0.500, NOT_TDB54);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[53], 1.000, 0.500, NOT_TDB53);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[52], 1.000, 0.500, NOT_TDB52);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[51], 1.000, 0.500, NOT_TDB51);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[50], 1.000, 0.500, NOT_TDB50);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[49], 1.000, 0.500, NOT_TDB49);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[48], 1.000, 0.500, NOT_TDB48);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[47], 1.000, 0.500, NOT_TDB47);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[46], 1.000, 0.500, NOT_TDB46);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[45], 1.000, 0.500, NOT_TDB45);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[44], 1.000, 0.500, NOT_TDB44);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[43], 1.000, 0.500, NOT_TDB43);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[42], 1.000, 0.500, NOT_TDB42);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[41], 1.000, 0.500, NOT_TDB41);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[40], 1.000, 0.500, NOT_TDB40);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[39], 1.000, 0.500, NOT_TDB39);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[38], 1.000, 0.500, NOT_TDB38);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[37], 1.000, 0.500, NOT_TDB37);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[36], 1.000, 0.500, NOT_TDB36);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[35], 1.000, 0.500, NOT_TDB35);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[34], 1.000, 0.500, NOT_TDB34);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[33], 1.000, 0.500, NOT_TDB33);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[32], 1.000, 0.500, NOT_TDB32);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[31], 1.000, 0.500, NOT_TDB31);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[30], 1.000, 0.500, NOT_TDB30);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[29], 1.000, 0.500, NOT_TDB29);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[28], 1.000, 0.500, NOT_TDB28);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[27], 1.000, 0.500, NOT_TDB27);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[26], 1.000, 0.500, NOT_TDB26);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[25], 1.000, 0.500, NOT_TDB25);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[24], 1.000, 0.500, NOT_TDB24);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[23], 1.000, 0.500, NOT_TDB23);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[22], 1.000, 0.500, NOT_TDB22);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[21], 1.000, 0.500, NOT_TDB21);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[20], 1.000, 0.500, NOT_TDB20);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[19], 1.000, 0.500, NOT_TDB19);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[18], 1.000, 0.500, NOT_TDB18);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[17], 1.000, 0.500, NOT_TDB17);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[16], 1.000, 0.500, NOT_TDB16);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[15], 1.000, 0.500, NOT_TDB15);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[14], 1.000, 0.500, NOT_TDB14);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[13], 1.000, 0.500, NOT_TDB13);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[12], 1.000, 0.500, NOT_TDB12);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[11], 1.000, 0.500, NOT_TDB11);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[10], 1.000, 0.500, NOT_TDB10);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[9], 1.000, 0.500, NOT_TDB9);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[8], 1.000, 0.500, NOT_TDB8);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[7], 1.000, 0.500, NOT_TDB7);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[6], 1.000, 0.500, NOT_TDB6);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[5], 1.000, 0.500, NOT_TDB5);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[4], 1.000, 0.500, NOT_TDB4);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[3], 1.000, 0.500, NOT_TDB3);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[2], 1.000, 0.500, NOT_TDB2);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[1], 1.000, 0.500, NOT_TDB1);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[0], 1.000, 0.500, NOT_TDB0);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[79], 1.000, 0.500, NOT_TDB79);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[78], 1.000, 0.500, NOT_TDB78);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[77], 1.000, 0.500, NOT_TDB77);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[76], 1.000, 0.500, NOT_TDB76);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[75], 1.000, 0.500, NOT_TDB75);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[74], 1.000, 0.500, NOT_TDB74);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[73], 1.000, 0.500, NOT_TDB73);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[72], 1.000, 0.500, NOT_TDB72);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[71], 1.000, 0.500, NOT_TDB71);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[70], 1.000, 0.500, NOT_TDB70);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[69], 1.000, 0.500, NOT_TDB69);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[68], 1.000, 0.500, NOT_TDB68);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[67], 1.000, 0.500, NOT_TDB67);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[66], 1.000, 0.500, NOT_TDB66);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[65], 1.000, 0.500, NOT_TDB65);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[64], 1.000, 0.500, NOT_TDB64);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[63], 1.000, 0.500, NOT_TDB63);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[62], 1.000, 0.500, NOT_TDB62);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[61], 1.000, 0.500, NOT_TDB61);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[60], 1.000, 0.500, NOT_TDB60);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[59], 1.000, 0.500, NOT_TDB59);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[58], 1.000, 0.500, NOT_TDB58);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[57], 1.000, 0.500, NOT_TDB57);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[56], 1.000, 0.500, NOT_TDB56);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[55], 1.000, 0.500, NOT_TDB55);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[54], 1.000, 0.500, NOT_TDB54);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[53], 1.000, 0.500, NOT_TDB53);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[52], 1.000, 0.500, NOT_TDB52);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[51], 1.000, 0.500, NOT_TDB51);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[50], 1.000, 0.500, NOT_TDB50);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[49], 1.000, 0.500, NOT_TDB49);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[48], 1.000, 0.500, NOT_TDB48);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[47], 1.000, 0.500, NOT_TDB47);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[46], 1.000, 0.500, NOT_TDB46);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[45], 1.000, 0.500, NOT_TDB45);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[44], 1.000, 0.500, NOT_TDB44);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[43], 1.000, 0.500, NOT_TDB43);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[42], 1.000, 0.500, NOT_TDB42);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[41], 1.000, 0.500, NOT_TDB41);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[40], 1.000, 0.500, NOT_TDB40);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[39], 1.000, 0.500, NOT_TDB39);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[38], 1.000, 0.500, NOT_TDB38);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[37], 1.000, 0.500, NOT_TDB37);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[36], 1.000, 0.500, NOT_TDB36);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[35], 1.000, 0.500, NOT_TDB35);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[34], 1.000, 0.500, NOT_TDB34);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[33], 1.000, 0.500, NOT_TDB33);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[32], 1.000, 0.500, NOT_TDB32);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[31], 1.000, 0.500, NOT_TDB31);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[30], 1.000, 0.500, NOT_TDB30);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[29], 1.000, 0.500, NOT_TDB29);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[28], 1.000, 0.500, NOT_TDB28);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[27], 1.000, 0.500, NOT_TDB27);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[26], 1.000, 0.500, NOT_TDB26);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[25], 1.000, 0.500, NOT_TDB25);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[24], 1.000, 0.500, NOT_TDB24);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[23], 1.000, 0.500, NOT_TDB23);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[22], 1.000, 0.500, NOT_TDB22);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[21], 1.000, 0.500, NOT_TDB21);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[20], 1.000, 0.500, NOT_TDB20);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[19], 1.000, 0.500, NOT_TDB19);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[18], 1.000, 0.500, NOT_TDB18);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[17], 1.000, 0.500, NOT_TDB17);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[16], 1.000, 0.500, NOT_TDB16);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[15], 1.000, 0.500, NOT_TDB15);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[14], 1.000, 0.500, NOT_TDB14);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[13], 1.000, 0.500, NOT_TDB13);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[12], 1.000, 0.500, NOT_TDB12);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[11], 1.000, 0.500, NOT_TDB11);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[10], 1.000, 0.500, NOT_TDB10);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[9], 1.000, 0.500, NOT_TDB9);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[8], 1.000, 0.500, NOT_TDB8);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[7], 1.000, 0.500, NOT_TDB7);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[6], 1.000, 0.500, NOT_TDB6);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[5], 1.000, 0.500, NOT_TDB5);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[4], 1.000, 0.500, NOT_TDB4);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[3], 1.000, 0.500, NOT_TDB3);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[2], 1.000, 0.500, NOT_TDB2);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[1], 1.000, 0.500, NOT_TDB1);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[0], 1.000, 0.500, NOT_TDB0);
    $setuphold(posedge CLKA &&& opopTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cpcpandopopTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cpcp, posedge RET1N, 1.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKA &&& opopTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cpcpandopopTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cpcp, negedge RET1N, 1.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKB &&& opopTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cpcpandopopTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cpcp, posedge RET1N, 1.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKB &&& opopTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cpcpandopopTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cpcp, negedge RET1N, 1.000, 0.500, NOT_RET1N);
    $setuphold(posedge CENA, negedge RET1N, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CENB, negedge RET1N, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge TCENA, negedge RET1N, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge TCENB, negedge RET1N, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge STOVA, 1.000, 0.500, NOT_STOVA);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge STOVA, 1.000, 0.500, NOT_STOVA);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge STOVB, 1.000, 0.500, NOT_STOVB);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge STOVB, 1.000, 0.500, NOT_STOVB);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge COLLDISN, 1.000, 0.500, NOT_COLLDISN);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge COLLDISN, 1.000, 0.500, NOT_COLLDISN);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge COLLDISN, 1.000, 0.500, NOT_COLLDISN);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge COLLDISN, 1.000, 0.500, NOT_COLLDISN);
  endspecify


endmodule
`endcelldefine
`endif
`timescale 1ns/1ps
module sram_dp_hde_error_injection (Q_out, Q_in, CLK, A, CEN, WEN, BEN, TQ);
   output [79:0] Q_out;
   input [79:0] Q_in;
   input CLK;
   input [10:0] A;
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
   reg [22:0] fault_table [511:0];
   reg [22:0] fault_entry;
initial
begin
   `ifdef DUT
      `define pre_pend_path TB.DUT_inst.CHIP
   `else
       `define pre_pend_path TB.CHIP
   `endif
   `ifdef ARM_NONREPAIRABLE_FAULT
      `pre_pend_path.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST.u1.add_fault(11'd126,7'd6,2'd1,2'd0);
   `endif
end
   task add_fault;
   //This task injects fault in memory
      input [10:0] address;
      input [6:0] bitPlace;
      input [1:0] fault_type;
      input [1:0] red_fault;
 
      integer i;
      reg done;
   begin
      done = 1'b0;
      i = 0;
      while ((!done) && i < 511)
      begin
         fault_entry = fault_table[i];
         if (fault_entry[0] === 1'b0 || fault_entry[0] === 1'bx)
         begin
            fault_entry[0] = 1'b1;
            fault_entry[2:1] = red_fault;
            fault_entry[4:3] = fault_type;
            fault_entry[11:5] = bitPlace;
            fault_entry[22:12] = address;
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
   for (i = 0; i < 512; i=i+1)
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
   reg [8:0] row_address;
   reg [1:0] column_address;
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
            if (row_address == A[10:2] && column_address == A[1:0])
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
