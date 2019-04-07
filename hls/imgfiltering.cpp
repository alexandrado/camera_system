#include "imgfiltering.h"
#include "stdio.h"

void img_filter(hls::stream<uint_8_side_channel> &inStream,hls::stream<uint_8_side_channel> &outStream, ap_uint<3> sel){
	#pragma HLS INTERFACE axis port=inStream
	#pragma HLS INTERFACE axis port=outStream

	char kernel[KERNEL_DIM*KERNEL_DIM];

	switch(sel){
		case 0: {
			kernel[0] = 0; kernel[1] = 0; kernel[2] = 0;
			kernel[3] = 0; kernel[4] = 1; kernel[5] = 0;
			kernel[6] = 0; kernel[7] = 0; kernel[8] = 0;
			break;
		}
		case 1:{
			kernel[0] = -1; kernel[1] = -1; kernel[2] = -1;
			kernel[3] = -1; kernel[4] = 8; kernel[5] = -1;
			kernel[6] = -1; kernel[7] = -1; kernel[8] = -1;
			break;
		}
		case 2:{
			kernel[0] = -1; kernel[1] = -2; kernel[2] = -1;
			kernel[3] = 0; kernel[4] = 0; kernel[5] = 0;
			kernel[6] = 1; kernel[7] = 2; kernel[8] = 1;
			break;
		}
		default:{
			kernel[0] = 0; kernel[1] = 0; kernel[2] = 0;
			kernel[3] = 0; kernel[4] = 1; kernel[5] = 0;
			kernel[6] = 0; kernel[7] = 0; kernel[8] = 0;
			break;
		}
	}

	hls::LineBuffer<KERNEL_DIM,IMG_WIDTH_OR_COLS,unsigned char> lineBuff;
	hls::Window<KERNEL_DIM,KERNEL_DIM,short> window;

	int idxCol = 0;
	int idxRow = 0;
	int pixConvolved = 0;
	int waitTicks = (IMG_WIDTH_OR_COLS*(KERNEL_DIM-1)+KERNEL_DIM)/2;
	int countWait = 0;
	int sentPixels = 0;

	uint_8_side_channel dataOutSideChannel;
	uint_8_side_channel currPixelSideChannel;

	if(sel < 4){
		for(int idxPixel = 0; idxPixel < (IMG_WIDTH_OR_COLS*IMG_HEIGHT_OR_ROWS);idxPixel++){
			#pragma HLS PIPELINE
			currPixelSideChannel = inStream.read();
			ap_uint<8> data1 = currPixelSideChannel.data;

			currPixelSideChannel = inStream.read();
			ap_uint<8> data2 = currPixelSideChannel.data;

			unsigned char red = (255*data1.range(7,3))/31;
			unsigned char green = (255*( data1.range(2,0)*8 + data2.range(7,5)))/63;
			unsigned char blue = (255*data2.range(4,0))/31;


			unsigned char pixelIn = (red+green+blue)/3;

			lineBuff.shift_up(idxCol);
			lineBuff.insert_top(pixelIn,idxCol);

			for(int idxWinRow = 0; idxWinRow < KERNEL_DIM; idxWinRow++){
				for(int idxWinCol = 0; idxWinCol < KERNEL_DIM; idxWinCol++){
					short val = (short)lineBuff.getval(idxWinRow,idxWinCol+pixConvolved);

					val = (short)kernel[(idxWinRow*KERNEL_DIM)+idxWinCol]*val;
					window.insert(val,idxWinRow,idxWinCol);

				}
			}

			short valOutput = 0;
			if((idxRow >= KERNEL_DIM-1)&&(idxCol >=KERNEL_DIM-1)){
					valOutput = sum(&window);
					if(valOutput <0)
						valOutput = 0;
					pixConvolved++;
			}


			if(idxCol < IMG_WIDTH_OR_COLS -1){
				idxCol++;
			}else{
				idxCol = 0;
				idxRow++;
				pixConvolved = 0;
			}

			countWait++;
			if(countWait > waitTicks){
				valOutput = (31*valOutput)/255;
				dataOutSideChannel.data = (valOutput*8)+(valOutput/4);
				dataOutSideChannel.last = 0;

				outStream.write(dataOutSideChannel);


				dataOutSideChannel.data = (valOutput*64)+(valOutput);
				dataOutSideChannel.last = 0;

				outStream.write(dataOutSideChannel);

				sentPixels++;
			}

		}


		for(countWait = 0; countWait < waitTicks; countWait++){
			dataOutSideChannel.data = 0;
			if(countWait < waitTicks - 1)
				dataOutSideChannel.last = 0;
			else
				dataOutSideChannel.last = 1;

			outStream.write(dataOutSideChannel);
			outStream.write(dataOutSideChannel);
		}
	} else{
		for(int idxPixel = 0; idxPixel < (IMG_WIDTH_OR_COLS*IMG_HEIGHT_OR_ROWS);idxPixel++){
			#pragma HLS PIPELINE
			currPixelSideChannel = inStream.read();
			ap_uint<8> data1 = currPixelSideChannel.data;

			currPixelSideChannel = inStream.read();
			ap_uint<8> data2 = currPixelSideChannel.data;

			if(sel == 5){

				ap_uint<5> red = data1.range(7,3);
				ap_uint<6> green = data1.range(2,0)*8 + data2.range(7,5);
				ap_uint<5> blue = data2.range(4,0);

				bool thr = (red < 32) & (green < 32) & (blue > 15);

				if(thr == false){
					red = 0;
					green = 0;
					blue = 0;
				}


				dataOutSideChannel.data = (red*8)+(green/8);
				dataOutSideChannel.last = 0;

				outStream.write(dataOutSideChannel);

				dataOutSideChannel.data = (green.range(2,0)*32)+(blue);
				dataOutSideChannel.last = 0;

				outStream.write(dataOutSideChannel);
			}else{
				dataOutSideChannel.data = data1;
				dataOutSideChannel.last = 0;

				outStream.write(dataOutSideChannel);

				dataOutSideChannel.data = data2;
				dataOutSideChannel.last = 0;

				outStream.write(dataOutSideChannel);
			}

		}
	}

}

short sum(hls::Window<KERNEL_DIM,KERNEL_DIM,short> *window){
		short accumulator = 0;

		for(int idxRow = 0; idxRow < KERNEL_DIM; idxRow++){
			for(int idxCol = 0; idxCol < KERNEL_DIM; idxCol++){
				accumulator = accumulator + (short)window->getval(idxRow,idxCol);
			}
		}
		return accumulator;
}

