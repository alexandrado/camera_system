#include "hls_video.h"
#include <hls_stream.h>
#define IMG_WIDTH_OR_COLS 640
#define IMG_HEIGHT_OR_ROWS 480

#define KERNEL_DIM 3

typedef struct ap_axiu_video{
    ap_uint<8>       data;
    ap_uint<1>       last;
  } uint_8_side_channel;


void img_filter(hls::stream<uint_8_side_channel> &inStream,hls::stream<uint_8_side_channel> &outStream, ap_uint<3> sel/*, char kernel[KERNEL_DIM*KERNEL_DIM],int operation*/);
short sum(hls::Window<KERNEL_DIM,KERNEL_DIM,short> *windows);

