/* constants */
`define MIN 32000//2^(CALC_WIDTH-1)
`define DIRECTION_WIDTH 5
`define BP_WIDTH 2
`define CALC_WIDTH 16

/* score */
`define MATCH 20
`define MISMATCH 1
`define Q 10
`define E 4
`define Q_hat 20
`define E_hat 2

/* Hardware Resources */
`define N 64 //PE array size
`define log_N 6
`define MEM_SIZE 64 //should be 2048
`define ADDRESS_WIDTH 6 //log(MEM_SIZE)
`define MEM_AMOUNT 2 // iteration numbers, aka SEQ_MAX_LEN/N
`define MEM_AMOUNT_WIDTH 1 //log(MEM_AMOUNT)

`define SEQ_MAX_LEN 128//should be 2048, this var is for testbench only

/* Traceback Resources */
`define PREFETCH_LENGTH 16 //prefetch block size
`define PREFETCH_TIMES 8 //SEQ_MAX_LEN/PREFETCH_LENGTH
`define PRELOAD_COUNT_WIDTH 3 //log(PREFETCH_TIMES)
`define POSITION_WIDTH 7 //log(SEQ_MAX_LEN)
`define PREFETCH_WIDTH 4 //log(PREFETCH_LENGTH)