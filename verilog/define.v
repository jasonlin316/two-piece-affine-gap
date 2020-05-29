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
`define N 8 //PE array size
`define log_N 3
`define MEM_SIZE 64 //should be 2048
`define ADDRESS_WIDTH 6 //log(MEM_SIZE)
`define MEM_AMOUNT 8 // iteration numbers, aka SEQ_MAX_LEN/N
`define MEM_AMOUNT_WIDTH 3 //log(MEM_AMOUNT)

`define SEQ_MAX_LEN 64//should be 2048, this var is for testbench only
