# filtersRestore
I used the libsvm and VCNN from *https://github.com/Georgezhouzhou/vcnn_double-bladed*. Only used code for my repository is reversed.
Here is  supply code. You should download my pic.zip from https://yunpan.cn/cMXIiYpnvz663 passward：6138  ,and untar it under the path **libsvm-3.21\feature**.

# Steps to run
1. First you can just turn to the script 'preModel' to get started.
The script does the following things:
 - It gets the data-hist of training sets and test sets, then it automatically adjusts two parameters to  get the best fitted model with the RBF kernel function.
 - It prints the parameters' values and other informations. And it mainly stores variables in the workspace into the data *preModel.mat*.

2. When you have prepared the data model(preModel), You can also choose to run in a GUI method. This requires you do the stuffs.
 - Turn to the **GUI.m** and run it.
 - You should choose the correct item to get ready for the correct answer.
 - Filters are divided into two categories: Normal filters(10 types) and specical filters(5 types).  

  

# Things should be payed attention to
## About 'preModel' script
1. 'preModel' script just takes the datahist model to get the filtered images restored. LBP model preforms badly for prediction. 
2. You can simply add more deleteClasses by simply adding filters' name into the '{}', then svmtrain will automatically ignore those filters. There is a tiny bug in the script, which is that at least one deleting class should be added to get it operating correctly.

## About 'getModelx' script
By now, I have only provided two main ways to get deal with restoring images filtered by normal filters. Although both of them perform badly for more than half of the 12 filters, several filters just fit well. These filters are 'dy','fs','zrmf','zrlb','rh'. It seems funny when you see the poor situation. But it is the truth.

Two main methods are realized by getModel1 and getModel2/getModel3. They are separately corresponding to cal_A and cal_C/cal_CC. cal_A is the first way to get matirx of 3x4. It just fits the situation when the main dialog's values are almost 1. In fact, the idea of such approach is bound to fail for its strict constraints. The second way is to calculate the 3x4 matirx by two steps: 3x3 square matirx and 1x3 martrix, while the first matrix is  obtained by randomly extracting three pairs of pixel points from the orignal image and the filtered image. The second matrix can be achieved by just extracting one pair pixel, among which one is from the orignal image and another is from the filtered.

## About models
In order to get images restored better, I used *sharpen* and *color enhance* on the basis of the fact that filtered images tend to show more blurry and color channel faint. On thing has to be knowed: CNN indeed can restored filtered images. However, in consideration of my net is quite shallow, restoration effect is barely satisfactory. So I add the two stages of post-processing. Note, I do no such processing to *rh* filter effect.

## About VCNN
VCNN is a framework from github. I just exchange the input and output to try getting a opposite effect. By far, several special types of filters are simulated. The first one *sharpen* works quite well, some filter effects such as 'zuanqiang','GuassBlur' perform well, however, 'psMasic4' and 'dssmx' show quite bad restoration.



