===========
README
EESHAAN SHARMA
2015CSB1011
===========

How to build and run the code.

Step 1 - Extract the folder : P2015CS1011-PA1

Step 2 - To run the code type TestPA1 in the MATLAB Window.

Assumption.

The code is working well for the following images - 

1.) cat-underexposed.jpg
2.) lg-image9.jpg
3.) snow.jpg
4.) squirrel.jpg
5.) xray4a-orig-15pc.png

The image Over.jpg due to its large size is taking a long time to execute and thus to execute the code for Over.jpg, 
I have included a separate test script namely - TestPA1_2.m which when run will show the desired output for the image Over.jpg

Observations.

1.) The first function myHistEqual.m equalizes the histogram of the given image. Thus the original image is transformed 
    in such a way that it has nearly uniform distribution of pixel values. This significantly improves the contrast of the image.
    A general trend is observed in such a way that the contrast of the output image increases by increasing the value of 
    parameter nBins in the function and the best result is obtained at a value of nBins = 256.

2.) The process of Localized Histogram Equalization is implemented in the second function - myAHE.m . The output produced is pretty
    distorted as the process of Histogram Equalization is carried out on each neighbourhood of window size separately. If we increase 
    the value of wSize parameter of function the output observed is better but it takes a lot of time for the code to execute as 
    Histogram Equalization is called a number of times.

3.) The final function myCegaHE.m implements the following procedures as described in the research paper shared - 

	a.)  Gap Adjustment
	b.)  Gray Value Recovery
	c.)  Dark Region Enhancement

    Output after applying each of the 3 procedures is analysed and it is observed that in the end a clear image is produced, with 
    a well balanced Histogram distribution.   