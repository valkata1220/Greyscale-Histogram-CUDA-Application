// ImageLoad2.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
using namespace std;


int main()
{

	int width, height, channels;
	char filename[20];
	char picture[100];
	bool f;

	cout << "Enter image location:" << endl;
	cin >> picture;

	stbi_set_flip_vertically_on_load(true);
	unsigned char *image = stbi_load(picture, &width,	&height, &channels,	3);
	if (!image) cout << "Unsuccessful loading!"<<endl;
	else
		cout << "Image successfuly loaded" << endl;
	cout << "Enter new filename" << endl;
	cin >> filename;

	 stbi_write_jpg(filename, width, height, channels, image, 100);
    return 0;
}

