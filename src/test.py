from PIL import Image
import Evaluator as ev
import numpy as np
import Bicubic
import cv2
import time
import os
import re

def evTester():
    image = Image.open('../proj_2017/Set14/baboon.bmp')
    img = np.asarray(image)
    psnr = ev.PSNR(img, img)
    ssim = ev.SSIM(img, img)
    print psnr, ssim

def bicubicTester():
    image = Image.open('../proj_2017/Set14/bridge.bmp')
    img = np.asarray(image)
    M, N = (img.shape[0], img.shape[1])
    # small_img = Bicubic.bicubic(img, (M/3, N/3))
    # restored_img = Bicubic.bicubic(small_img, (M, N))
    restored_img = np.array(Image.open('test2.png'))
    # Image.fromarray(restored_img).save('test2.png's)
    psnr = ev.PSNR(img, restored_img)
    print psnr
    mssim = ev.MSSIM(img, restored_img)
    print mssim

def ssimTest():
    img1 = np.asarray(Image.open('Einstein/image001.jpg'))
    img2 = np.asarray(Image.open('Einstein/image003.jpg'))
    img3 = np.asarray(Image.open('Einstein/image004.jpg'))
    start = time.clock()
    print ev.MSSIM(img1, img2)
    end = time.clock()
    print 'running time: {}'.format(end - start)

def bicubicSet14():
    dirPath = raw_input('dirPath: ')
    pathDir = os.listdir(dirPath)
    directory = [filename for filename in pathDir if re.search('bmp', filename)]
    f = open('../result/result.txt', 'w+')
    f.write("Filename: (PSNR, SSIM)\n")

    for image_name in directory:
        image = Image.open(dirPath+image_name)
        img = np.asarray(image)
        M, N = (img.shape[0], img.shape[1])
        small_img = Bicubic.bicubic(img, (M/3, N/3))
        restored_img = Bicubic.bicubic(small_img, (M, N))
        Image.fromarray(restored_img).save('../result/'+image_name+'.png')
        result_tmp = '{}: (PSRN: {}, SSIM: {})'.format(image_name, ev.PSNR(img, restored_img), ev.MSSIM(img, restored_img))
        f.write(result_tmp)
        print result_tmp

def doseImagesEqual():
    img1 = np.asarray(Image.open('test.png'))
    img2 = np.asarray(Image.open('bicubic1.bmp'))
    M, N = (img1.shape[0], img1.shape[1])
    for i in range(M):
        for j in range(N):
            if (img1[i,j] != img2[i,j]).all():
                print '({},{})'.format(i, j)
                print img1[i,j], img2[i,j]

def main():
    start = time.clock()
    # bicubicSet14()
    bicubicTester()
    # doseImagesEqual()
    end = time.clock()
    print 'running time: {}'.format(end - start)
    # ssimTest()

if __name__ == "__main__":
    main()