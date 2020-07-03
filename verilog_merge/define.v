/* constants */
`define MIN 32000//2^(CALC_WIDTH-1)
`define DIRECTION_WIDTH 5
`define BP_WIDTH 2
`define CALC_WIDTH 16

/* score */
`define MATCH 2
`define MISMATCH 4
`define Q 4
`define E 2
`define Q_hat 24
`define E_hat 1

/* Hardware Resources */
`define N 256 //PE array size
`define log_N 8
`define MEM_SIZE 2048 //should be 2048
`define ADDRESS_WIDTH 11 //log(MEM_SIZE)
`define MEM_AMOUNT 8 // iteration numbers, aka SEQ_MAX_LEN/N
`define MEM_AMOUNT_WIDTH 3 //log(MEM_AMOUNT)
`define RAM_NUM 16 // N/16
`define log_RAM_NUM 4
`define MEM_WIDTH 16
`define log_MEM_WIDTH 4 
`define MEM_BLOCK 128 //SEQ_MAX_LEN/MEM_WIDTH
`define MEM_BLOCK_WIDTH 7 //log(MEM_BLOCK)
`define LZA 47 //leading zero amoumt, 80 - 3*ADDRESS_WIDTH

`define SEQ_MAX_LEN 2048//should be 2048, this var is for testbench only

/* Traceback Resources */
`define PREFETCH_LENGTH 16 //prefetch block size
`define POSITION_WIDTH 11 //log(SEQ_MAX_LEN)
`define PREFETCH_WIDTH 4 //log(PREFETCH_LENGTH)