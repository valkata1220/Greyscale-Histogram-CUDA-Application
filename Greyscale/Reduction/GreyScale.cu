

#include <string.h>
#include <math.h>
#include <float.h>
#include "helper_cuda.h"
#include "stdafx.h"
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
using namespace std;


////////////////////////////////////////////////////////////////////////////////
// GPU routines
////////////////////////////////////////////////////////////////////////////////

__global__ void GrayScale(int *g_outdata, unsigned char *g_indata, int bin_width)
{
	int tid = (threadIdx.x + blockDim.x*blockIdx.x)*3;
	unsigned char gray = (g_indata[tid] + g_indata[tid+1] + g_indata[tid + 2])/3;
	atomicAdd(&g_outdata[gray / bin_width], 1);
	//g_outdata[tid] = gray;
	//g_outdata[tid+1] = gray;
	//g_outdata[tid+2] = gray;
}


int main(int argc, const char **argv)
{
	int num_elements, num_threads, mem_size, num_blocks,bin_count,bin_width;
	int width, height, channels;
	char filename[20];
	char picture[100];
	//bool f;
	unsigned char *din_image;
	unsigned char *dout_image;
	int *out_hist;
	int *histogram;


	cout << "Enter image location:" << endl;
	cin >> picture;

	// User entering blocks count...
	cout << "Enter blocks count:" << endl;
	cin >> bin_count;

	bin_width = 255 / bin_count;
	if (bin_count % 255 != 0) bin_width += 1;

	unsigned char *image = stbi_load(picture, &width, &height, &channels, 3);
	if (!image) cout << "Unsuccessful loading!" << endl;
	else cout << "Image successfuly loaded" << endl;

	findCudaDevice(argc, argv);
	
	histogram = (int*) malloc(bin_count * sizeof(int));
	mem_size = sizeof(char) * (width*height*3);
	checkCudaErrors(cudaMalloc((void**)&din_image, mem_size));
	checkCudaErrors(cudaMalloc((void**)&out_hist, bin_count * sizeof(int)));
	//checkCudaErrors(cudaMalloc((void**)&dout_image, bin_count * sizeof(int)));
	checkCudaErrors(cudaMemcpy(din_image, image, mem_size, cudaMemcpyHostToDevice));

	
	
	num_elements = width*height;
	num_threads = 1024;
	num_blocks = num_elements/num_threads;

	GrayScale << <num_blocks, num_threads >> > (out_hist, din_image,bin_width);
	getLastCudaError("GrayScale kernel execution failed");

	// copy result from device to host

	//checkCudaErrors(cudaMemcpy(image, dout_image, mem_size, cudaMemcpyDeviceToHost));
	checkCudaErrors(cudaMemcpy(histogram, out_hist, bin_count * sizeof(int), cudaMemcpyDeviceToHost));


	cout << "Enter new filename" << endl;
	cin >> filename;

	//stbi_write_jpg(filename, width, height, channels, image, 100);

	for (int i = 0; i < bin_count; i++)
	{
		printf("Bin ¹ %d - %d\n", i, histogram[i]);
	}
	free(image);

	checkCudaErrors(cudaFree(din_image));
	//checkCudaErrors(cudaFree(dout_image));
	cudaDeviceReset();

	return 0;

}


